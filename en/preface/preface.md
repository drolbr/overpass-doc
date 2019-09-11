OpenStreetMap and the Overpass API
==================================

How does the ecosystem of OpenStreetMap work?
Which role plays Overpass API there?

<a name="osm"/>
## What is OpenStreetMap?

OpenStreetMap primarily is a database of worldwide geographic data.
The data is geographic base data,
e.g. streets, roads, railways, waterways should be completely present,
but adding shops and restaurants with their names and opening hours also is highly appreciated.

In general, everything that is observable on the ground can be added to OpenStreetMap.
A street usually has a name sign, and a restaurant typically annouces its name as well.
For a river or a railway line, their names can almost always be read off sign refering to the respective features.

Some but rare exceptions to the requirement of being observable exist.
The only universally accepted exemption are bounadaries of countries, counties, and municipalities.

Personal data is never added to the database:
It is forbidden in OpenStreetMap
to copy names from bell plates to the database.

Being free from personal data restrictions and [license](https://wiki.osmfoundation.org/wiki/Licence) restrictions
allows to make the OpenStreetMap data downloadable in its entirety.
From that it is in principle possible to answer questions like

1. Where is city X, river Y, restaurant Z?
1. What is situated close to X or inside X?
1. How do I get as a pedestrian, a cyclist or by using a car from location X to location Y?

Also this data enables to draw a map of the world in many different ways.
To enable assessing the data,
in addition to the [sample map](https://openstreetmap.org) also a sample tool for _geocoding_ is operated.
It is called [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim),
answers question (1) from the last paragraph,
and it can in addition figure out for a given coordinate the most like postal address.
This is called _reverse geocoding_.
Tools to do _routing_ are accomodated on the [main site](https://openstreetmap.org/) as well.
These tools answer the question how to get from location X to location Y.

The database has an already challenging size
and every minute more updates and enhancements are performed by the mappers.
To download the data en bloc is impractical for that reason.
This is mitigated by making available in addition to the [complete database](https://planet.openstreetmap.org/) every minute a distinct file with the data changes having taken place that very minute.

<a name="overpass"/>
## What is Overpass API?

The Overpass API keeps a copy of the main database up to date with these minute updates
and provides them for search.
There exist not only [public instances](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances) to which a request can be send.
It is also possible to have your own instance because
Overpass API is [open source](https://github.com/drolbr/Overpass-API)
with easy installation and reasonable hardware requirements.

A good starting point is the frontend _Overpass Turbo_.
There, the results of a request appear immediately on a map.
As [an example](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=2&Q=nwr%5Bname%3D%22Sylt%22%5D%3B%0Aout%20center%3B) we search for everything that has the name _Sylt_:

    nwr[name="Sylt"];
    out center;

For this purpose, the text from above is put into the input field on the left hand side,
and then the reuqest is sent to Overpass API per click on the _Execute_ button.
The query language is versatile but also huge.
Thus this whole handbook aims at explaining the query language.

On fact, the Overpass API is designed to answer queries from other software over the internet.
It got the name [API](https://de.wikipedia.org/wiki/Programmierschnittstelle) for that reason.
For many popular downstream applications therefore their respective direct connection is explained in the chapter [Downstream Tools](../targets/index.md).
