{
  if (substr($0,1,4) == "    ")
  {
    print substr($0,4);
    in_code = 1;
  }
  else
  { 
    if (in_code)
    {
      match($0,"[a-zA-Z0-9]");
      if (RSTART > 0)
      {
        print "";
        in_code = 0;
      }
    }
  }
}
