BEGIN {
  last = "0A";
}
{
  if ($2 >= "a" && $2 <= "z" || $2 >= "A" && $2 <= "Z" || $2 >= "0" && $2 <= "9")
    printf "%s",$2;
  else if ($1 == "0A" && last == "0A")
    print "";
  else if (($1 != "0A" || last != "") && ($1 != "20" || last != "0A"))
    printf "%s","%"$1;
  last = $1;
}
END {
  print "";
}
