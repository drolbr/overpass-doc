{
  if (in_pre)
  {
    if ($0 == "</code></pre>")
    {
      in_pre = 0;
      print "</pre>";
    }
    else
      print "<codeline>"$0"</codeline>";
  }
  else
  {
    if (substr($0,1,11) == "<pre><code>")
    {
      in_pre = 1;
      print "<pre>";
      print "<codeline>"substr($0,12)"</codeline>";
    }
    else
      print;
  }
}