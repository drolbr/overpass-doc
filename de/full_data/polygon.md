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
Mit den Ergebnissen von Nominatim kann dann meist schon die im nächsten Abschnitt beschriebene Suche um Koordinaten benutzt werden.

Es gibt aber genug Beispiele, bei denen schon der Name das richtige Objekt [liefert](https://overpass-turbo.eu/?lat=51.0&lon=10.0&zoom=6&Q=nwr%5Bname%3D%22K%C3%B6lner%20Dom%22%5D%3B%0Aout%20geom%3B):

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

...
<!--
  Um Punkt
  Um Pfad
-->

<a name="polygon"/>
## Polygone als Begrenzung

...
