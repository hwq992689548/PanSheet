#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE_ID="com.hwq.PanSheet"
OUT="$ROOT/Docs/screenshots"
DD="$ROOT/build/DerivedData"
APP="$DD/Build/Products/Debug-iphonesimulator/PanSheet.app"

mkdir -p "$OUT"

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
xcodebuild -workspace "$ROOT/PanSheet.xcworkspace" -scheme PanSheetDemo \
  -destination "platform=iOS Simulator,id=$DEST_ID" \
  -derivedDataPath "$DD" \
  CODE_SIGNING_ALLOWED=NO build

xcrun simctl install "$DEST_ID" "$APP"

capture() {
  local demo="$1"
  local file="$2"
  xcrun simctl terminate "$DEST_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$DEST_ID" "$BUNDLE_ID" --demo="$demo"
  sleep 1.6
  xcrun simctl io "$DEST_ID" screenshot "$OUT/$file"
  echo "wrote $OUT/$file"
}

capture home home.png
capture fixed-1 fixed-1.png
capture fixed-2 fixed-2.png
capture fixed-3 fixed-3.png
capture input-single input-single.png
capture input-multi input-multi.png
capture list-fill list-fill.png
capture list-button list-button.png
capture list-pinned list-pinned.png

xcrun simctl terminate "$DEST_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
echo "done"
