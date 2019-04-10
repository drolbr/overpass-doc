Weitere Map-APIs
================

Es gibt neben gezielt konfigurierter Abfragen auch einige API-Aufrufe,
die nur Koordinaten brauchen und dann bereits Daten in jeweils einer speziellen Konfiguration liefern.

## Der Export der Main Site

Im [Export-Tab](https://openstreetmap.org/export) der [OSM Main Site](https://openstreetmap.org) gibt es eine Funktion,
um alle Daten mittels Overpass API zu exportieren.
Diese bildet das Verhalten des Exports direkt von der Originaldatenbank nach,
kann aber quantitativ deutlich mehr Elemente exportieren.
Dahinter steckt eine einfache URL:

[/api/map?bbox=-0.001,51.477,0.001,51.478](https://overpass-api.de/api/map?bbox=-0.001,51.477,0.001,51.478)

Die Reihenfolge der Koordinaten orientiert sich hier an älteren Schnittstellen.
Sie weicht daher von der Bounding-Box ab.
Es folgen westlicher Rand, südlicher Rand, östlicher Rand und nördlicher Rand aufeinander.

Als Abfrage wird ausgeführt [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=17&Q=%28%20node%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%28bn%29%3B%0A%20%20node%28w%29%3B%20%29%3B%0A%28%20%2E%5F%3B%0A%20%20%28%20rel%28bn%29%2D%3E%2Ea%3B%0A%20%20%20%20rel%28bw%29%2D%3E%2Ea%3B%0A%20%20%29%3B%0A%20%20rel%28br%29%3B%0A%29%3B%0Aout%20meta%3B)

    ( node({{bbox}});
      way(bn);
      node(w);
    );
    ( ._;
      ( rel(bn)->.a;
        rel(bw)->.a;
      );
      rel(br);
    );
    out meta;

D.h. es sind enthalten:

1. alle Nodes in der gegebenen Bounding-Box
1. alle Ways, die mindestens eine Node in der Bounding-Box haben
1. alle von diesen Ways benutzte Nodes
1. alle Relationen, die eines oder mehrere Elemente unter 1.-3. als Member enthalten
1. alle Relationen, die eine oder mehrere Relation von 4. als Member enthalten

und es wird davon der Detailgrad mit Version und Zeitstempel ausgegeben.

Nicht enthalten sind Ways, die die Bounding-Box nur durchlaufen ohne dort einen Node zu haben.


## Xapi

...