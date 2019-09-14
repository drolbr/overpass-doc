#!/usr/bin/env bash

SOURCE="$1"
TARGET="$2/"$(dirname "$1")/$(basename "$1" .md).html
PARENT_AUX_TARGET="$2/"$(dirname "$1")/../index.aux
AUX_TARGET="$2/"$(dirname "$1")/index.aux
SCRIPT_DIR=$(dirname $0)
TITLE=$(cat <$1 | awk '{ if (substr($1,1,3) == "===") print last; last = $0; }')

DIRPREFIX="../"
if [[ -n $3 ]]; then
  PARENT="$3"
else
  PARENT="$TITLE"
  DIRPREFIX=

  if [[ $(dirname "$1") == "de" ]]; then
    declare -x TR_NEXT="weiter"
    declare -x TR_TOC="Inhalt"
  elif [[ $(dirname "$1") == "en" ]]; then
    declare -x TR_NEXT="next"
    declare -x TR_TOC="Content"
  elif [[ $(dirname "$1") == "fr" ]]; then
    declare -x TR_NEXT="prochaine"
    declare -x TR_TOC="Sommaire"
  elif [[ -z $TR_PREVIOUS || -z $TR_NEXT ]]; then
    declare -x TR_NEXT="+1"
    declare -x TR_TOC="[+]"
  fi
fi

mkdir -p $(dirname $TARGET)

if [[ $(basename "$1") == "index.md" ]]; then
  rm -f "$AUX_TARGET"
  for I in $(cat <$1 | grep -E '^\[LINK_STUB\]\(' | awk '{ print substr($0,13,length($0)-13); }'); do
    echo "$I $(cat <"$(dirname $1)/$I" | awk '{ if (substr($1,1,3) == "===") print last; last = $0; }')" >>$AUX_TARGET
  done
fi

echo '<?xml version="1.0" encoding="UTF-8"?>' >$TARGET
echo '<html xmlns="http://www.w3.org/1999/xhtml">' >>$TARGET
echo '<head><meta charset="utf-8"/>' >>$TARGET
echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>' >>$TARGET
echo '<style>' >>$TARGET
echo 'pre { background-color:#ccffff; padding: 0.5em; counter-reset: line; }' >>$TARGET
echo 'div[type=sibling] { text-indent:1em; }' >>$TARGET
echo 'codeline::before { counter-increment: line; content: counter(line)" "; color: #99cccc; }' >>$TARGET
echo '</style>' >>$TARGET
echo '  <title>'$TITLE'</title>' >>$TARGET
echo '</head>' >>$TARGET
echo '<body style="font-family:sans-serif; max-width:32em">' >>$TARGET
echo >>$TARGET

{
  if [[ -f $PARENT_AUX_TARGET ]]; then
    if [[ $(basename "$1") == "index.md" ]]; then
      cat <$PARENT_AUX_TARGET | awk '{ if ($1 == "'$(basename $(dirname "$1"))'/index.md") print "F"substr($0,index($0," ")); else print "u "$0; }'
    else
      cat <$PARENT_AUX_TARGET | awk '{ if ($1 == "'$(basename $(dirname "$1"))'/index.md") print "p"substr($0,index($0," ")); else print "u "$0; }'
    fi
  fi
  if [[ -f $AUX_TARGET ]]; then
    cat <$AUX_TARGET | awk '{ if ($1 == "'$(basename "$1")'") print "f "substr($0,index($0," ")); else print; }'
  fi
  echo "$TR_TOC"
  echo "$TR_NEXT"
  cat <$1 | awk -f "$SCRIPT_DIR/get_internal_anchors.awk";
  echo;
  {
    cat <$1 | awk -f "$SCRIPT_DIR/extract_code.awk" \
    | hexdump -v -e '/1 "%02X "' -e '/1 "%_p\n"' | awk -f "$SCRIPT_DIR/to_cgi.awk";
    echo;
    cat <$1;
  } | awk -f "$SCRIPT_DIR/include_example_links.awk" | {
    if [[ -n $PARENT ]]; then
      echo "x[$PARENT](${DIRPREFIX}index.md)  x"
    fi
    if [[ -n $PARENT ]]; then
      echo 'xx'
      echo 'x---x'
      echo 'xx'
    fi
    sed 's/^/x/g' | sed 's/$/x/g'
  } | while read LINE
  do
    if [[ ${LINE:1:12} == "[LINK_STUB](" ]]; then
      INCLUDE=${LINE:13:$((${#LINE}-15))} 
      { echo "$INCLUDE"; cat "$(dirname $1)/$INCLUDE"; } | awk -f "$SCRIPT_DIR/explain_link.awk"
    else
      echo "${LINE:1:$((${#LINE}-2))}"
    fi
  done \
    | sed 's/\([[][^:[]*\)\.md\b/\1\.html/g' \
    | markdown \
    | awk -f "$SCRIPT_DIR/tag_each_code_line.awk" \
    | sed 's/href=\"https:/target=\"_blank\" rel=\"noopener\" href=\"https:/g';
} | awk -f "$SCRIPT_DIR/inject_local_toc.awk" >>$TARGET

echo >>$TARGET
echo '</body>' >>$TARGET
echo '</html>' >>$TARGET

for I in $(cat <$1 | grep -E '^\[LINK_STUB\]\(' | awk '{ print substr($0,13,length($0)-13); }'); do
  $0 "$(dirname $1)/$I" "$2" "$PARENT"
done

if [[ $(basename "$1") == "index.md" ]]; then
  rm -f "$AUX_TARGET"
fi
