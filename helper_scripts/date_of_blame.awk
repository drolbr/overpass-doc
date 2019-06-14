BEGIN {
  lastref = "--";
  latest = "00";
}
{
  match($0,"<a name=\"[^\"]*\"/>");
  if (RSTART > 0)
  {
    print latest"\t"lastref;
    lastref = substr($0,RSTART+9,RLENGTH-12);
    latest = "00";
  }
  else
  {
    match($0," 20..-..-.. ");
    date = substr($0,RSTART+1,RLENGTH-2);
    if (date > latest)
      latest = date;
  }
}
END {
  print latest"\t"lastref;
}