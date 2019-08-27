{
  if (!mode)
  {
    if ($0 == "")
      mode = "seek";
    else if (h3 == "")
      h3 = $0;
    else
    {
      pos = index($0," ");
      toc_lines = toc_lines "<div type=\"subsection\"><a href=\""substr($0,1,pos-1)"\">"substr($0,pos+1)"</a></div>\n";
    }
  }
  else
  {
    if (mode == "seek" && substr($0,1,11) == "<p><a name=")
    {
      print "<nav>";
      print "<h3>"h3"</h3>";
      print "";
      printf "%s",toc_lines;
      print "</nav>";
      print "";

      mode = "done";
    }
    print;
  }
}