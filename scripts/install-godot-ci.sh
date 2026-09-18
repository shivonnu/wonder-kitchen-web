#!/usr/bin/env bash
# Download Godot 4.7.2 (linux) and install the committed threadless web export template.
set -euo pipefail

VERSION="${GODOT_VERSION:-4.7.2}"
RELEASE="${GODOT_RELEASE:-stable}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CACHE="${GODOT_CACHE_DIR:-$ROOT/.godot-ci}"
TEMPLATE_SRC="$ROOT/scripts/godot-export-templates/web_nothreads_release.zip"
EDITOR_URL="https://github.com/godotengine/godot/releases/download/${VERSION}-${RELEASE}/Godot_v${VERSION}-${RELEASE}_linux.x86_64.zip"

mkdir -p "$CACHE/bin"

if [[ ! -x "$CACHE/bin/godot" ]]; then
  echo "Downloading Godot ${VERSION}-${RELEASE}…"
  curl -L --fail --retry 5 --retry-delay 4 -o "$CACHE/godot.zip" "$EDITOR_URL"
  unzip -o "$CACHE/godot.zip" -d "$CACHE/bin"
  rm -f "$CACHE/godot.zip"
  editor_bin="$(find "$CACHE/bin" -maxdepth 1 -type f -name 'Godot_v*_linux.x86_64' | head -n 1)"
  if [[ -z "$editor_bin" ]]; then
    echo "Godot editor binary not found after unzip" >&2
    ls -la "$CACHE/bin" >&2
    exit 1
  fi
  mv "$editor_bin" "$CACHE/bin/godot"
  chmod +x "$CACHE/bin/godot"
fi

if [[ ! -f "$TEMPLATE_SRC" ]]; then
  echo "Missing web export template: $TEMPLATE_SRC" >&2
  exit 1
fi

template_home="$HOME/.local/share/godot/export_templates/${VERSION}.${RELEASE}"
mkdir -p "$template_home"
cp "$TEMPLATE_SRC" "$template_home/web_nothreads_release.zip"
echo "${VERSION}.${RELEASE}" > "$template_home/version.txt"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$CACHE/bin" >> "$GITHUB_PATH"
fi

"$CACHE/bin/godot" --version
echo "Installed web_nothreads_release.zip into $template_home"
