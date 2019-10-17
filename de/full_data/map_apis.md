Weitere Map-APIs
================

Es gibt neben Abfragen in Overpass QL auch einige fixe API-Aufrufe.
Die meisten von diesen erfüllen jediglich Zwecke der Rückwärtskompatibilität,
und alle werden emuliert, indem die semantisch äquivalenten Overpass-QL-Abfragen ausgeführt werden.
Diese API-Aufrufe brauchen daher nur Koordinaten.

## Der Export der Main Site

Im [Export-Tab](https://openstreetmap.org/export) der [OSM Main Site](https://openstreetmap.org) gibt es eine Funktionalität,
um alle Daten mittels Overpass API zu exportieren.
Diese bildet das Verhalten des Exports direkt von der Originaldatenbank nach,
kann aber quantitativ deutlich mehr Elemente exportieren.
Dahinter steckt eine einfache URL:

[/api/map?bbox=-0.001,51.477,0.001,51.478](https://overpass-api.de/api/map?bbox=-0.001,51.477,0.001,51.478)

Die Reihenfolge der Koordinaten orientiert sich hier an älteren Schnittstellen.
Sie weicht daher von der Bounding-Box ab.
Es folgen westlicher Rand, südlicher Rand, östlicher Rand und nördlicher Rand aufeinander.

Als Abfrage wird ausgeführt [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=17&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
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
Wie man dieses Problem behebt,
ist im [vorhergehenden Unterkapitel](osm_types.md#full) erläutert, insbesondere im Abschnitt _Alles zusammen_.

## Xapi

...
