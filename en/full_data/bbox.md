Bounding Boxes
==============

The simplest way to obtain OpenStreetMap data from a small region.

<a name="filter"/>
## Filter a Query

The simplest way to get all data from a bounding box
is to explicitly state so [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    nwr(51.477,-0.001,51.478,0.001);
    out;

Here `(51.477,-0.001,51.478,0.001)` represents the bounding box.
The order of the edges is always the same:

* `51.477` is the _latitude_ of the southern edge.
* `-0.001` is the _longitude_ of the western edge.
* `51.478` is the _latitude_ of the norther edge.
* `0.001` is the _longitude_ of the eastern edge.

The Overpass API only uses the decimal fraction notation,
a notation in minutes and seconds is not supported.

The value of the southern edge must be always smaller than the value of the northern edge,
because the values for degree of latitude are growing from the south pole to the north pole,
from -90.0 to +90.0.

In contrast to this, the values for degree of longitude are growing from west to east almost everywhere.
But at the antimeridian the values jumps from +180.0 to -180.0.
The antimeridian crosses on its way from the north pole to the south pole the pacific and not much else.
Thus, in almost all cases the value of the western edge is smaller than the value of the eastern edge,
unless one really wants to span a bounding box across the antimeridian.

It usually is tedious
to manually figure out the bounding box.
For this reason, almost all of the at [Downstream Tools](../targets/index.md) listed tools have convenience features for this.
In [Overpass Turbo](../targets/turbo.md#convenience) and also [JOSM](../targets/index.md),
the substring `{{bbox}}` is replaced by the bounding box of the viewport.
Thus, one can work with a generalized query like [this](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    nwr({{bbox}});
    out;

The query then always is executed in the then current visible bounding box.

Please note that some of the elements are presented as dashed.
This is a telltale sign of a bigger phenomenon,
and we will pursue that further [in the next section](osm_types.md):
The objects in question have been completely delivered with regard to their syntactic structure,
but they have incomplete geometry because we implicitly specified so in this query.

<a name="crop"/>
## Crop Output

<!--
Eine zweite Situation, in der Bounding-Boxen vorkommen,
ist bei der Ausgabebegrenzung mit ``out geom``.
Möchte man einen _Way_ oder eine _Relation_ auf der Karte visualisieren,
so muss die Overpass API [explizit anweisen](../targets/formats.md#extras),
das Objekt entgegen der OSM-Konventionen mit Koordinaten auszustatten.

Im Falle von Relationen kann dies zu großen Datenmengen führen.
So wird in [diesem Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=relation%2851%2E477%2C%2D0%2E001%2C51%2E478%2C0%2E001%29%3B%0Aout%20geom%3B) ungefragt Geometrie quer durch England ausgeliefert,
obwohl nur ein paar hundert Quadratmeter im Fokus gewesen sind:

    relation(51.477,-0.001,51.478,0.001);
    out geom;

Die Datenmenge kann eingeschränkt werden,
indem bei der Ausgabe [explizit](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=relation%2851%2E477%2C%2D0%2E001%2C51%2E478%2C0%2E001%29%3B%0Aout%20geom%2851%2E47%2C%2D0%2E01%2C51%2E49%2C0%2E01%29%3B) nur Koordinaten aus einer übergebenen Bounding-Box angefordert werden:

    relation(51.477,-0.001,51.478,0.001);
    out geom(51.47,-0.01,51.49,0.01);

Die Bounding-Box wird direkt hinter ``geom`` notiert.
Sie kann sowohl gleich als auch verschieden von Bounding-Boxen aus vorangehenden Statements sein.
In diesem Fall haben wir uns durch verschiedene Bounding-Boxen zu einem sehr breiten Reserverand entschieden.

Zu einzeln vorkommenden _Nodes_ werden dabei die Koordinaten genau dann mitgeliefert,
wenn diese innerhalb der Bounding-Box liegen.

Bei _Ways_ nicht nur die Koordinaten aller _Nodes_ in der Bounding-Box mitgeliefert,
sondern auch die jeweils nächste und vorausgehende Koordinate,
auch wenn sie bereits außerhalb der Bounding-Box liegt.
Um dies [im Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=18&Q=way%5Bname%3D%22Blackheath%20Avenue%22%5D%2851%2E477%2C%2D0%2E001%2C51%2E478%2C0%2E001%29%3B%0Aout%20geom%2851%2E477%2C%2D0%2E002%2C51%2E479%2C0%2E002%29%3B) zu sehen, bitte nach dem Ausführen auf _Daten_ oben rechts klicken;
Herumschieben der Karte zeigt auch, wo abgeschnitten worden ist:

    way[name="Blackheath Avenue"](51.477,-0.001,51.478,0.001);
    out geom(51.477,-0.002,51.479,0.002);

Nur ein Teil der _Nodes_ im _Way_ hat hier Koordinaten.

Die mit Koordinaten versehenen Abschnitte des Ways [können unzusammenhängend](https://overpass-turbo.eu/?lat=51.4735&lon=-0.007&zoom=17&Q=way%5Bname%3D%22Hyde%20Vale%22%5D%3B%0Aout%20geom%2851%2E472%2C%2D0%2E009%2C51%2E475%2C%2D0%2E005%29%3B) sein,
auch bei einem einzelnen Way:

    way[name="Hyde Vale"];
    out geom(51.472,-0.009,51.475,-0.005);

Es reicht dazu eine mäßige Kurve aus der Bounding-Box und wieder hinein wie in diesem Beispiel.

Bei _Relations_ werden _Ways_ mit allen ihren _Nodes_ expandiert,
wenn zumindest eine der _Nodes_ dieses Ways innerhalb der Bounding-Box liegt.
Andere _Ways_ werden nicht expandiert.
Innerhalb dieser _Ways_ werden wie bei einzelnen _Ways_ die _Nodes_ innerhalb der Bounding Box plus eine Extra-_Node_ mit Koordinaten versehen.

Ebenso wie bei der Bounding-Box als Filter haben die meisten Programme einen Mechanismus,
um die Bounding Box selbsttätig einzufügen.
Bei [Overpass Turbo](../targets/turbo.md#convenience) tut dies wie oben ``{{bbox}}``, [(Beispiel)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=relation%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%28%7B%7Bbbox%7D%7D%29%3B):

    relation({{bbox}});
    out geom({{bbox}});
-->

<a name="global"/>
## Filter Globally

...
