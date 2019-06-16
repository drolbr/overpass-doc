Alternatives
============

L'Overpass API travaille toujours sur les données d'OpenStreetMap originales.
Souvent on veut plutôt une interprétation intelligente, par example du géocodage.
Le service _Nominatim_ et plusieurs autres services sont mieux adaptés à cette tâche que l'Overpass API.

<a name="nominatim"/>
## Nominatim

...
<!--
!-- [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim) --

!--
Es gibt aber genug Beispiele, bei denen schon der Name das richtige Objekt liefert ...

    nwr[name="Kölner Dom"];
    out geom;

... oder zumindest der Name zusammen mit einer Ortsangabe:

    area[name="Paris"];
    nwr[name="Tour Eiffel"](area);
    out geom;


...

[](https://overpass-turbo.eu/?lat=51.84&lon=12.23&zoom=12&Q=)

    nwr["addr:street"="Bauhausstraße"]
      ["addr:housenumber"="6"]
      ["addr:postcode"="06846"]
      ["addr:city"="Dessau-Roßlau"];
    out geom;
--
-->

<a name="taginfo"/>
## Taginfo

...
