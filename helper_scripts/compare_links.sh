#!/usr/bin/env bash

if [[ -z $1 ]]; then
  echo "Usage: $0 Language_Dir"
  exit 1
fi

TEMP_DIR=$(mktemp -d)

for j in preface targets full_data criteria counting analysis more_info; do
  for i in de/$j/*.md; do
    { echo $j"/"$(basename $i); cat <$i; } | awk -f helper_scripts/get_internal_links.awk;
  done
done | LC_ALL=C sort | uniq >"$TEMP_DIR/refs.log"

for j in preface targets full_data criteria counting analysis more_info; do
  for i in de/$j/*.md; do
    echo $j"/"$(basename $i); cat <$i | grep -E '^<a name=' | awk '{ print "'$j'/'$(basename $i)'#"substr($0,10,length($0)-12); }'
  done
done | LC_ALL=C sort | uniq >"$TEMP_DIR/anchors.log"

diff -y "$TEMP_DIR/refs.log" "$TEMP_DIR/anchors.log"

rm -Rf "$TEMP_DIR"
