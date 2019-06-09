Polygon und Around
==================

Neben der Bounding-Box gibt es weitere, dem Zielgebiet besser anpassbare Begrenzungsrahmen.

Koordinaten in Breiten- und Längengrad sind zwar als Konzept gut verständlich,
aber die wenigsten Menschen kennen zu den sie interessiernden Orten die Koordinaten auswendig.

Es wird daher zunächst die indirekte Suche anhand von benannten Objekten vorgestellt.
Die Suche in Flächen ist dabei einerseits herausragend häufig,
hat aber andererseits mehrere Besonderheiten.
Sie wird daher in einem [anderen Unterkapitel](area.md) behandelt.

In diesem Unterkapitel geht es um die Suche im Umkreis von benannten Objekten.
Die Suche im Umkreis von Koordinaten schließt sich an.
Zuletzt werden noch Polygone als räumlicher Suchfilter vorgestellt.

<a name="around"/>
## Around-Filter ab Objekten

Es ist eine anspruchsvolle Aufgabe,
aus einem Text zuverlässig einen konkreten Ort zu ermitteln.
Daher fällt dies auch eigentlich einem Geocoder zu, z.B. [Nominatim](../criteria/nominatim.md#nominatim),
und wird hier nicht vertieft.
Mit den Ergebnissen von Nominatim kann schon die im nächsten Abschnitt beschriebene Suche um Koordinaten benutzt werden.

Es gibt aber genug Beispiele, bei denen bereits der Name das richtige Objekt [liefert](https://overpass-turbo.eu/?lat=51.0&lon=10.0&zoom=6&Q=nwr%5Bname%3D%22K%C3%B6lner%20Dom%22%5D%3B%0Aout%20geom%3B):

    nwr[name="Kölner Dom"];
    out geom;

In Zeile 1 suchen wir nach allen Objekten,
die ein Tag ``name`` mit wert ``Kölner Dom`` besitzen.
Dieses wird im Set ``_`` abgelegt,
und in Zeile 2 gibt ``out geom`` aus, was es im Set ``_`` vorfindet.

Zur Erinnerung: [Die Lupe](../targets/turbo.md#basics) zoomt auf die Fundstellen heran.
Gerade bei indirekten Filtern ist es oft sinnvoll, die ursprüngliche Objektsuche auszuführen,
um auszuschließen, dass es weitere gleichnamige Objekte [an anderen Orten](https://overpass-turbo.eu/?lat=51.0&lon=10.0&zoom=6&Q=nwr%5Bname%3D%22Viktualienmarkt%22%5D%3B%0Aout%20geom%3B) gibt:

    nwr[name="Viktualienmarkt"];
    out geom;

Eine [Bounding-Box](bbox.md#bbox) oder die Angabe einer umschließenden Fläche [können helfen](https://overpass-turbo.eu/?lat=48.0&lon=11.5&zoom=10&Q=area%5Bname%3D%22M%C3%BCnchen%22%5D%3B%0Anwr%28area%29%5Bname%3D%22Viktualienmarkt%22%5D%3B%0Aout%20geom%3B):

    area[name="München"];
    nwr(area)[name="Viktualienmarkt"];
    out geom;

Das bzw. die gewünschten Objekte stehen hier nach Zeile 2 im Set ``_``.

Wir könnten nun alle Objekte im Umkreis von 100 Metern um den Kölner Dom [finden](https://overpass-turbo.eu/?lat=50.94&lon=6.96&zoom=14&Q=nwr%5Bname%3D%22K%C3%B6lner%20Dom%22%5D%3B%0Anwr%28around%3A100%29%3B%0Aout%20geom%3B):

    nwr[name="Kölner Dom"];
    nwr(around:100);
    out geom;

Allerdings warnt Overpass Turbo zurecht vor der Größe der zurückkommenden Datenmenge.
Es erschließt sich auch nicht unmittelbar,
warum eigentlich Gleise zwischen Paris und Brüssel als in der Nähe des Kölner Doms gelten sollen.
Das Problem sind daher einmal mehr räumlich ausgedehnte _Relations_.
Da dies beim Viktualienmarkt wegen Fernwander- und Radwegen [kaum besser](https://overpass-turbo.eu/?lat=48.135&lon=11.575&zoom=14&Q=area%5Bname%3D%22M%C3%BCnchen%22%5D%3B%0Anwr%28area%29%5Bname%3D%22Viktualienmarkt%22%5D%3B%0Anwr%28around%3A100%29%3B%0Aout%20geom%3B) ist ...

    area[name="München"];
    nwr(area)[name="Viktualienmarkt"];
    nwr(around:100);
    out geom;

... lässt sich vermuten, dass es sich um ein häufiges Problem handelt.
Dies setzt der Nutzbarkeit des _Around_-Filters ohne weitere Filter enge Grenzen.

Auf der technischen Ebene haben wir wieder unsere benannten Objekte vor der Zeile mit ``(around:100)`` im Set ``_``.
Das Statement _Around_ filtert nun aus allen Objekten nur diejenigen heraus,
die zu mindestens einem Objekt im Set ``_`` einen Abstand von höchstens dem angegebenen Wert in Metern haben.

Der Mechanismus zur Verkettung hat [ein eigenes Unterkapitel](../criteria/chaining.md#lateral), und Sets sind in [der Einleitung](../preface/design.md#sets) eingeführt worden.
Das Beispiel [dort vom Anfang](../preface/design.md#sequential) zeigt eine Anwendung der _Around_-Filters,
die hilfreich ist,
da sie den Filter mit einem Filter nach einem Tag [kombiniert](../criteria/union.md#intersection).
Werkzeuge gegen übergroße Datenmengen sind im Unterkapiel [Geometrien](osm_types.md#full) diskutiert worden.

Eine weitere mögliche Lösung, um den obigen Fall zumindest sinnvoll anzeigen zu können,
wäre nach _Ways_ statt nach allen Objekten zu filtern und nur die _Relations_ zu ermitteln,
die die gefundenen _Ways_ referenzieren;
für den [Kölner Dom](https://overpass-turbo.eu/?lat=50.94&lon=6.96&zoom=14&Q=nwr%5Bname%3D%22K%C3%B6lner%20Dom%22%5D%3B%0Away%28around%3A100%29%3B%0Aout%20geom%3B%0Arel%28bw%29%3B%0Aout%3B):

    nwr[name="Kölner Dom"];
    way(around:100);
    out geom;
    rel(bw);
    out;

Zeile 1 bringt unsere benannten Objekte ins Set ``_``;
Zeile 2 findet alle _Ways_,
die zu mindestens einem der Objekte aus dem Set ``_`` höchstens 100 Meter Abstand haben;
das Ergebnis ersetzt den Inhalt von Set ``_``.
Zeile 3 gibt den Inhalt von Set ``_`` aus, also die in Zeile 2 gefundenen _Ways_.
Zeile 4 findet alle _Relations_, die mindestens einen der im Set ``_`` abgelegten _Ways_ referenzieren
und ersetzt den Inhalt von ``_`` durch dieses Ergebnis.
In Zeile 5 wird der Inhalt von Set ``_``, also die gefundenen _Relations_, ausgegeben,
aber im Gegensatz zu Zeile 3 werden keine Koordinaten mitgeliefert -
dies schrumpft die _Relations_ auf eine handhabbare Größe.

<a name="absolute_around"/>
## Around-Filter mit Koordinaten

Im Umkreis kann auch anhand von Koordinaten statt vorhandener Objekte gesucht werden.
Ein Beispiel nahe Greenwich [auf dem Nullmeridian](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=nwr%28around%3A100%2C51%2E477%2C0%2E0%29%3B%0Aout%20geom%3B):

    nwr(around:100,51.477,0.0);
    out geom;

Es kommt ein Filter in Zeile 1 zum Einsatz:
es werden alle Objekte im Set ``_`` abgelegt,
die höchstens 100 Meter Abstand zu der gegebenen Koordinate haben.
Zeile 2 gibt das Set ``_`` aus.

Es gelten die gleichen Vorsichtshinweise wie bei allen anderen Volldaten-Suchen mit _Relations_:
sehr schnell hat man sehr viele Daten.
Die Reduktionstechniken von [Bounding-Boxen](osm_types.md#full) und [aus dem letzten Abschnitt](polygon.md#around) greifen hier aber ebenfalls.

Es gibt aber keinen Zwang nach _Relations_ zu suchen.
Man kann auch nur nach _Nodes_, [nur nach _Ways_](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=way%28around%3A100%2C51%2E477%2C0%2E0%29%3B%0Aout%20geom%3B) ...

    way(around:100,51.477,0.0);
    out geom;

... oder nach [_Nodes_ und _Ways_](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=%28%0A%20%20node%28around%3A100%2C51%2E477%2C0%2E0%29%3B%0A%20%20way%28around%3A100%2C51%2E477%2C0%2E0%29%3B%0A%29%3B%0Aout%20geom%3B) suchen:

    (
      node(around:100,51.477,0.0);
      way(around:100,51.477,0.0);
    );
    out geom;

Hier nutzen wir ein _Union_-Statement (wird [später](../criteria/union.md#union) eingeführt),
um die Ergebnisse der Umkreissuche nach _Nodes_ und der Umkreissuche nach _Ways_ zusammenzuführen.
Zeile 2 und Zeile 3 filtern je einen Objekttyp anhand eines _Around_-Filters,
und _Union_ fügt die Ergebnisse beider _Query_-Statements im Set ``_`` zusammen.

Damit werden auch Umkreise mit einem Radius von 1000 Metern und mehr durchführbar.

Relationen kann man jetzt ähnlich wie oben ohne Geometrie wieder [hinzunehmen](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=%28%0A%20%20node%28around%3A1000%2C51%2E477%2C0%2E0%29%3B%0A%20%20way%28around%3A1000%2C51%2E477%2C0%2E0%29%3B%0A%29%3B%0Aout%20geom%3B%0Arel%28%3C%29%3B%0Aout%3B):

    (
      node(around:1000,51.477,0.0);
      way(around:1000,51.477,0.0);
    );
    out geom;
    rel(<);
    out;

In Zeile 5 steht als Eingabe im Set ``_`` noch das Ergebnis des _Union_-Statements zur Verfügung.
Der Filter ``(<)`` lässt nur Objekte zu,
die auf mindestens ein Objekt in der Eingabe referenzieren -
das sind genau die Relationen, die einen Bezug zum Suchgebiet haben.

Um mit Suchen umzugehen,
die nicht gut in Bounding-Boxen passen,
stellen wir hier noch die Umkreissuche um einen Linienzug vor.
Dazu definiert man einen Pfad über zwei oder mehr Koordinaten,
und es werden alle Objekte gefunden,
deren Abstand [geringer](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=13&Q=%28%0A%20%20node%28around%3A100%2C51%2E477%2C0%2E0%2C51%2E46%2C%2D0%2E03%29%3B%0A%20%20way%28around%3A100%2C51%2E477%2C0%2E0%2C51%2E46%2C%2D0%2E03%29%3B%0A%29%3B%0Aout%20geom%3B%0Arel%28%3C%29%3B%0Aout%3B) als der angegebene Radius ist:

    (
      node(around:100,51.477,0.0,51.46,-0.03);
      way(around:100,51.477,0.0,51.46,-0.03);
    );
    out geom;
    rel(<);
    out;

Gegenüber der vorangehenden Abfrage haben sich nur die Zeilen 2 und 3 geändert;
die Koordinaten werden jeweils mit Kommata getrennt aneinandergehängt.

<a name="polygon"/>
## Polygone als Begrenzung

Eine weitere Methode,
um mit Suchgebieten umzugehen,
die nur schlecht in Bounding-Boxen passen,
ist die Suche anhand eines Polygons.
...
