{
  if (filename == "")
    filename = $0;
  if (header == "" && substr($0,1,3) == "===")
    header = last;
  else if (status < 2 && header != "")
  {
    if ($0 == "")
      ++status;
    else
    {
      status = 1;
      if (lead == "")
        lead = $0;
      else
        lead = lead"\n"$0;
    }
  }
  last = $0;
}
END {
  print "["header"]("filename")  ";
  print lead;
}
