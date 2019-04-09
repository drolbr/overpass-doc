#!/usr/bin/env bash

SOURCE="$1"
TARGET="$2/"`dirname "$1"`/`basename "$1" .md`.html
SCRIPT_DIR=`dirname $0`
TITLE=`cat <$1 | awk '{ if (substr($1,1,3) == "===") print last; last = $0; }'`

if [[ -n $5 ]]; then
  PARENT="$5"
fi

mkdir -p $(dirname $TARGET)

echo '<?xml version="1.0" encoding="UTF-8"?>' >$TARGET
echo '<html xmlns="http://www.w3.org/1999/xhtml">' >>$TARGET
echo '<head><meta charset="utf-8"/>' >>$TARGET
echo '  <title>'$TITLE'</title>' >>$TARGET
echo '</head>' >>$TARGET
echo '<body>' >>$TARGET
echo >>$TARGET

{
  if [[ -n $PARENT ]]; then
    if [[ `basename "$1"` == "index.md" ]]; then
      echo "[$PARENT](../index.md)  x"
    else
      echo "[$PARENT](index.md)  x"
    fi
  fi
  cat <$1 | sed 's/$/x/g';
} | while read LINE
do
  if [[ ${LINE:0:2} == "((" ]]; then
    INCLUDE=${LINE:2:$((${#LINE}-5))} 
    { echo "$INCLUDE"; cat "$(dirname $1)/$INCLUDE"; } | awk -f "$SCRIPT_DIR/explain_link.awk"
  else
    echo "${LINE:0:$((${#LINE}-1))}"
  fi
done | sed 's/\.md\b/\.html/g' | markdown >>$TARGET

echo >>$TARGET
echo '</body>' >>$TARGET
echo '</html>' >>$TARGET

LAST=
LASTBUTONE=
for I in $(cat <$1 | grep -E '^\(\(' | awk '{ print substr($0,3,length($0)-4); }'); do
  if [[ -n $LAST ]]; then
    $0 "$(dirname $1)/$LAST" "$2" "$LASTBUTONE" "$I" "$TITLE"
  fi
  LASTBUTONE="$LAST"
  LAST="$I"
done
if [[ -n $LAST ]]; then
  $0 "$(dirname $1)/$LAST" "$2" "$LASTBUTONE" "" "$TITLE"
fi
