#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE_ID="com.hwq.PanSheet"
OUT="$ROOT/Docs/screenshots"
DD="$ROOT/build/DerivedData"
APP="$DD/Build/Products/Debug-iphonesimulator/PanSheet.app"
WORK="$ROOT/build/gif"
DRAG="$ROOT/build/sim-drag"
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
xcodebuild -project "$ROOT/PanSheet.xcodeproj" -scheme PanSheetDemo \
  -destination "platform=iOS Simulator,id=$DEST_ID" \
  -derivedDataPath "$DD" \
  CODE_SIGNING_ALLOWED=NO build
xcrun simctl install "$DEST_ID" "$APP"
swiftc -O -o "$DRAG" "$ROOT/scripts/sim-drag.swift"

osascript -e 'tell application "Simulator" to activate' >/dev/null
sleep 0.3

encode_gif() {
  local mp4="$1"
  local gif="$2"
  ffmpeg -y -i "$mp4" \
    -vf "fps=12,scale=240:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=64:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5" \
    -loop 0 "$gif" >/dev/null 2>&1
}

# 上滑列表/内容：半屏跟手升高；再从抓手下滑：半屏跟手降低。
swipe_follow() {
  "$DRAG" 603 2000 603 1050 0.48
  sleep 0.38
  "$DRAG" 603 640 603 1600 0.55
  sleep 0.42
  "$DRAG" 603 2000 603 1050 0.48
  sleep 0.38
  "$DRAG" 603 640 603 1600 0.55
  sleep 0.35
}

SCENES=(
  fixed-1
  fixed-2
  fixed-3
  input-single
  input-multi
  list-fill
  list-button
  list-pinned
)

for scene in "${SCENES[@]}"; do
  echo "=== $scene ==="
  xcrun simctl terminate "$DEST_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$DEST_ID" "$BUNDLE_ID" --demo="$scene" --hold-sheet
  sleep 1.25
  osascript -e 'tell application "Simulator" to activate' >/dev/null
  sleep 0.2
  mp4="$WORK/${scene}-scroll.mp4"
  gif="$OUT/${scene}-scroll.gif"
  rm -f "$mp4"
  xcrun simctl io "$DEST_ID" recordVideo --codec=h264 --force "$mp4" &
  rec=$!
  sleep 1.0
  swipe_follow
  kill -INT "$rec" >/dev/null 2>&1 || true
  wait "$rec" || true
  if [[ ! -s "$mp4" ]]; then
    echo "没有录到 $mp4" >&2
    exit 1
  fi
  encode_gif "$mp4" "$gif"
  ls -lh "$gif"
done

xcrun simctl terminate "$DEST_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
echo "done"
