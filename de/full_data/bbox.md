Bounding-Boxen
==============

Der einfachste Weg, um an OpenStreetMap-Daten in einem Ausschnitt zu kommen.

<a name="filter"/>
## Suchkriterium

Der einfachste Weg, an alle Daten in einer Bounding-Box zu kommen, ist,
dies explizit so zu formulieren [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    nwr(51.477,-0.001,51.478,0.001);
    out;

Dabei steht `(51.477,-0.001,51.478,0.001)` für die Bounding Box.
Die Reihenfolge der Ränder im Ausdruck ist dabei immer gleich:

* `51.477` ist der Breitengrad (_Latitude_) des südlichen Randes
* `-0.001` ist der Längengrad (_Longitude_) des westlichen Randes
* `51.478` ist der Breitengrad (_Latitude_) des nördlichen Randes
* `0.001` ist der Längengrad (_Longitude_) des östlichen Randes

Die Overpass API verwendet ausschließlich Dezimalbrüche,
die Minuten-Sekunden-Notation oder Minuten-Dezimalbruch-Notation wird nicht unterstützt.

Der Wert für den südlichen Rand muss stets kleiner sein als der Wert für den nördlichen Rand,
da im Breitengrad-Längengrad-Koordinatensystem die Grade vom Südpol zum Nordpol wachsen, von -90.0 bis +90.0.

Im Gegensatz dazu steigen die Längengrade zwar von Westen nach Osten ebenfalls fast überall an.
Es gibt aber den sogenannten Anitmeridian, im Deutschen oft mit der "Datumsgrenze" verwechselt;
dort springt der Wert von +180.0 auf -180.0.
Er verläuft zwischen Nordpol und Südpol durch den Pazifik.
In nahezu allen Fällen ist also ebenfalls der westliche Wert kleiner als der östliche Wert,
es sei denn, man will eine Bounding-Box über den Antimeridian spannen.

Meistens ist es recht mühsam,
die passende Bounding-Box selbst herauszufinden.
Daher haben fast alle der unter [Verwendung](../targets/index.md) beschriebenen Programme Komfortfunktionen dafür.
Bei [Overpass Turbo](../targets/turbo.md#convenience) und auch [JOSM](../targets/index.md)
werden vor dem Absenden der Anfrage alle Vorkommen der Zeichenfolge `{{bbox}}` durch die sichtbare Bounding-Box ersetzt. Damit kann man eine Abfrage wie oben allgemeiner schreiben als [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    nwr({{bbox}});
    out;

Die Abfrage wirkt dann in der jeweils sichtbaren Bounding-Box.

Beachten Sie, dass einige Elemente in der Darstellung gestrichelt werden.
Das ist der Hinweis auf ein größere Problematik, dem wir [im nächsten Abschnitt](osm_types.md) nachgehen werden:
Es werden zwar formal vollständige Objekte geliefert,
aber diese Objekte haben hier unvollständige Geometrien,
da wir dies in der Abfrage so spezifiziert haben.

<a name="crop"/>
## Ausgabebegrenzung

Eine zweite Situation, in der Bounding-Boxen vorkommen,
ist bei der Ausgabebegrenzung mit `out geom`.
Möchte man einen _Way_ oder eine _Relation_ auf der Karte visualisieren,
so muss die Overpass API [explizit anweisen](../targets/formats.md#extras),
das Objekt entgegen der OSM-Konventionen mit Koordinaten auszustatten.

Im Falle von Relationen kann dies zu großen Datenmengen führen.
So wird in [diesem Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) ungefragt Geometrie quer durch England ausgeliefert,
obwohl nur ein paar hundert Quadratmeter im Fokus gewesen sind:

    relation(51.477,-0.001,51.478,0.001);
    out geom;

Die Datenmenge kann eingeschränkt werden,
indem bei der Ausgabe [explizit](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) nur Koordinaten aus einer übergebenen Bounding-Box angefordert werden:

    relation(51.477,-0.001,51.478,0.001);
    out geom(51.47,-0.01,51.49,0.01);

Die Bounding-Box wird direkt hinter `geom` notiert.
Sie kann sowohl gleich als auch verschieden von Bounding-Boxen aus vorangehenden Statements sein.
In diesem Fall haben wir uns durch verschiedene Bounding-Boxen zu einem sehr breiten Reserverand entschieden.

Zu explizit vorkommenden _Nodes_ werden dabei die Koordinaten genau dann mitgeliefert,
wenn diese innerhalb der Bounding-Box liegen.

Bei _Ways_ nicht nur die Koordinaten aller _Nodes_ in der Bounding-Box mitgeliefert,
sondern auch die jeweils nächste und vorausgehende Koordinate,
auch wenn sie bereits außerhalb der Bounding-Box liegt.
Um dies [im Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=18&Q=CGI_STUB) zu sehen, bitte nach dem Ausführen auf _Daten_ oben rechts klicken;
Herumschieben der Karte zeigt auch, wo abgeschnitten worden ist:

    way[name="Blackheath Avenue"](51.477,-0.001,51.478,0.001);
    out geom(51.477,-0.002,51.479,0.002);

Nur ein Teil der _Nodes_ im _Way_ hat hier Koordinaten.

Die mit Koordinaten versehenen Abschnitte des Ways [können unzusammenhängend](https://overpass-turbo.eu/?lat=51.4735&lon=-0.007&zoom=17&Q=CGI_STUB) sein,
auch bei einem einzelnen Way:

    way[name="Hyde Vale"];
    out geom(51.472,-0.009,51.475,-0.005);

Es reicht dazu eine mäßige Kurve aus der Bounding-Box und wieder hinein wie in diesem Beispiel.

Bei _Relations_ werden _Member_ vom Typ _Way_ expandiert,
wenn zumindest eine der _Nodes_ dieses Ways innerhalb der Bounding-Box liegt.
Andere _Member_ vom Typ _Way_ werden nicht expandiert.
Innerhalb dieser _Ways_ werden wie bei einzelnen _Ways_ die _Nodes_ innerhalb der Bounding Box plus eine Extra-_Node_ mit Koordinaten versehen.

Ebenso wie bei der Bounding-Box als Filter haben die meisten Programme einen Mechanismus,
um die Bounding Box selbsttätig einzufügen.
Bei [Overpass Turbo](../targets/turbo.md#convenience) tut dies wie oben `{{bbox}}`, [(Beispiel)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    relation({{bbox}});
    out geom({{bbox}});

<a name="global"/>
## Globale Bounding-Box

...
