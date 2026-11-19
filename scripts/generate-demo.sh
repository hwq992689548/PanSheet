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

# 绑定 product -> XCLocalSwiftPackageReference，否则 Xcode GUI 报 Missing package product。
ref = re.search(
    r"([A-F0-9]{24}) /\* XCLocalSwiftPackageReference \"\.\.\" \*/ = \{\n\t\t\tisa = XCLocalSwiftPackageReference;",
    text,
)
if not ref:
    raise SystemExit("没找到 XCLocalSwiftPackageReference ..")
ref_id = ref.group(1)

dep = re.search(
    r"([A-F0-9]{24}) /\* PanSheet \*/ = \{\n\t\t\tisa = XCSwiftPackageProductDependency;\n(?:\t\t\tpackage = [A-F0-9]{24} /\* XCLocalSwiftPackageReference \"\.\.\" \*/;\n)?\t\t\tproductName = PanSheet;",
    text,
)
if not dep:
    raise SystemExit("没找到 XCSwiftPackageProductDependency PanSheet")
if "package = " not in dep.group(0):
    old = dep.group(0)
    new = old.replace(
        "isa = XCSwiftPackageProductDependency;\n\t\t\tproductName = PanSheet;",
        "isa = XCSwiftPackageProductDependency;\n"
        f"\t\t\tpackage = {ref_id} /* XCLocalSwiftPackageReference \"..\" */;\n"
        "\t\t\tproductName = PanSheet;",
    )
    text = text.replace(old, new, 1)

# 去掉 Packages 组里指向仓库根 `..` 的文件夹引用，避免 Xcode 把仓库根当工程打开。
folder = re.search(
    r"\t\t([A-F0-9]{24}) /\* PanSheet \*/ = \{isa = PBXFileReference; lastKnownFileType = folder; name = PanSheet; path = \.\.; sourceTree = SOURCE_ROOT; \};\n",
    text,
)
if folder:
    folder_id = folder.group(1)
    text = text.replace(folder.group(0), "")
    text = text.replace(f"\t\t\t\t{folder_id} /* PanSheet */,\n", "")

p.write_text(text)
print(f"已绑定 product PanSheet -> local package {ref_id}")
PY
