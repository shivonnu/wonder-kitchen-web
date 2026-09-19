#!/usr/bin/env bash
# Export the Godot project to HTML5 (threadless) for GitHub Pages.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${EXPORT_DIR:-$ROOT/build/web}"
BASE_PATH="${BASE_PATH:-}"
GODOT_BIN="${GODOT_BIN:-godot}"

if [[ ! -x "$GODOT_BIN" ]] && ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "Godot binary not found: $GODOT_BIN" >&2
  exit 1
fi

if [[ -n "$BASE_PATH" && "$BASE_PATH" != "/" && "$BASE_PATH" != */ ]]; then
  BASE_PATH="${BASE_PATH}/"
fi

rm -rf "$OUT"
mkdir -p "$OUT"

echo "Importing Godot project…"
"$GODOT_BIN" --headless --path "$ROOT/godot" --import

echo "Exporting Web release to $OUT…"
"$GODOT_BIN" --headless --path "$ROOT/godot" --export-release Web "$OUT/index.html"

find "$OUT" -name '*.import' -delete
touch "$OUT/.nojekyll"

export OUT BASE_PATH
python3 - <<'PY'
from pathlib import Path
import os
import re

out = Path(os.environ["OUT"])
html_path = out / "index.html"
text = html_path.read_text(encoding="utf-8")
text = text.replace('lang="en"', 'lang="ja"', 1)
text = text.replace(
    '"ensureCrossOriginIsolationHeaders":true',
    '"ensureCrossOriginIsolationHeaders":false',
)
text = text.replace("use-filter--true", "use-filter--false")
text = text.replace("background-color: black;", "background-color: #0b1026;")
text = text.replace(
    "Your browser does not support the canvas tag.",
    "このブラウザではキャンバスを表示できません。",
)
text = text.replace(
    "Your browser does not support JavaScript.",
    "JavaScript を有効にすると、ほししおの台所を遊べます。",
)
text = re.sub(
    r'<meta name="viewport" content="[^"]*">',
    '<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, viewport-fit=cover">',
    text,
    count=1,
)
if "100dvh" not in text:
    text = text.replace(
        "html, body, #canvas {\n\tmargin: 0;\n\tpadding: 0;\n\tborder: 0;\n}",
        "html, body, #canvas {\n\tmargin: 0;\n\tpadding: 0;\n\tborder: 0;\n\twidth: 100%;\n\theight: 100%;\n}\n\n"
        "html, body {\n\tposition: fixed;\n\tinset: 0;\n\toverflow: hidden;\n\twidth: 100%;\n"
        "\theight: 100%;\n\theight: 100dvh;\n\twidth: 100dvw;\n}",
        1,
    )
    text = text.replace(
        "#canvas {\n\tdisplay: block;\n}",
        "#canvas {\n\tdisplay: block;\n\twidth: 100% !important;\n\theight: 100% !important;\n}",
        1,
    )
if "visualViewport" not in text:
    text = text.replace(
        "</body>",
        """<script>
(function () {
	function fitToPhoneScreen() {
		var vv = window.visualViewport;
		var w = vv ? vv.width : window.innerWidth;
		var h = vv ? vv.height : window.innerHeight;
		document.documentElement.style.width = w + "px";
		document.documentElement.style.height = h + "px";
		document.body.style.width = w + "px";
		document.body.style.height = h + "px";
	}
	fitToPhoneScreen();
	window.addEventListener("resize", fitToPhoneScreen);
	window.addEventListener("orientationchange", fitToPhoneScreen);
	if (window.visualViewport) {
		window.visualViewport.addEventListener("resize", fitToPhoneScreen);
		window.visualViewport.addEventListener("scroll", fitToPhoneScreen);
	}
})();
</script>
</body>""",
        1,
    )
base = os.environ.get("BASE_PATH", "")
if base and base != "/" and "<base " not in text:
    text = text.replace(
        '<meta charset="utf-8">',
        f'<meta charset="utf-8">\n\t\t<base href="{base}">',
        1,
    )
html_path.write_text(text, encoding="utf-8")

base_href = base if base and base != "/" else "./"
(out / "404.html").write_text(
    """<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="utf-8">
<title>ほししおの台所</title>
<meta http-equiv="refresh" content="0; url={base}">
<link rel="canonical" href="{base}">
<script>location.replace({base_js});</script>
</head>
<body>
<p><a href="{base}">ほししおの台所</a></p>
</body>
</html>
""".format(base=base_href, base_js=repr(base_href)),
    encoding="utf-8",
)
PY

required=(index.html index.js index.wasm index.pck index.png .nojekyll)
for name in "${required[@]}"; do
  if [[ ! -e "$OUT/$name" ]]; then
    echo "Export missing $OUT/$name" >&2
    ls -la "$OUT" >&2
    exit 1
  fi
done

if ! grep -q 'GODOT_THREADS_ENABLED = false' "$OUT/index.html"; then
  echo "Expected threadless HTML5 export" >&2
  exit 1
fi
if ! grep -q 'ensureCrossOriginIsolationHeaders":false' "$OUT/index.html"; then
  echo "Expected ensureCrossOriginIsolationHeaders=false for GitHub Pages" >&2
  exit 1
fi
if ! grep -q '100dvh' "$OUT/index.html"; then
  echo "Expected mobile visual-viewport CSS in HTML5 export" >&2
  exit 1
fi

echo "Web export ready: $OUT"
ls -lh "$OUT"

if [[ -d "$ROOT/public/art" ]]; then
  echo "Copying static art for leftover React sessions…"
  mkdir -p "$OUT/art"
  cp -a "$ROOT/public/art/." "$OUT/art/"
  cp "$ROOT/godot/assets/art/icon-milk.png" "$OUT/art/icon-milk.png"
  cp "$ROOT/godot/assets/art/moon-cave.png" "$OUT/art/moon-cave.png"
  cp "$ROOT/godot/assets/art/moon-well.png" "$OUT/art/moon-well.png"
fi
