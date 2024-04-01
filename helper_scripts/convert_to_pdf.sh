#!/usr/bin/env bash


count_headlines_down()
{
  echo
  cat <$1 | awk '{ if (inside) { if (substr($0,1,1) == "#") print "#"$0; else if (substr($0,1,8) != "<a name=") print; } else { if (headline == "") headline = $0; else { print "## "headline; inside = 1; } } }'
}

process_entire_directory()
{
  pushd $1
  {
    echo
    echo -n "# "
    head -n 1 index.md
    for i in `cat index.md | grep -E '^.LINK_STUB' | awk '{ print substr($0,13,length($0)-13); }'`; do
      count_headlines_down "$i"
    done
  } >>../_
  popd
}


rm -f _

process_entire_directory preface
process_entire_directory targets
process_entire_directory full_data
process_entire_directory criteria
process_entire_directory analysis
process_entire_directory more_info

cat _ | pandoc --toc --toc-depth=2 -N --from=markdown --output=test.pdf
