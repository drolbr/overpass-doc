Geometries
==========

To explain the different variants of getting full OpenStreetMap data within a region
the fine print of the OpenStreetMap data model is explained here.

<a name="scope"/>
## Scope of this Section

The OpenStreetMap data types already have been introduced in [a subsection](../preface/osm_data_model.md) of the preface.
Thus, you already are familiar with nodes, ways, and relations.

OpenStreetMap data can be represented in different ways.
Output formats like JSON or XML are explained in the subsection [Data Formats](../targets/formats.md).
The range of possible levels of detail with regard to structure, geometry, tags, version information and attribution also are introduced there.

The issue at stake here is
how completing ways and relations equips them with a useful geometry
while keeping the total size manageable.

<a name="nodes_ways"/>
## Ways and Nodes

A usable geometry for nodes is easy to obtain:
All output modes except `out ids` and `out tags` include the coordinates of the nodes,
because they are anyway part of the nodes by the definition in the OpenStreetMap data model.

By contrast, ways already can be equipped with geometry in multiple ways:
In the best of all cases, your program can process coordinates on ways.
You can observe the difference e.g. in Overpass Turbo,
by comparing the results of the two following requests in the tab _Data_ (upper right corner):
[without coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out;


and [with coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out geom;

The original data model of OpenStreetMap does not admit coordinates on ways,
because the ways already have references to nodes.
Therefore, there still exist programs that cannot process coordinates on ways.
For those there exist two levels of faithfulness to deliver the geometry in the traditional way.

The least extra effort is due if one requests only coordinates of the nodes.
After the output statement of the ways, a statement `node(w)` selects the in the ways referred nodes;
the mode `out skel` reduces the amount of data to pure coordinates,
and the supplement `qt` eliminates the effort to sort the output:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out qt;
    node(w);
    out skel qt;

I suggest to inspect the output in the tab _Data_ (upper right corner).
The nodes appear after scrolling sufficiently far down.

This is already closer to the original data model,
but there are programs that still do not work with this form of data.
There is a practice to place all nodes before any ways and to sort the elements of the same type by their ids.
To achieve this we must load the nodes in parallel to the ways before we can output anything.
The idiom `(._; node(w););` accomplishes this by its three statements `._`, `node(w)`, and `(...)`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    (._; node(w););
    out;

Nodes and ways each with all their details together are explained in the final section.

<a name="rels"/>
## Relations

As with ways, the simpler case is
that the downstream tool can handle integrated geometry directly.
For this purpose the direct comparison:
[without coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out;

and [with coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom;

In contrast to the ways the data grows by an order of magnitude:
This is because in the variant without coordinates, we see the ids of the member ways only,
but in fact each way consists of multiple nodes and accordingly has multiple coordinates.

Relations with most of the members being of type way are much more frequent than anything else.
For this reason there is the mechanism to restrict the output geometry to a bounding box,
which is described in the subsection [Crop the Bounding Box](bbox.md#crop):
an [example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom({{bbox}});

The original data model of OpenStreetMap does not admit coordinates for relations, too.
For software that needs the strictly original data model, there again are two levels of faithfulness.
One gets a result the most possible way reduced to only the extra coordinates
by outputting the relations first and then resolving their dependencies.
This needs two pathes of data flow,
because relations can have nodes directly as members,
but also indirectly as the members of the ways that are members of the relation.
We would have to use four statements.
Because this is such a frequent case there is an extra short shortcut statement `>`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out qt;
    >;
    out skel qt;

In comparison to the preceding output the volume of data has already doubled,
because we always need to include both the reference target and the reference itself.

The completely compatible variant claims even more data volume.
It employs the idiom `(._; >;);` built from the statements `._`, `>`, and `(...)`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    (._; >;);
    out;

Is there a solution possible also here to restrict the set of retrieved coordinates to the bounding box?
Because a relation is contained in a bounding box
if and only if at least one of its members is contained in the bounding box,
we can achieve this by asking for the referred objects first and then resolve backwards.
The statement `<` facilitates this:
It is a shortcut to find all ways and relations
that refer to the given nodes or ways as members.
Thus we search for all nodes and ways in the bounding box.
Then we keep them with the statement `._` and search all relations
that refer to these as members: [(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    (._; <;);
    out;

The relations can be spotted by the traces they leave on their members:
These have a different colour than ordinary search results in Overpass Turbo.
The relations are even easier to find in the tab _Data_;
just scroll down to the end.

Hence, most members of the relations are not loaded at all;
only the members within the bounding box are loaded.
This request is not ready for production use because we do not load all used nodes for the ways.
A completed request can be found below in the section _Grand Total_.

<a name="rels_on_rels"/>
## Relations on Top of Relations

<!--
Um das Problem mit Relationen auf Relationen vorzuführen,
müssen wir die Bounding-Box nicht einmal besonders vergrößern.
Wir starten mit der Abfrage von oben ohne Relatione auf Relationen: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    (._; >;);
    out;

Jetzt ersetzen wir die Auflösung ab den Relationen abwärts durch

* eine Rückwärtsauflösung auf Relationen von Relationen
* die vollständige Vorwärtsauflösung der gefundenen Relationen bis zu den Koordinaten

Dies sind die Kommandos `rel(br)` und `>>`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    ( rel(br); >>;);
    out;

Je nach System wird dies Ihren Browser verlangsamen oder eine Warnmeldung produzieren.
Wir haben eine Ecke im Vorort Greenwich gewollt und tatsächlich Daten aus fast ganz London bezogen,
da es eine Sammelrelation _Quietways_ gibt.
Da hat die sowieso schon große Datenmenge wiederum vervielfacht.

Selbst wenn es hier irgendwann keine Sammelrelation mehr geben sollte,
wie dies auch für unsere Testregion mit etwa hundert Metern Kantenlänge gilt:
Wollen Sie ernsthaft Ihre Anwendung dafür anfällig machen,
dass sie nicht mehr funktioniert,
sobald irgendein ein unbedarfter Mapper im Zielgebiet eine oder mehrere Sammelrelationen anlegt?

Daher rate ich recht dringend davon ab, mit Relationen auf Relationen zu arbeiten.
Die Datenstruktur schafft das Risiko,
ungewollt sehr große Datenmengen miteinander zu verbinden.

Wenn man unbedingt Relationen auf Relationen verarbeiten will,
dann ist eine eher beherrschbare Lösung,
nur die Relationen zu laden,
aber keine Vorwärtsauflösung mehr durchzuführen.
Dazu ergänzen wir die letzte Abfrage aus dem Absatz _Relationen_ um die Rückwärtsauflösung `rel(br)`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    (._; <; rel(br); );
    out;
-->

<a name="full"/>
## Grand Total

<!--
Wir stellen hier die am ehesten sinnvollen Varianten zusammen.

Wenn Ihr Zielprogramm mit Koordinaten am Objekt umgehen kann,
dann können Sie alle Nodes, Ways und Relations in der Bounding Box komplett wie folgt bekommen: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    out geom qt;
    <;
    out qt;

Dies sammelt

* alle Nodes in der Bounding-Box (Selektion Zeile 1, Ausgabe Zeile 3)
* alle Ways in der Bounding-Box, auch solche, die die Bounding Box nur ohne Node durchschneiden (Selektion Zeile 2, Ausgabe Zeil 3)
* alle Relationen, die mindestens eine Node oder Way in der Bounding-Box als Member haben, ohne eigenständige Geometrie (Selektion Zeile 4, Ausgabe Zeile 5)

Die gleichen Daten ganz ohne Relationen erhalten Sie, wenn Sie nur die Zeilen 1 bis 3 als Abfrage verwenden.

Relationen auf Relationen erhalten Sie, wenn Sie Zeile 4 durch die Sammlung von Relationen und Relationen auf Relationen ergänzen: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    out geom qt;
    ( <; rel(br); );
    out qt;

Alternativ können Sie die Daten auch im strikt traditionellen Format mit Sortierung nach Elementtypen und nur indirekter Geometrie ausgeben.
Dies erfordert insbesondere, die Vorwärtsauflösung der Ways, um alle Nodes für die Geometrie zu bekommen.
Dann müssen wir das Kommando `<` durch eine präzisere Variante ersetzen,
da sonst das Kommando `<` Wege an den hinzugefügen Nodes aufsammelt.
Die erste Variante wird dann zu: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    ( ._;
      (
        rel(bn)->.a;
        rel(bw)->.a;
      ); );
    ( ._;
      node(w); );
    out;

Hier sind Zeilen 3 bis 7 für die Relationen zuständig.
Ohne Zeilen 4 bis 8, aber mit Zeilen 9 bis 11 für die Vervollständigung der Ways und die Ausgabe
erhält man dann nur Nodes und Ways.

Umgekehrt können Relationen auf Relationen gesammelt werden,
indem Zeile 7 entsprechend durch die neue Zeile 8 ergänzt wird: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    ( ._;
      (
        rel(bn)->.a;
        rel(bw)->.a;
      );
      rel(br); );
    ( ._;
      node(w); );
    out;

Weitere Varianten existieren,
auch wenn sie eher historische Bedeutung haben.
Zwei stellen wir im [nächsten Unterkapitel](map_apis.md) vor.
-->