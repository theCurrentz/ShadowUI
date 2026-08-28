#!/usr/bin/env bash
set -euo pipefail

# Copy Macro Cursor "Export cache" files onto Era or TBC WTF.
# Refuses to write while World of Warcraft Classic is open.

wow_version="${WOW_VERSION:-ERA}"
wow_root="${WOW_CLASSIC_ERA:-/Applications/World of Warcraft/_classic_era_}"
if [[ "${wow_version}" == "TBC" ]]; then
  wow_root="${WOW_TBC:-${WOW_ANNIVERSARY:-/Applications/World of Warcraft/_anniversary_}}"
fi
account="${WOW_ACCOUNT:-WARKEYS}"
realm="${WOW_REALM:-Nightslayer}"
character="${WOW_CHAR:-Tazzy}"
downloads="${WOW_DOWNLOADS:-$HOME/Downloads}"
dry_run=0

usage() {
  cat <<'EOF'
Copy Macro Cursor Export cache files onto Era or TBC WTF.

Usage:
  scripts/apply-macro-cache.sh [--dry-run] [FILE ...]

With no FILE, uses the newest macros-cache-account*.txt and
macros-cache-character*.txt in ~/Downloads.

Each FILE is General (account) or character from the name or the VER 3 id.

Env:
  WOW_VERSION      ERA (default) or TBC
  WOW_CLASSIC_ERA  Era client root (default: /Applications/World of Warcraft/_classic_era_)
  WOW_TBC          TBC client root (default: /Applications/World of Warcraft/_anniversary_)
  WOW_ANNIVERSARY  alias for WOW_TBC
  WOW_ACCOUNT      account folder (default: WARKEYS)
  WOW_REALM        realm folder (default: Nightslayer)
  WOW_CHAR         character folder (default: Tazzy)
  WOW_DOWNLOADS    export folder (default: ~/Downloads)

Exits without write if World of Warcraft Classic is open.
EOF
}

wow_is_open() {
  pgrep -fi "World of Warcraft Classic" >/dev/null 2>&1
}

tab_of() {
  local file="$1" base id
  base="$(basename "$file")"
  case "$base" in
    *character*) echo character; return ;;
    *account*) echo account; return ;;
  esac
  id="$(grep -m1 -E '^VER[[:space:]]+[0-9]+[[:space:]]+' "$file" | awk '{print $3}' || true)"
  case "$id" in
    01000000*) echo character ;;
    00000000*) echo account ;;
    *)
      echo "Cannot tell General vs character from $file" >&2
      return 1
      ;;
  esac
}

newest() {
  local prefix="$1" newest="" candidate
  shopt -s nullglob
  for candidate in "$downloads/${prefix}"*.txt; do
    if [[ -f "$candidate" && ( -z "$newest" || "$candidate" -nt "$newest" ) ]]; then
      newest="$candidate"
    fi
  done
  shopt -u nullglob
  printf '%s' "$newest"
}

validate() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Missing export: $file" >&2
    return 1
  fi
  if [[ ! -s "$file" ]]; then
    return 0
  fi
  if ! grep -q -E '^VER[[:space:]]+[0-9]+[[:space:]]+' "$file"; then
    echo "Not a macros-cache export: $file" >&2
    return 1
  fi
}

apply_one() {
  local src="$1" tab dest dir
  tab="$(tab_of "$src")"
  validate "$src"
  if [[ "$tab" == account ]]; then
    dest="$wow_root/WTF/Account/$account/macros-cache.txt"
  else
    dest="$wow_root/WTF/Account/$account/$realm/$character/macros-cache.txt"
  fi
  dir="$(dirname "$dest")"
  if [[ ! -d "$dir" ]]; then
    echo "Missing WTF folder: $dir" >&2
    return 1
  fi
  echo "$tab: $src -> $dest"
  if (( dry_run )); then
    return 0
  fi
  if [[ -f "$dest" ]]; then
    cp "$dest" "$dest.bak"
  fi
  cp "$src" "$dest"
}

files=()
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      dry_run=1
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 1
      ;;
    *)
      files+=("$arg")
      ;;
  esac
done

if ((${#files[@]} == 0)); then
  account_export="$(newest macros-cache-account)"
  character_export="$(newest macros-cache-character)"
  if [[ -n "$account_export" ]]; then
    files+=("$account_export")
  fi
  if [[ -n "$character_export" ]]; then
    files+=("$character_export")
  fi
fi

if ((${#files[@]} == 0)); then
  echo "No export files. Pass a path or Export cache into $downloads." >&2
  exit 1
fi

if wow_is_open; then
  echo "World of Warcraft Classic is open. Close it, then run this script." >&2
  if (( ! dry_run )); then
    exit 1
  fi
  echo "Dry run continues. A real run would refuse." >&2
fi

for file in "${files[@]}"; do
  apply_one "$file"
done

if (( dry_run )); then
  echo "Dry run. No files written."
else
  echo "Done. Login after the client reads the new cache."
fi
