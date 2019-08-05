{
  if (substr($0,1,4) == "    ")
    print substr($0,4);
  else
  { 
    match($0,"overpass-turbo\\.eu[^ )]*&Q=");
    if (RSTART > 0)
      print "";
  }
}
