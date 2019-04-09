#!/usr/bin/env bash

SOURCE="$1"
TARGET="$2/"`dirname "$1"`/`basename "$1" .md`.html

echo '<?xml version="1.0" encoding="UTF-8"?>' >$TARGET
echo '<html xmlns="http://www.w3.org/1999/xhtml">' >>$TARGET
echo '<head><meta charset="utf-8"/>' >>$TARGET
echo '  <title>'`cat <$1 | awk '{ if (substr($1,1,3) == "===") print last; last = $0; }'`'</title>' >>$TARGET
echo '</head>' >>$TARGET
echo '<body>' >>$TARGET
echo >>$TARGET

cat <$1 | sed 's/\.md\b/\.html/g' | markdown >>$TARGET

echo >>$TARGET
echo '</body>' >>$TARGET
echo '</html>' >>$TARGET

