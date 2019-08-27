#!/usr/bin/env bash

HOST="$1"

process_dir()
{
  for i in "$1"/*; do
    if [[ -d "$i" ]]; then
      process_dir "$i"
    elif [[ -f "$i" ]]; then
      echo -e "\
  <url>\n\
    <loc>$HOST/"$i"</loc>\n\
    <lastmod>$(date -r "$i" +%F)</lastmod>\n\
    <changefreq>monthly</changefreq>\n\
  </url>"
    fi
  done 
}

echo "Content-Type: application/xml; charset=utf-8"
echo
echo -e "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\"\n\
  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n\
  xsi:schemaLocation=\"http://www.sitemaps.org/schemas/sitemap/0.9\n\
      http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd\">\n\
\n\
  <url>\n\
    <loc>$HOST/</loc>\n\
    <lastmod>`date -r index.html +%F`</lastmod>\n\
    <changefreq>monthly</changefreq>\n\
  </url>"

for i in *; do
  process_dir "$i"
done

echo -e "\n\
</urlset>\n\
"

