{
  if (!body)
  {
    if ($0 == "")
      body = 1;
    else
      example[i] = substr($0,1,length($0)-3); ++i;
  }
  else
  {
    match($0,"overpass-turbo\\.eu[^ )]*&Q=CGI_STUB");
    if (RSTART > 0)
    {
      print substr($0,1,RSTART+RLENGTH-9) example[j] substr($0,RSTART+RLENGTH);
      ++j;
    }
    else
    {
      if ($0 == "<!-- NO_QL_LINK -->")
        ++j;
      print;
    }
  }
}
