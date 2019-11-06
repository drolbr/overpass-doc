Overpass Turbo
==============

The standard tool to develop requests.

<a name="overview"/>
## Overview

Overpass Turbo is a website
to execute requests towards Overpass API
and to watch the result on a map.

Many examples in this manual link to Overpass Turbo with a predefined request text.

A public instance is available at [https://overpass-turbo.eu](https://overpass-turbo.eu).
It is, like Overpass API, open source,
and the source code is available from [Github](https://github.com/tyrasd/overpass-turbo).
Martin Raifer has developed Overpass Turbo,
and I'm grateful to him both for the idea and the software.

Almost all output formats
that the Overpass API can emit
can be understood by Overpass Turbo.
Very large result sets cause difficulties;
the JavaScript engines even of contemporary browsers then get strained in their memory management.
For this reason, Overpass Turbo will ask you
if it has received a large set of results
if you accept the risk to freeze your browser by the amount of data.

There are many popular and helpful features in Overpass Turbo,
but they exceed the mission of this manual.
Instead, the proper [documentation of Overpass Turbo](https://wiki.openstreetmap.org/wiki/Overpass_turbo) introduces them.
Features not introduced here include e.g. _styles_ and the request generator _wizard_.
This manual concentrates on the immediate interaction between Overpass Turbo and the Overpass query language.

<a name="basics"/>
## Basics

The interface of the website consists of multiple parts;
these parts are differently arranged between desktop and mobile site version.
Please open [the site](https://overpass-turbo.eu) now in a separated browser tab.

In the desktop version there is on the left a large text field;
please type or paste your request here.
The right part is a slippy map.
By the two tabs in the upper right corner
this part can be switched between the map view and a text field showing the received raw data.

In the mobile version the text field sits above the slippy map.
The second text field for the received raw data is below the slippy map.
Instead of the tabs you switch between the two parts by intense scrolling.

We exercise the standard use case:
Please enter into the text field ...

    nwr[name="Canary Wharf"];
    out geom;

... or use [this link](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=18&Q=CGI_STUB)!

Please click now on _Execute_.
For a short moment a progress meter asks you to be patient.
Then you see almost exactly the same as before.

Please click now on the magnifier.
This is on the left brim of the slippy map the third symbol counted from the top,
below the plus and minus buttons.
The slippy map moves to the center of the results and the finest possible resolution
such that still all results fit into the viewport.

The objects marked in the map view are now exactly the objects that the request has found.

It is often useful to view the raw returned data.
It gets shown when you click on the tab _Data_ above the upper right corner of the map view
respectively with scrolling in the mobile version.

Meanwhile, all on the map highlighted objects are clickable
and show on click, depending on the degree of detail of the request,
their id, their tags, and their metadata.

Eventually you will get the warning
that not for all objects the geometry has been delivered.
Then you can try out the automatic completion of the request.
Or you replace all `out` in the request by their counterparts with geometry `out geom`.

If you anticipate a large result
or if you want to process the result anyway with a different tool than Overpass Turbo
then you can directly export the data without an attempt to display them:
Please go to _Export_, keep in the tab _Data_,
and select `raw data directly from Overpass API`.
For long running requests it is normal
that apparently nothing happens after the click to trigger the request.

I suggest you to put attention to two useful features:

* In the lower right corner of the map view
  a counter shows how many objects of each type have been returned in the last request.
* In the upper left corner there is a search input field.
  Although it is less powerful than [Nominatim on openstreetmap.org](../criteria/nominatim.md),
  it is usually good enough for the names of towns to place the slippy map at the right location.

<a name="symbols"/>
## Symbols

<!-- Not yet checked -->

<!--
Die [Dokumentation](https://wiki.openstreetmap.org/wiki/DE:Overpass_turbo) erläutert die Farben bereits.
Wir konzentrieren uns hier daher eher auf das Zusammenspiel:
Zu einem konkreten Objekt oder Objektart haben Sie eine Vorstellung,
ob es ein Punkt, Linie, Fläche, eine Zusammensetzung davon, etwas Abstraktes oder etwas mit unscharfen Grenzen ist.
In den OpenStreetMap-Datenstrukturen ist es auf irgendeine Weise modelliert;
diese kann, aber muss nicht zwingend mit ihrer Erwartung übereinstimmen.

Die Overpass API bietet [Hilfsmittel](formats.md#extras),
um von der OpenStreetMap-Modellierung zu einer zu wechseln,
die besser zur Darstellung passt;
sei es durch Beschaffen der Koordinaten oder auch geometrische Vereinfachung oder [Zuschnitt](../full_data/bbox.md#crop).
Overpass Turbo muss nun in jedem Fall eine möglichst gute Darstellung liefern,
egal, ob die Modellierung in OpenStreetMap noch naheliegend ist,
und egal, ob das in der Abfrage gewählte Ausgabeformat sinnvoll zu den Daten passt.

Dieser Abschnitt soll erläutern,
was dann final in der Kartendarstellung herauskommt
und wie dies mit der Abfrage und den Daten zusammenhängt.

Punktobjekte können ein gelbes oder rotes Inneres haben.
Mit gelbem Inneren sind es echte _Nodes_,
mit rotem Inneren sind es _Ways_.

Ways können entweder wegen ihrer geringen Länge zu Punkten werden,
da sie sonst zu unauffällig wären:
Zoomen Sie bitte in [diesem Beispiel](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=way%28%7B%7Bbbox%7D%7D%29%5Bbuilding%5D%3B%0Aout%20geom%3B) heraus
und beobachten, wie Gebäude und Straße zu Punkten werden!
-->

    way({{bbox}})[building];
    out geom;

<!--
Wenn das bei einer konkreten Abfrage stört,
können Sie es unter _Einstellungen_, _Karte_, _Kleine Features nicht wie POIs darstellen_ abschalten.

Oder sie können als Punkte dargestellt werden,
weil [die Abfrage](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=way%28%7B%7Bbbox%7D%7D%29%5Bbuilding%5D%3B%0Aout%20center%3B) per ``out center`` ausgegeben hat:
-->

    way({{bbox}})[building];
    out center;

<!--
Punktobjekte können ein blauen oder lilanen Rand haben;
das gilt auch für als Linienzug oder Fläche gezeichnete Objekte.
In allen solchen Fällen sind _Relations_ [beteiligt](https://overpass-turbo.eu/?lat=51.5045&lon=-0.0195&zoom=17&Q=rel%5Bname%3D%22Canary%20Wharf%22%5D%3B%0Aout%20geom%3B):
-->

    rel[name="Canary Wharf"];
    out geom;

<!--
Im Gegensatz zu _Nodes_ oder _Ways_ sind die Details der _Relation_ dann aber nicht per Klick aufs Objekt verfügbar,
sondern in der Blase gibt es nur einen Link auf die _Relation_ auf dem Hauptserver.
Unter gewöhnlichen Umständen ist dies kein Problem.

Hat man aber gezielt einen alten Versionsstand angefragt,
so sind die Daten von der Hauptseite andere als die per Overpass API bezogenen Daten.
Es führt dann kein Weg daran vorbei,
in die zurückgelieferten Daten selbst per Reiter _Daten_ hineinzuschauen.

Ist dagegen die Linie oder Umrandung der Fläche gestrichelt,
so ist die Geometrie des Objekts unvollständig.
Das ist zumeist ein gewollter Effekt der [Ausgabebegrenzung](../full_data/bbox.md#crop) ([Beispiel](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=16&Q=%28%0A%20%20way%2851%2E475%2C%2D0%2E002%2C51%2E478%2C0%2E003%29%5Bhighway%3Dunclassified%5D%3B%0A%20%20rel%28bw%29%3B%0A%29%3B%0Aout%20geom%2851%2E475%2C%2D0%2E002%2C51%2E478%2C0%2E003%29%3B)):
-->

    (
      way(51.475,-0.002,51.478,0.003)[highway=unclassified];
      rel(bw);
    );
    out geom(51.475,-0.002,51.478,0.003);

<!--
Es kann aber auch Folge einer Abfrage sein,
die zu _Ways_ einige, aber nicht alle _Nodes_ geladen hat.
Hier haben wir _Ways_ auf Basis von _Nodes_ geladen,
aber [vergessen](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=%28%0A%20%20node%2851%2E475%2C%2D0%2E003%2C51%2E478%2C0%2E003%29%3B%0A%20%20way%28bn%29%3B%0A%29%3B%0Aout%3B), die fehlenden Nodes direkt oder indirekt nachzuladen:
-->

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out;

<!--
Die Abfrage kann durch ``out geom`` [repariert](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=%28%0A%20%20node%2851%2E475%2C%2D0%2E003%2C51%2E478%2C0%2E003%29%3B%0A%20%20way%28bn%29%3B%0A%29%3B%0Aout%20geom%3B) werden;
mehr Möglichkeiten sind im Abschnitt zu [Geometrien](../full_data/osm_types.md#nodes_ways) erklärt:
-->

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out geom;

<a name="convenience"/>
## Convenience

<!--
Overpass Turbo bietet einige Komfortfunktionen.

Es kann die Bounding-Box des aktuellen Fensters automatisch in eine Query einfügen.
Dazu ersetzt Overpass Turbo jedes Vorkommen der Zeichenfolge ``{{bbox}}`` durch die vier Ränder,
so dass eine gültige Bounding-Box entsteht.

Man kann die übertragene Bounding-Box sogar sehen,
wenn man sie an einer anderen als der üblichen Stelle [einfügt](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=make%20Beispiel%20Infotext%3D%22Die%20aktuelle%20Bounding%2DBox%20ist%20%7B%7Bbbox%7D%7D%22%3B%0Aout%3B) (und nach dem Ausführen auf _Daten_ klickt):
-->

    make Beispiel Infotext="Die aktuelle Bounding-Box ist {{bbox}}";
    out;

<!--
Eine zweite nützliche Funktion verbirgt sich hinter der Schaltfläche _Teilen_ oben links.
Dies erzeugt einen Link,
unter dem sich dauerhaft die zu dem Zeitpunkt eingegebene Abfrage abrufen lässt.
Auch wenn jemand Drittes den Link aufruft und die Abfrage editiert,
dann bleibt trotzdem die originale Abfrage unter dem Link erhalten.

Es lässt sich ebenfalls auch per Checkbox die aktuelle Kartenansicht mitgeben.
Dies meint Zentrum der Ansicht und Zoomstufe,
d.h. auf verschieden großen Bildschirmen sind verschiedene Kartenausschnitte sichtbar.
-->

<a name="limitations"/>
## Limitations

<!--
Overpass Turbo beherrscht zwar nahezu alle Ausgabearten der Overpass API.
Es gibt aber dennoch ein paar Grenzen:

Pro Objekt-Id und -Typ zeigt Overpass Turbo nur ein Objekt an.
Daher lassen sich [Diffs](index.md) nicht sinnvoll mit Overpass Turbo anzeigen.

Overpass Turbo zeigt [GeoJSON](../targets/formats.md#json) direkt von der Overpass API nicht an.
Overpass Turbo bringt sein eigenes Konvertierungsmodul für GeoJSON mit,
und Martin hält die Benutzer-Verwirrung für zu groß,
wenn beide Mechanismen parallel im Einsatz sind.
Vorläufig muss für diesen Fall daher auf die experimentelle Instanz [https://olbricht.nrw/ovt/](https://olbricht.nrw/ovt/) verwiesen werden.
