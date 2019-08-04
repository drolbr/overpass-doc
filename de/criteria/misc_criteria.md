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
Ein [Beispiel](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=nwr%5Brailway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B) mit _railway_:

    nwr[railway]({{bbox}});
    out geom;

Der Filter ``[railway]`` lässt dabei nur Objekte zu, die ein Tag ``railway`` mit einem beliebigen Value tragen.
Er ist hier kombiniert mit einem Key ``({{bbox}})``,
so dass genau solche Objekte gefunden werden,
die sowohl ein Tag mit Key ``railway`` besitzen
als auch innerhalb der von [Overpass Turbo](../targets/turbo.md#convenience) übermittelten Bounding-Box liegen.

Dabei kann jeder beliebige Key durch eckige Klammer als Filterbedingung genutzt werden.
Keys, in deren Namen ein Sonderzeichen vorkommt, müssen zusätzlich in Anführungszeichen [eingeschlossen werden](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=nwr%5B%22addr%3Ahousenumber%22%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B):

    nwr["addr:housenumber"]({{bbox}});
    out geom;

Im Prinzip können die Filter nach Keys auch als einziger Filter in einem Query-Statements verwendet werden.
Allerdings gibt es rein von Datenmenge und Suchdauer her kaum einen sinnvollen Anwendungsfall.

Es können auch mehrere solche Filter [kombiniert werden](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=nwr%5B%22addr%3Ahousenumber%22%5D%5B%22addr%3Astreet%22%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B):

    nwr["addr:housenumber"]["addr:street"]({{bbox}});
    out geom;

Hier interessieren wir uns nur für Objekte,
die sowohl eine Hausnummer als auch einen Straßennamen für die Adresse tragen.
Dafür selektiert das Query-Statement in Zeile 1 genau solche Objekte,
die ein Tag mit Key ``addr:housenumber`` und zusätzlich ein Tag mit Key ``addr:street`` besitzen.

Da es zudem möglich ist, die Bedingung zu verneinen,
ist auf diesem Wege auch die Suche nach bearbeitungsbedürftigen Objekten möglich.
Wir suchen Objekte, die ein Tag mit Key ``addr:housenumber`` aber kein Tag zum Key ``addr:street`` [tragen](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=nwr%5B%22addr%3Ahousenumber%22%5D%5B%21%22addr%3Astreet%22%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B):

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
Hier [für Nodes](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=node%28if%3Acount%5Ftags%28%29%3E0%29%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B), da bei Ways und Relations ohnehin nahezu alle Objekte Tags tragen:

    node(if:count_tags()>0)({{bbox}});
    out geom;

Umgekehrt ist es genauso möglich, alle Objekte zu selektieren, die kein Tag tragen.
Hier [für Ways](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=way%28if%3Acount%5Ftags%28%29%3D%3D0%29%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B):

    way(if:count_tags()==0)({{bbox}});
    out geom;

Beide Requests sind aber weniger nützlich als sie aussehen:
Es gibt einerseits uninformative Tags
(``created_by`` an Nodes, Ways oder Relations ist misbilligt, kann aber durchaus noch existieren)
andererseits können Objekte zu Relationen gehören.

Für Ways und Relations lässt sich auch die Anzahl der Member zählen, damit rechnen und vergleichen.
Auch gibt es umfassende Beispiele im Kapitel [Objekte zählen](../counting/index.md).

Wir können Ways [mit besonders vielen Members](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=way%28if%3Acount%5Fmembers%28%29%3E200%29%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B) finden:

    way(if:count_members()>200)({{bbox}});
    out geom;

Oder Relationen darauf prüfen, ob alle Member plausible Rollen haben.
Dazu verwenden wir den Evaluator ``count_by_role`` zusätzlich zum Evaluator ``count_members``,
um dies für Abbiegebeschränkungen [anzuzeigen](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=12&Q=rel%5Btype%3Drestriction%5D%28%7B%7Bbbox%7D%7D%29%0A%20%20%28if%3Acount%5Fmembers%28%29%0A%20%20%20%20%2Dcount%5Fby%5Frole%28%22from%22%29%0A%20%20%20%20%2Dcount%5Fby%5Frole%28%22to%22%29%0A%20%20%20%20%2Dcount%5Fby%5Frole%28%22via%22%29%20%3E%200%29%3B%0Aout%20center%3B):

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
da das zugehörige Tag ``building=chimney`` gelegentlich für das gesamte Industriegebäude genutzt worden ist.
Wir suchen daher weltweit alle Schornsteine mit einem [Umfang von mehr als 62 Metern](https://overpass-turbo.eu/?lat=30.0&lon=-0.0&zoom=1&Q=way%5Bbuilding%3Dchimney%5D%28if%3Alength%28%29%3E62%29%3B%0Aout%20geom%3B):

    way[building=chimney](if:length()>62);
    out geom;

Naheliegend wäre es auch, lange Straßen finden zu wollen.
Da Straßenzüge aber gewöhnlich aus vielen Abschnitten bestehen,
müssen wir dazu die Straßen zunächst wieder gruppenweise zusammenfassen.
Abfragen dieses Komplexitätsgrades gehören zwar eher in das Kapitel [Daten analysieren](../analysis/index.md),
aber aus Bequemlichkeit sei ein Ansatz für 2km Mindestlänge [hier skizziert](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=14&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%5Bname%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20stat%20length%3Dsum%28length%28%29%29%2Cname%3D%5F%2Eval%3B%0A%20%20if%20%28u%28t%5B%22length%22%5D%29%20%3E%202000%29%0A%20%20%7B%0A%20%20%20%20out%3B%0A%20%20%7D%0A%7D):

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
in der die Auswahl aus Zeile 2, nämlich alle Ways mit Keys ``highway`` und ``name``,
nach ``name`` gruppiert werden.
Daher können in Zeile 5 mit dem Ausdruck ``sum(length())`` die Länge aller Objekte jeweils eines Namens summiert werden.
In Zeile 6 bis 9 schreiben wir dann nur dann eine Ausgabe, wenn die dabei erreichte Länge 2000 Meter übersteigt.

Ein Ansatz, der auch etwas anzeigt, ist dabei schwierig,
da jeder Name ja von jeweils vielen Objekten repräsentiert wird.
Eine Lösung mittels _Deriveds_ wird ebenfalls im Kapitel [Daten analysieren](../analysis/index.md) vorgestellt.

<a name="meta"/>
## Meta-Eigenschaften

Es ist möglich, direkt per Typ und Id nach einem Objekt zu suchen,
[hier der Node 1](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=node%281%29%3B%0Aout%3B):

    node(1);
    out;

Dazu stehen sowohl der gezeigte Filter ``(...)`` mit der Id zwischen den Klammern
als auch Evaluators ``id()`` und ``type()`` zur Verfügung.
Direkte Anwendungsfälle sind mir nicht bekannt,
aber einige größere Funktionen bei der [Datenanalyse](../analysis/index.md) nutzen diese Funktionalität.

Für die Version steht dagegen nur ein Evaluator zur Verfügung,
da ein Filter ohnehin nicht alleine stehen könnte.

Ein beliebter Anwendungsfall ist es, unsinnige oder unzulässige Uploads zu identifizieren.
Dazu kann es helfen, alle Objekte der Version 1 in einer Bounding-Box [auszuwählen](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=nwr%28%7B%7Bbbox%7D%7D%29%0A%20%20%28if%3Aversion%28%29%3D%3D1%29%3B%0Aout%20center%3B):

    nwr({{bbox}})
      (if:version()==1);
    out center;

...
<!--
  Timestamp (Newer, Changed)
-->

<a name="attribution"/>
## Zurechenbarkeit

...
<!--
  Username
  Changeset-Id
-->

