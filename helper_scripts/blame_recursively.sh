#!/usr/bin/env bash

SOURCE="$1"
SCRIPT_DIR=`dirname $0`

echo "$1"
git blame "$1" | awk -f "$SCRIPT_DIR/date_of_blame.awk"

for I in $(cat <$1 | grep -E '^\[LINK_STUB\]\(' | awk '{ print substr($0,13,length($0)-13); }'); do
  if [[ -n $I ]]; then
    $0 "$(dirname $1)/$I"
  fi
done
