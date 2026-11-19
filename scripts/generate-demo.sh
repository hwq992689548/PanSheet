#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/Demo"
xcodegen generate
python3 - <<'PY'
from pathlib import Path
import re
p = Path("PanSheet.xcodeproj/project.pbxproj")
text = p.read_text()
ref = re.search(
    r"([A-F0-9]{24}) /\* XCLocalSwiftPackageReference \"\.\.\" \*/ = \{\n\t\t\tisa = XCLocalSwiftPackageReference;",
    text,
)
dep = re.search(
    r"([A-F0-9]{24}) /\* PanSheet \*/ = \{\n\t\t\tisa = XCSwiftPackageProductDependency;\n\t\t\tproductName = PanSheet;",
    text,
)
if not ref:
    if "XCLocalSwiftPackageReference \"..\"" in text and "package = " in text:
        print("package 引用已在 pbxproj 里")
        raise SystemExit(0)
    raise SystemExit("没找到 XCLocalSwiftPackageReference ..")
if not dep:
    if re.search(r"package = [A-F0-9]{24} /\* XCLocalSwiftPackageReference", text):
        print("package 引用已在 pbxproj 里")
        raise SystemExit(0)
    raise SystemExit("没找到 XCSwiftPackageProductDependency PanSheet")
old = dep.group(0)
new = old.replace(
    "isa = XCSwiftPackageProductDependency;\n\t\t\tproductName = PanSheet;",
    f"isa = XCSwiftPackageProductDependency;\n\t\t\tpackage = {ref.group(1)} /* XCLocalSwiftPackageReference \"..\" */;\n\t\t\tproductName = PanSheet;",
)
p.write_text(text.replace(old, new, 1))
print(f"已绑定 product PanSheet -> local package {ref.group(1)}")
PY
