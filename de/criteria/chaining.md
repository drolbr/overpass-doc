Verketten
=========

Wie man mehrere Suchkriterien verkettet, so dass man nach Objekten relativ zu anderen Objekten suchen kann.

## Indirekte Filter

Beispiele für indirekte Filter haben wir bereits bei [Areas](../full_data/area.md) und [Around](../full_data/polygon.md) gesehen.
Es wird stets [per Aneinanderreihung](../preface/design.md#sequential) ein Filter gesteuert.

Wir schauen uns das am Beispiel an,
[alle Cafés in Köln](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=area%5Bname%3D%22K%C3%B6ln%22%5D%3B%0Anwr%5Bamenity%3Dcafe%5D%28area%29%3B%0Aout%20geom%3B) zu finden:

    area[name="Köln"];
    nwr[amenity=cafe](area);
    out center;

Zentral ist hier der Filter ``(area)`` in Zeile 2.
Der Filter filtert auf die Fläche oder Flächen,
die er im Set ``_`` vorfindet.
Er wirkt zusammen mit dem Filter ``[amenity=cafe]``,
d.h. wir suchen in Zeile 2 alle Objekte,
die _Node_, _Way_ oder _Relation_ sind (_nwr_) und das Tag _amenity_ mit Wert _cafe_ tragen
und innerhalb der in ``_`` hinterlegten Flächen liegen.

Wir können also die obige Abfrage auch umformulieren und erhalten das exakt gleiche Ergebnis:

    area[name="Köln"];
    nwr[amenity=cafe](area._);
    out center;

und

    area[name="Köln"]->._;
    nwr[amenity=cafe](area);
    out center;

und

    area[name="Köln"]->._;
    nwr[amenity=cafe](area._);
    out center;

In allen Fällen wird die Fläche von Zeile 1 nach Zeile 2 durch das Set ``_`` vermittelt.
Sets werden in [einem Abschnitt der Einleitung](../preface/design.md#sets) eingeführt.

Wir können auch ein Set [mit beliebigem Namen](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=area%5Bname%3D%22K%C3%B6ln%22%5D%2D%3E%2Eganzlangername%3B%0Anwr%5Bamenity%3Dcafe%5D%28area%2Eganzlangername%29%3B%0Aout%20center%3B) verwenden:

    area[name="Köln"]->.ganzlangername;
    nwr[amenity=cafe](area.ganzlangername);
    out center;

Es funktioniert allerdings nicht,
wenn der Name der Sets in beiden Zeilen nicht übereinstimmt:

    area[name="Köln"]->.ganzlangername;
    nwr[amenity=cafe](area.ganzlangrname);
    out center;

Nützlich werden Set-Namen dann,
wenn man mehrere Filter ansteuern möchte.
Wir können z.B. zwar nach Cafés in Münster suchen,
aber die Overpass API weiß dann nicht,
welches Münster wir meinen,
da es außer der großen Stadt auch viele kleinere Orte mit dem Namen gibt
und diese [auch Cafés haben](https://overpass-turbo.eu/?lat=50.0&lon=10.0&zoom=4&Q=area%5Bname%3D%22M%C3%BCnster%22%5D%3B%0Anwr%5Bamenity%3Dcafe%5D%28area%29%3B%0Aout%20center%3B):

    area[name="Münster"];
    nwr[amenity=cafe](area);
    out center;

Wir können aber verlangen,
dass das Café sowohl in Münster als auch in Nordrhein-Westfalen [liegen muss](https://overpass-turbo.eu/?lat=52.0&lon=7.5&zoom=6&Q=area%5Bname%3D%22Nordrhein%2DWestfalen%22%5D%2D%3E%2Ea%3B%0Aarea%5Bname%3D%22M%C3%BCnster%22%5D%2D%3E%2Eb%3B%0Anwr%5Bamenity%3Dcafe%5D%28area%2Ea%29%28area%2Eb%29%3B%0Aout%20center%3B):

    area[name="Nordrhein-Westfalen"]->.a;
    area[name="Münster"]->.b;
    nwr[amenity=cafe](area.a)(area.b);
    out center;

Die Cafés werden in Zeile 3 selektiert:
Wir wählen Objekte vom Typ _Node_, _Way_ oder _Relation_,
die das Tag ``amenity=cafe`` tragen
und die sowohl in einer der in ``a`` gespeicherten Flächen (nur 1 Fläche, nämlich das Bundesland _Nordrhein-Westfalen_)
als auch in einer der in ``b`` gespeicherten Flächen (alle Städte, Stadtteile und Dörfer mit Namen _Münster_) liegen.
Das sind nur nur noch die Cafés in Münster in Westfalen.

Das Zusammenspiel zwischen mehreren Filtern und Verkettung wird [im nächsten Abschnitt](union.md#full) vertieft.

Der Vollständigkeit halber sei darauf hingewiesen,
dass das Prinzip der indirekten Filter für alle Typen existiert.
Wir wollen alle Brücken über den Fluss _Alster_ finden.

Den Fluss Alster können wir gleich auf zwei verschiedene Weisen finden,
zunächst [per Way](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=way%5Bname%3D%22Alster%22%5D%5Bwaterway%3Driver%5D%3B%0Aout%20geom%3B):

    way[name="Alster"][waterway=river];
    out geom;

Wir suchen dazu nach alle Objekten vom Typ _Way_,
die das Tag _name_ mit Wert _Alster_ und das Tag _waterway_ mit Wert _river_ tragen.
Diese stehen nach Zeile 1 im Set ``_`` und werden von dort in Zeile 2 ausgegeben.

Die Brücken anstatt des Flusses finden wir [wie folgt](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=way%5Bname%3D%22Alster%22%5D%5Bwaterway%3Driver%5D%3B%0Away%28around%3A0%29%5Bbridge%3Dyes%5D%3B%0Aout%20geom%3B)

    way[name="Alster"][waterway=river];
    way(around:0)[bridge=yes];
    out geom;

Hier ist ``(around:0)`` in Zeile 2 der indirekte Filter.
Wir suchen in Zeile 2 alle _Ways_,
die das Tag _bridge_ mit Wert _yes_ haben
und die einen Abstand 0 zu den Objekten aus dem Set ``_`` haben.
Das Set ``_`` haben wir dazu in Zeile 1 mit den Ways befüllt, in deren Umkreis wir suchen wollen,
und zwar alle _Ways_, die ein Tag ``name`` mit Wert ``Alster`` und ein Tag ``waterway`` mit Wert ``river`` haben.

Das ganze funktioniert auch [mit Relations](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=relation%5Bname%3D%22Alster%22%5D%5Bwaterway%3Driver%5D%3B%0Aout%20geom%3B) ...

    relation[name="Alster"][waterway=river];
    out geom;

... nun [mit Brücken](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=relation%5Bname%3D%22Alster%22%5D%5Bwaterway%3Driver%5D%3B%0Away%28around%3A0%29%5Bbridge%3Dyes%5D%3B%0Aout%20geom%3B):

    relation[name="Alster"][waterway=river];
    way(around:0)[bridge=yes];
    out geom;

## Benutzte Objekte

Einer völlig anderen Anwendung für Verkettung sind wir in Abschnitten [Relationen](../full_data/osm_types.md#rels) und [Relationen auf Relationen](../full_data/osm_types.md#rels_on_rels) in [Geometrien](../full_data/osm_types.md) begegnet:
Da das traditionelle OSM-Datenmodell Koordinaten nur auf Nodes zulässt,
aber auch an den anderen Objekten ihre Geometrie interessant ist,
müssen im traditionellen OSM-Datenmodell _Ways_ und _Relations_ um die jeweiligen Hilfsobjekte ergänzt werden.

Die Verkettungsaspekte erklären wir an einem Beispiel:
Die U-Bahn-Linie _Waterloo & City_ in London können wir zwar [wie folgt](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0Aout%20geom%3B) bekommen:

    rel[ref="Waterloo & City"];
    out geom;

Dann gebrauchen wir aber ein [erweitertes Datenmodell](../targets/formats.md#extras),
das nicht alle Anwendungen unterstützen.
Wenn wir dagegen den traditionellen Detailgrad _out_ [zur Ausgabe nutzen](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0Aout%3B),
so sehen wir gar nichts:

    rel[ref="Waterloo & City"];
    out;

Die Relation steht nach der Ausgabe in Zeile 2 aber noch immer im Set ``_``.
Wir können daher die zugehörigen _Ways_ und _Nodes_ sammeln,
indem wir das im [folgenden Abschnitt](union.md#union) erläuterte _Union_ mit Verkettung [kombinieren](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0Aout%3B%0A%28%0A%20%20way%28r%29%3B%0A%20%20node%28w%29%3B%0A%29%3B%0Aout%20skel%3B):

    rel[ref="Waterloo & City"];
    out;
    (
      way(r);
      node(w);
    );
    out skel;

Vor Zeile 3 stehen im Set ``_`` wie schon erwähnt die gefundenen Relationen.
Zeilen 3 bis 6 sind das [Union](union.md#union).
Zeile 4 ``way(r)`` ist daher die nächste nach Zeile 2 ausgeführte Zeile und erhält die Relationen als Eingabe.
Es sucht nach _Ways_, die dem Filter ``(r)`` genügen,
d.h. von einer oder mehreren _Relations_ in der Eingabe referenziert werden.
Als Ergebnis schreibt es diese Ways nun in das Set ``_``.
Das Block-Statement _Union_ behält gemäß seiner Semantik eine Kopie davon für sein Ergebnis.

Zeile 5 ``node(w)`` findet  also die Ways aus Zeile 4 als Eingabe im Set ``_`` vor.
Es sucht nach _Nodes_, die dem Filter ``(w)`` genügen,
d.h. von einer oder mehreren _Ways_ in der Eingabe referenziert werden.
Als Ergebnis schreibt es diese Ways zwar in das Set ``_``,
aber _Union_ ersetzt das Set ohnehin durch sein eigenes Ergebnis.

Als Ergebnis von Zeile 6 schreibt _Union_ in das Set ``_`` die Vereinigung der Ergebnisse,
die es gesehen hat.
Wir erhalten also alle _Ways_, die von den Relationen referenziert worden sind
und alle _Nodes_, die von diesen _Ways_ referenziert worden sind.

Allerdings können Relationen auch _Nodes_ direkt als Member haben,
und diese Relationen haben dies auch;
man sieht dies im [Daten](../targets/turbo.md#basics)-Tab oder [per Abfrage](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0Anode%28r%29%3B%0Aout%3B):

    rel[ref="Waterloo & City"];
    node(r);
    out;

Auf diesem Weg ersetzen wir im Set ``_`` in Zeile 2 die _Relations_ durch die referenzierten _Nodes_.
Dann haben wir zwar für die Ausgabe in Zeile 3 diese Nodes zur Verfügung,
bräuchten aber die _Relations_ erneut,
um die referenzierten _Ways_ zu erhalten.
Können wir die Doppelsuche vermeiden?

Ja, [mit benannten Sets](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0Aout%3B%0A%28%0A%20%20node%28r%29%2D%3E%2Edirekt%5Fvon%5Fden%5Frelations%5Freferenziert%3B%0A%20%20way%28r%29%3B%0A%20%20node%28w%29%3B%0A%29%3B%0Aout%20skel%3B):

    rel[ref="Waterloo & City"];
    out;
    (
      node(r)->.direkt_von_den_relations_referenziert;
      way(r);
      node(w);
    );
    out skel;

Im Detail:

* Nach Zeile 1 stehen im Set ``_`` alle _Relations_,
  die ein Tag ``ref`` mit Wert ``Waterloo & City`` haben.
* In Zeile 2 werden diese ausgegeben.
  Im Set ``_`` stehen nach wie vor die _Relations_.
* Das Block-Statement _Union_ von Zeile 3 bis Zeile 7 führt den Block in seinem Inneren aus.
* In Zeile 4 wird daher von ``(r)`` der Inhalt von Set ``_`` genutzt, nämlich die _Relations_ aus Zeile 1.
  Damit werden neu im Set ``direkt_von_den_relations_referenziert`` diejenigen _Nodes_ abgelegt,
  die von einer der _Relations_ referenziert werden.
  _Union_ behält eine Kopie des Ergebnisses zurück.
* In Zeile 5 wird von ``(r)`` wiederum der Inhalt von Set ``_`` genutzt,
  und dies sind noch immer die _Relations_, da wir diese nicht überschrieben haben.
  Im Set ``_`` sind nun die _Ways_ abgelegt, die von den _Relations_ referenziert werden.
  _Union_ behält eine Kopie des Ergebnisses zurück.
* In Zeile 6 wird von ``(w)`` wiederum der Inhalt von Set ``_`` genutzt.
  Dies sind nun die in Zeile 5 geschriebenen _Ways_.
  Also werden im Set ``_`` nun die von diesen _Ways_ referenzierten _Nodes_ abgelegt.
  _Union_ behält eine Kopie des Ergebnisses zurück.
* _Union_ setzt nun aus seinen Teilergebnisse der Zeilen 4, 5 und 6 das Gesamtergebnis zusammen
  und schreibt es in das Set ``_``.
* In Zeile 8 wird nun das Set ``_`` ausgegeben.

Da dies ein sehr häufiges Problem ist,
gibt es für genau diese Aufgabe auch [eine Abkürzung](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0Aout%3B%0A%3E%3B%0Aout%20skel%3B):

    rel[ref="Waterloo & City"];
    out;
    >;
    out skel;

Zeilen 1 und 2 arbeiten exakt wie vorher,
und Zeile 4 arbeitet exakt wie Zeile 8 vorher:
Denn der Pfeil in Zeile 3 hat als Semantik,
dass er zu Relations im Set ``_`` die direkt und indirekt referenzierten _Ways_ und _Nodes_ findet
und ins Set ``_`` ausgibt.

Nun sind zuletzt noch einige Programme überfordert,
wenn die Reihenfolge in der Datei nicht exakt alle _Nodes_, dann alle _Ways_, dann zuletzt alle _Relations_ ist.

Für den detaillierten Ansatz erreicht man dies,
indem die initiale Anfrage in den _Union_-Block [verschiebt](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=%28%0A%20%20rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0A%20%20node%28r%29%2D%3E%2Edirekt%5Fvon%5Fden%5Frelations%5Freferenziert%3B%0A%20%20way%28r%29%3B%0A%20%20node%28w%29%3B%0A%29%3B%0Aout%3B):

    (
      rel[ref="Waterloo & City"];
      node(r)->.direkt_von_den_relations_referenziert;
      way(r);
      node(w);
    );
    out;

Ebenso [mit dem Pfeil](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=%28%0A%20%20rel%5Bref%3D%22Waterloo%20%26%20City%22%5D%3B%0A%20%20%3E%3B%0A%29%3B%0Aout%3B):

    (
      rel[ref="Waterloo & City"];
      >;
    );
    out;

## Differenz

...
<!--
  TODO: Differenz wegen ._-Falle
-->

## Tags gleichen Wertes

...
<!--
  TODO: Wertgleichheit via Evaluator
-->
