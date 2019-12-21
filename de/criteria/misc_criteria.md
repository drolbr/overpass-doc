Mehr Suchkriterien
==================

Weitergehende Suchkriterien wie nur nach Keys, Suche per Länge, Version, Changest-Nummer oder Elementanzahl.

<!--
  Jeweils Eval und ggf. auch Filter
-->

<a name="per_key"/>
## Nur Keys

Es kann nützlich sein,
nach allen Objekten zu suchen, bei denen ein bestimmter _Key_ mit egal welchem _Value_ gesetzt ist.
Ein [Beispiel](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB) mit _railway_:

    nwr[railway]({{bbox}});
    out geom;

Der Filter `[railway]` lässt dabei nur Objekte zu, die ein Tag `railway` mit einem beliebigen Value tragen.
Er ist hier kombiniert mit einem Filter `({{bbox}})`,
so dass genau solche Objekte gefunden werden,
die sowohl ein Tag mit Key `railway` besitzen
als auch innerhalb der von [Overpass Turbo](../targets/turbo.md#convenience) übermittelten Bounding-Box liegen.

Dabei kann jeder beliebige Key durch eckige Klammer als Filterbedingung genutzt werden.
Keys, in deren Namen ein Sonderzeichen vorkommt, müssen zusätzlich in Anführungszeichen [eingeschlossen werden](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB):

    nwr["addr:housenumber"]({{bbox}});
    out geom;

Im Prinzip können die Filter nach Keys auch als einziger Filter in einem Query-Statements verwendet werden.
Allerdings gibt es rein von Datenmenge und Suchdauer her kaum einen sinnvollen Anwendungsfall.

Es können auch mehrere solche Filter [kombiniert werden](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB):

    nwr["addr:housenumber"]["addr:street"]({{bbox}});
    out geom;

Hier interessieren wir uns nur für Objekte,
die sowohl eine Hausnummer als auch einen Straßennamen für die Adresse tragen.
Dafür selektiert das Query-Statement in Zeile 1 genau solche Objekte,
die ein Tag mit Key `addr:housenumber` und zusätzlich ein Tag mit Key `addr:street` besitzen.

Da es zudem möglich ist, die Bedingung zu verneinen,
ist auf diesem Wege auch die Suche nach bearbeitungsbedürftigen Objekten möglich.
Wir suchen Objekte, die ein Tag mit Key `addr:housenumber` aber kein Tag zum Key `addr:street` [tragen](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB):

    nwr["addr:housenumber"][!"addr:street"]({{bbox}});
    out geom;

Die Verneinung geschieht durch ein Ausrufezeichen zwischen öffnender eckiger Klammer und Beginn des Keys.

<a name="count"/>
## Kennzahlen eines Objekts

Die Filter, mit deren Hilfe sich Objekte auszählen lassen,
können dagegen grundsätzlich nur zusammen mit anderen Filtern verwendet werden.
Der Grund dafür ist, dass die zu bewältigenden Datenmengen sonst schnell unbeherrschbar groß werden.

Für das Zählen der Tags eines Objektes seien die beiden beliebtesten Einsatzfälle erwähnt,
für alle übrigen auf das Kapitel [Objekte zählen](../counting/index.md) verwiesen.

Es ist möglich, alle Objekte zu selektieren, die mindestens ein Tag tragen.
Hier [für Nodes](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB), da bei Ways und Relations ohnehin nahezu alle Objekte Tags tragen:

    node(if:count_tags()>0)({{bbox}});
    out geom;

Umgekehrt ist es genauso möglich, alle Objekte zu selektieren, die kein Tag tragen.
Hier [für Ways](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB):

    way(if:count_tags()==0)({{bbox}});
    out geom;

Beide Requests sind aber weniger nützlich als sie aussehen:
Es gibt einerseits uninformative Tags
(`created_by` an Nodes, Ways oder Relations ist misbilligt, kann aber durchaus noch existieren)
andererseits können Objekte zu Relationen gehören.

Für Ways und Relations lässt sich auch die Anzahl der Member zählen, damit rechnen und vergleichen.
Auch dafür gibt es umfassende Beispiele im Kapitel [Objekte zählen](../counting/index.md).

Wir können Ways [mit besonders vielen Members](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB) finden:

    way(if:count_members()>200)({{bbox}});
    out geom;

Oder Relationen darauf prüfen, ob alle Member plausible Rollen haben.
Dazu verwenden wir den Evaluator `count_by_role` zusätzlich zum Evaluator `count_members`,
um dies für Abbiegebeschränkungen [anzuzeigen](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=12&Q=CGI_STUB):

    rel[type=restriction]({{bbox}})
      (if:count_members()
        -count_by_role("from")
        -count_by_role("to")
        -count_by_role("via") > 0);
    out center;

Echte Fehler sind dies nicht:
wie bei allen Diagnosen und im Kapitel [Daten analysieren](../analysis/index.md) ausdrücklich erwähnt,
sind Objekte mit unerwarteteten Eigenschaften der Beginn einer Recherche, nicht deren Ende.

<a name="geom"/>
## Wege per Länge

Es ist möglich, die Länge eines Ways oder einer Relation per Evaluator zu ermitteln.
Neben [statistischen Auswertungen](../counting/index.md) erlaubt dies auch,
Ways oder Relations anhand ihrer Länge zu selektieren.
Die Länge wird immer in Metern ausgewiesen.

Ein zur Qualitätssicherung genutzes Beispiel sind Schornsteine gewesen,
da das zugehörige Tag `building=chimney` gelegentlich für das gesamte Industriegebäude genutzt worden ist.
Wir suchen daher weltweit alle Schornsteine mit einem [Umfang von mehr als 62 Metern](https://overpass-turbo.eu/?lat=30.0&lon=-0.0&zoom=1&Q=CGI_STUB):

    way[building=chimney](if:length()>62);
    out geom;

Naheliegend wäre es auch, lange Straßen finden zu wollen.
Da Straßenzüge aber gewöhnlich aus vielen Abschnitten bestehen,
müssen wir dazu die Straßen zunächst wieder gruppenweise zusammenfassen.
Abfragen dieses Komplexitätsgrades gehören zwar eher in das Kapitel [Daten analysieren](../analysis/index.md),
aber aus Bequemlichkeit sei ein Ansatz für 2km Mindestlänge [hier skizziert](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=14&Q=CGI_STUB):

    [out:csv(length,name)];
    way[highway][name]({{bbox}});
    for (t["name"])
    {
      make stat length=sum(length()),name=_.val;
      if (u(t["length"]) > 2000)
      {
        out;
      }
    }

Zeilen 3 bis 10 sind eine Schleife,
in der die Auswahl aus Zeile 2, nämlich alle Ways mit Keys `highway` und `name`,
nach `name` gruppiert werden.
Daher können in Zeile 5 mit dem Ausdruck `sum(length())` die Länge aller Objekte jeweils eines Namens summiert werden.
In Zeile 6 bis 9 schreiben wir dann nur dann eine Ausgabe, wenn die dabei erreichte Länge 2000 Meter übersteigt.

Ein Ansatz, der auch etwas anzeigt, ist dabei schwierig,
da jeder Name ja von jeweils vielen Objekten repräsentiert wird.
Eine Lösung mittels _Deriveds_ wird ebenfalls im Kapitel [Daten analysieren](../analysis/index.md) vorgestellt.

<a name="meta"/>
## Meta-Eigenschaften

Es ist möglich, direkt per Typ und Id nach einem Objekt zu suchen,
[hier der Node 1](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=CGI_STUB):

    node(1);
    out;

Dazu stehen sowohl der gezeigte Filter `(...)` mit der Id zwischen den Klammern
als auch Evaluators `id()` und `type()` zur Verfügung.
Direkte Anwendungsfälle sind mir nicht bekannt,
aber einige größere Funktionen bei der [Datenanalyse](../analysis/index.md) nutzen diese Funktionalität.

Für die Version steht dagegen nur ein Evaluator zur Verfügung,
da ein Filter alleine ohnehin zu irrsinnigen Datenmengen führen würde.

Ein beliebter Anwendungsfall ist es, unsinnige oder unzulässige Uploads zu identifizieren.
Dazu kann es helfen, alle Objekte der Version 1 in einer Bounding-Box [auszuwählen](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=CGI_STUB):

    nwr({{bbox}})
      (if:version()==1);
    out center;

Dazu wird hier in Zeile 2 der Evaluator `version()` genutzt.
Wie bei allen _Evaluators_ als _Filter_ geschieht dies,
indem im Rahmen des Filters `(if:...)` der Wert des Evaulators mit einem anderen Wert (hier `1`) verglichen wird.

Auch für Timestamps steht im Wesentlichen ein Evaluator zur Verfügung, und zwar `timestamp()`.
Es gibt zwar einen Filter `(changed:...)`,
aber dieser ist für den Einsatz [mit Attic-Data](../analysis/index.md) bestimmt.

Der Evaluator `timestamp()` liefert stets ein Datum im [internationalen Datumsformat](https://de.wikipedia.org/wiki/ISO_8601),
z.B. `2012-09-13` für den 13. September 2012.
Es sollte daher auch stets gegen ein Datum im ISO-Format verglichen werden.
Wir listen z.B. alle nahe Greenwich [zuletzt vor dem 13. September 2012](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=16&Q=CGI_STUB) geänderten Objekte auf:

    nwr({{bbox}})(if:timestamp()<"2012-09-13");
    out geom({{bbox}});

An einige Tücken sei dabei erinnert:

* Ways und Relations können ihre Geometrie ändern, ohne dass eine neue Version entsteht,
  nämlich wenn nur referenzierte Nodes verschoben worden sind, ohne die Referenzierung zu ändern.
* Die meisten Eigenschaften eines Objektes kommen aus früheren Version,
  d.h. ein scheinbar frisches Änderungsdatum bedeutet nicht notwendigerwiese ein aktuelles Objekt.

<a name="attribution"/>
## Zurechnung

...
<!--
  Username
  Changeset-Id
-->
