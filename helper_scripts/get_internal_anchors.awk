{
  if (substr($0,1,8) == "<a name=")
    target = substr($0,10,length($0)-12);
  else if (target != "" && substr($0,1,3) == "## ")
  {
    print "#"target" "substr($0,4);
    target = "";
  }
}
