Bounding-Boxen
==============

Der einfachste Weg, um an OpenStreetMap-Daten in einem Ausschnitt zu kommen.

## Suchkriterium

Der einfachste Weg, an alle Daten in einer Bounding-Box zu kommen, ist,
die explizit so zu formulieren [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=nwr%2851%2E477%2C%2D0%2E001%2C51%2E478%2C0%2E001%29%3B%0Aout%3B):

    nwr(51.477,-0.001,51.478,0.001);
    out;

Dabei steht `(51.477,-0.001,51.478,0.001)` für die Bounding Box:

* `51.477` ist der Breitengrad (_Latitude_) des südlichen Randes
* `-0.001` ist der Längengrad (_Longitude_) des westlichen Randes
* `51.478` ist der Breitengrad (_Latitude_) des nördlichen Randes
* `-0.001` ist der Längengrad (_Longitude_) des östlichen Randes

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
Bei [Overpass Turbo](../targets/turbo.md) und auch [JOSM](../targets/josm.md)
werden vor dem Absenden der Anfrage alle Vorkommen der Zeichenfolge `{{bbox}}` durch die sichtbare Bounding-Box ersetzt. Damit kann man eine Abfrage wie oben allgemeiner schreiben als [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=nwr%28%7B%7Bbbox%7D%7D%29%3B%0Aout%3B)

    nwr({{bbox}});
    out;

Die Abfrage wirkt dann in der jeweils sichtbaren Bounding-Box.

Beachten Sie, dass einige Elemente in der Darstellung gestrichelt werden.
Das ist der Hinweis auf ein größeres Problem, dem wir [im nächsten Abschnitt](osm_types.md) nachgehen werden:
Es werden zwar formal vollständige Objekte geliefert,
aber diese Objekte haben hier unvollständige Geometrien,
da wir dies in der Abfrage so spezifiziert haben.

## Ausgabebegrenzung

...

## Globale Bounding-Box

...
