#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE_ID="com.hwq.PanSheet"
OUT="$ROOT/Docs/screenshots"
DD="$ROOT/build/DerivedData"
APP="$DD/Build/Products/Debug-iphonesimulator/PanSheet.app"
WORK="$ROOT/build/gif"
mkdir -p "$OUT" "$WORK"

DEST_ID="${SIM_UDID:-}"
if [[ -z "$DEST_ID" ]]; then
  DEST_ID="$(python3 - <<'PY'
import json, subprocess
raw = subprocess.check_output(["xcrun", "simctl", "list", "devices", "booted", "-j"])
data = json.loads(raw)
for runtime, devices in data.get("devices", {}).items():
    for d in devices:
        if d.get("state") == "Booted" and "iPhone" in d.get("name", ""):
            print(d["udid"])
            raise SystemExit
print("")
PY
)"
fi
if [[ -z "$DEST_ID" ]]; then
  echo "没有已启动的 iPhone 模拟器" >&2
  exit 1
fi

echo "simulator=$DEST_ID"
xcodebuild -project "$ROOT/PanSheet.xcodeproj" -scheme PanSheet \
  -destination "platform=iOS Simulator,id=$DEST_ID" \
  -derivedDataPath "$DD" \
  CODE_SIGNING_ALLOWED=NO build

xcrun simctl install "$DEST_ID" "$APP"
xcrun simctl terminate "$DEST_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true

MP4="$WORK/tour.mp4"
GIF="$OUT/tour.gif"
rm -f "$MP4" "$GIF"

xcrun simctl io "$DEST_ID" recordVideo --codec=h264 --force "$MP4" &
REC_PID=$!
sleep 1.2
xcrun simctl launch "$DEST_ID" "$BUNDLE_ID" --tour
# 首页 0.55s + 8 段打开/停留/关闭 ≈ 21s，多留一点收尾。
sleep 22
kill -INT "$REC_PID" >/dev/null 2>&1 || true
wait "$REC_PID" || true

if [[ ! -s "$MP4" ]]; then
  echo "没有录到 $MP4" >&2
  exit 1
fi

ffmpeg -y -ss 1.55 -i "$MP4" \
  -vf "fps=12,scale=360:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=80:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5" \
  -loop 0 "$GIF"

ls -lh "$MP4" "$GIF"
echo "wrote $GIF"
xcrun simctl terminate "$DEST_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
