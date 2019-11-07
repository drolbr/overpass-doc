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

The [documentation of Overpass Turbo](https://wiki.openstreetmap.org/wiki/Overpass_turbo) already explains the colours.
We put our attention rather to the interaction here:
For a given object or type of object you have an idea
whether it is a point, a line, a composition of both, something abstract or something with a fuzzy boundary.
In the OpenStreetMap data structures it is modeled in some way;
this can meet or differ from your expectation.

The Overpass API offers [tools](formats.md#extras)
to change from the OpenStreetMap representation to a representation
that better fits the presentation.
This can happen by amending the coordinates, geometric simplification, or [by cropping](../full_data/bbox.md#crop).
Overpass Turbo strives to always present in the best possible way,
no matter whether the representation in OpenStreetMap makes sense,
and also no matter whether the output format chosen in the request fits to the data or not.

This section shall explain
what presentation finally the given situation results in
and how this is influenced by the request and the data.

Objects appearing as points can have a yellow or a red interior.
Those with yellow interior are _nodes_
while those with red interior are _ways_.

Ways can be morphed to points due to their small extent
because otherwise they may become too unremarkable:
Please zoom out in [this example](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=CGI_STUB)
and observe how buildings and streets morph into points!

    ( way({{bbox}})[building];
      way({{bbox}})[highway=steps]; );
    out geom;

If this hampers the presentation of a specific result,
then you can turn that off at _Settings_, _Map_, _Don't display small features as POIs_.
The setting comes into effect with the execution of the next request (or the same request again).

Or the objects have been collapsed because [the request](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=CGI_STUB) has asked only for points by `out center`:

    way({{bbox}})[building];
    out center;

Point objects can have a blue or a purple border;
and this applies also to line segments or areas.
In all these cases, _relations_ are [involved](https://overpass-turbo.eu/?lat=51.5045&lon=-0.0195&zoom=16&Q=CGI_STUB):

    rel[name="Canary Wharf"];
    out geom;

Opposed to _nodes_ or _ways_, the details of the _relation_ then are not shown by a click on the object,
but in the object's bubble there is just a link to the relation's presentation on the main server.
Under normal circumstances, this is no problem.

But if you have asked for a museum version different from the current version,
then the data from the main page is still the current version
and thus differs from the data returned from your request.
Rather, you need to look into the raw data shown in the tab _Data_.

If the line or boundary of the area is dashed,
then the geometry of the object is incomplete.
This is almost always an intended effect of the [output clipping](../full_data/bbox.md#crop) ([example](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=16&Q=CGI_STUB)):

    (
      way(51.475,-0.002,51.478,0.003)[highway=unclassified];
      rel(bw);
    );
    out geom(51.475,-0.002,51.478,0.003);

But it can also be the effect of a request
that has added for a _way_ some but not all _nodes_.
Here we have loaded _ways_ based on _nodes_,
but we have [forgotten](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB)
to ask for the nodes referred by the ways but outside the bounding box:

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out;

The request [can be fixed](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB) by `out geom`;
more possibilities are listed in the section about [geometry](../full_data/osm_types.md#nodes_ways):

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out geom;

<a name="convenience"/>
## Convenience

<!-- Not yet checked -->

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
