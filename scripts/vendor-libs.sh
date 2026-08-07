#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
libs_dir="$root_dir/libs"
temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/shadowui-libs.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT

ace3_source="https://github.com/WoWUIDev/Ace3.git"
lab_source="https://repos.wowace.com/wow/libactionbutton-1-0"
ace3_libraries=(
  LibStub
  CallbackHandler-1.0
  AceAddon-3.0
  AceEvent-3.0
  AceDB-3.0
  AceDBOptions-3.0
  AceConsole-3.0
  AceGUI-3.0
  AceConfig-3.0
)

git clone --depth 1 "$ace3_source" "$temp_dir/Ace3"
git clone --depth 1 "$lab_source" "$temp_dir/LibActionButton-1.0"

mkdir -p "$libs_dir"
for library in "${ace3_libraries[@]}"; do
  rm -rf "$libs_dir/$library"
  cp -R "$temp_dir/Ace3/$library" "$libs_dir/$library"
done

rm -rf "$libs_dir/LibActionButton-1.0"
mkdir -p "$libs_dir/LibActionButton-1.0"
cp "$temp_dir/LibActionButton-1.0/LibActionButton-1.0.lua" "$libs_dir/LibActionButton-1.0/"
