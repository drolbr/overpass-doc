#!/usr/bin/env bash

SOURCE="$1"
TARGET="$2/"`dirname "$1"`/`basename "$1" .md`.html
SCRIPT_DIR=`dirname $0`
TITLE=`cat <$1 | awk '{ if (substr($1,1,3) == "===") print last; last = $0; }'`

DIRPREFIX=
if [[ `basename "$1"` == "index.md" ]]; then
  DIRPREFIX="../"
  if [[ $(dirname $1) == "de" ]]; then
    declare -x TR_PREVIOUS="zurück"
    declare -x TR_NEXT="weiter"
  elif [[ $(dirname $1) == "en" ]]; then
    declare -x TR_PREVIOUS="prev"
    declare -x TR_NEXT="next"
  elif [[ $(dirname $1) == "fr" ]]; then
    declare -x TR_PREVIOUS="arrière"
    declare -x TR_NEXT="prochaine"
  elif [[ -z $TR_PREVIOUS || -z $TR_NEXT ]]; then
    declare -x TR_PREVIOUS="-1"
    declare -x TR_NEXT="+1"
  fi
fi
if [[ -n $3 ]]; then
  PRED_PAGE="$3"
  PRED_FILE=$(dirname "$1")"/${DIRPREFIX}$PRED_PAGE"
  PRED_TITLE=$(cat <"$PRED_FILE" | awk '{ if (substr($1,1,3) == "===") print last; last = $0; }')
fi
if [[ -n $4 ]]; then
  SUCC_PAGE="$4"
  SUCC_FILE=$(dirname "$1")"/${DIRPREFIX}$SUCC_PAGE"
  SUCC_TITLE=$(cat <"$SUCC_FILE" | awk '{ if (substr($1,1,3) == "===") print last; last = $0; }')
fi
if [[ -n $5 ]]; then
  PARENT="$5"
fi

mkdir -p $(dirname $TARGET)

echo '<?xml version="1.0" encoding="UTF-8"?>' >$TARGET
echo '<html xmlns="http://www.w3.org/1999/xhtml">' >>$TARGET
echo '<head><meta charset="utf-8"/>' >>$TARGET
echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>' >>$TARGET
echo '<style>' >>$TARGET
echo 'pre { background-color:aquamarine; padding:0.5em; }' >>$TARGET
echo '</style>' >>$TARGET
echo '  <title>'$TITLE'</title>' >>$TARGET
echo '</head>' >>$TARGET
echo '<body style="font-family:sans-serif; max-width:30em">' >>$TARGET
echo >>$TARGET

{
  if [[ -n $PARENT ]]; then
    echo "x[$PARENT](${DIRPREFIX}index.md)  x"
  fi
  if [[ -n $PRED_PAGE ]]; then
    echo "x$TR_PREVIOUS: [$PRED_TITLE](${DIRPREFIX}$PRED_PAGE)  x"
  fi
  if [[ -n $SUCC_PAGE ]]; then
    echo "x$TR_NEXT: [$SUCC_TITLE](${DIRPREFIX}$SUCC_PAGE)  x"
  fi
  if [[ -n $PARENT || -n $PRED_PAGE || -n $SUCC_PAGE ]]; then
    echo 'xx'
    echo 'x---x'
    echo 'xx'
  fi
  cat <$1 | sed 's/^/x/g' | sed 's/$/x/g';
} | while read LINE
do
  if [[ ${LINE:1:2} == "((" ]]; then
    INCLUDE=${LINE:3:$((${#LINE}-6))} 
    { echo "$INCLUDE"; cat "$(dirname $1)/$INCLUDE"; } | awk -f "$SCRIPT_DIR/explain_link.awk"
  else
    echo "${LINE:1:$((${#LINE}-2))}"
  fi
done | sed 's/\.md\b/\.html/g' | markdown | sed 's/href=\"https:/target=\"_blank\" rel=\"noopener\" href=\"https:/g' >>$TARGET

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
