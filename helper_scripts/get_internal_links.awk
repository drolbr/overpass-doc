{
  if (base_dir == "" || base_name == "")
  {
    base_dir = substr($0,1,index($0,"/")-1);
    base_name = substr($0,index($0,"/")+1);
  }

  match($0,"\\]\\(");
  if (RSTART > 0 && substr($0,RSTART+2,6) != "https:" && substr($0,1,4) != "    " && (index($0,"``") == 0 || index($0,"``") > RSTART))
  {
    link = substr($0,RSTART+2);
    link = substr(link,1,index(link,")")-1);
    if (substr(link,1,3) == "../")
      print substr(link,4);
    else if (substr(link,1,1) != "#")
      print base_dir"/"link;
    else
      print base_dir"/"base_name link;
  }
}
