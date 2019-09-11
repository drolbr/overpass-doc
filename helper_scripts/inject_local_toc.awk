{
  if (!mode)
  {
    if ($0 == "")
      mode = "seek_file";
    else if (index($0," ") > 0)
    {
      if (substr($0,1,1) == "#")
      {
        pos = index($0," ");
        toc_lines = toc_lines "<div type=\"subsection\"><a href=\""substr($0,1,pos-1)"\">"substr($0,pos+1)"</a></div>\n";
      }
      else
      {
        pos = index($0," ");
        if ($1 == "f")
        {
          external_nav = external_nav "<div type=\"sibling\"><strong>"substr($0,pos+1)"</strong></div>\n";
          succ_trigger = 1;
        }
        else if ($1 == "p")
        {
          parent_prefix = parent_suffix "<div type=\"parent\"><strong><a href=\"index.html\">"substr($0,pos+1)"</a></strong></div>\n";
          parent_suffix = "";
          succ_trigger = 1;
        }
        else if ($1 == "F")
        {
          parent_prefix = parent_suffix "<div type=\"parent\"><strong>"substr($0,pos+1)"</strong></div>\n";
          parent_suffix = "";
          succ_trigger = 2;
        }
        else if ($1 == "u")
        {
          rem = substr($0,pos+1);
          pos = index(rem," ");
          link = "<a href=\"../"substr(rem,1,pos-4)".html\">"substr(rem,pos+1)"</a>";
          parent_suffix = parent_suffix "<div type=\"parent\">" link "</div>\n";
          if (succ_trigger == 1)
          {
            succ_trigger = 0;
            succ = link;
          }
        }
        else
        {
          link = "<a href=\""substr($0,1,pos-4)".html\">"substr($0,pos+1)"</a>";
          external_nav = external_nav "<div type=\"sibling\">" link "</div>\n";
          if (succ_trigger > 0)
          {
            succ_trigger = 0;
            succ = link;
          }
        }
      }
    }
    else if (tr_h3 == "")
      tr_h3 = $0;
    else if (tr_succ == "")
      tr_succ = $0;
  }
  else
  {
    if (mode == "seek_file" && substr($0,1,3) == "<hr")
    {
      print "<nav>";
      print parent_prefix;
      print external_nav;
      print "</nav>";
      print parent_suffix;
      mode = "seek_toc";
    }
    if (mode == "seek_toc" && substr($0,1,11) == "<p><a name=")
    {
      print "<nav>";
      print "<h3>"tr_h3"</h3>";
      print "";
      print toc_lines;
      print "</nav>";
      print "";

      mode = "done";
    }
    print;
  }
}
END {
  if (succ != "")
  {
    print "<hr/>";
    print "<p>" tr_succ ": " succ "</p>";
  }
}