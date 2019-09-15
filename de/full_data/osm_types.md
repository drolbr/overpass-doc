Geometrien
==========

Um die verschiedenen Varianten für volle OpenStreetMap-Daten zu erklären,
werden hier die Details des OpenStreetMap-Datenmodells erklärt.

<a name="scope"/>
## Abgrenzung

Die Datentypen sind bereits im [passenden Abschnitt der Einleitung](../preface/osm_data_model.md) eingeführt worden.
Sie sollten hier also bereits mit Nodes, Ways und Relations vertraut sein.

Diese können auf verschiedene Weise dargestellt werden; Ausgabeformate wie JSON oder XML erläutert der Abschnitt [Datenformate](../targets/formats.md).
Ebenfalls dort wird darauf eingegangen, welche Detailgrade hinsichtlich Struktur, Geometrie, Tags, Versionen und Attributierung möglich sind.

Hier geht es darum, wie das Vervollständigen von Ways und Relationen diesen eine nutzbare Geometrie verschafft,
ohne dass die Größe des Abfrageresultats ausufert.

<a name="nodes_ways"/>
## Ways und Nodes

Bei Nodes ist eine nutzbare Geometrie einfach zu bekommen:
Alle Ausgabemodi außer `out ids` und `out tags` haben die Koordinaten der Nodes dabei,
denn diese sind ja per Definition im OSM-Datenmodell Bestandteil der Nodes.

Bei der Ausstattung von Ways mit Geometrie gibt es dagegen bereits mehrere Möglichkeiten:
Im einfachsten Fall kann Ihr Programm ergänzende Koordinaten an den Ways verarbeiten.
Sie können sich den Unterschied z.b. in Overpass Turbo veranschaulichen,
indem Sie die Resultate der beiden nachfolgenden Abfragen im Tab _Data_ (oben rechts) vergleichen:
[Ohne Koordinaten](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out;

und [mit Koordinaten](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out geom;

Im originalen Datenmodell von OpenStreetMap sind an Ways jedoch keine Koordinaten vorgesehen.
Die Ways haben ja bereits Verweise auf Ids von Nodes.
Daher gibt es auch nach wie vor Programme, die Koordinaten an Ways nicht verarbeiten können.
Für diese gibt es zwei Abstufungen, die Geometrie auf traditionellem Weg mitzuliefern.

Einen möglichst geringen Extra-Aufwand an Daten zieht es nach sich, nur die Koordinaten der Nodes anzufordern.
Das Kommando `node(w)` fordert nach der Ausgabe der Ways an, die in den Ways referenzierten Nodes zu finden;
der Modus `out skel` reduziert den Datenumfang auf die Koordinaten pur; der Zusatz `qt` spart den Aufwand für das Sortieren der Ausgabe: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out qt;
    node(w);
    out skel qt;

Ich empfehle wiederum, sich die Ausgabe im Tab _Data_ oben rechts anzuschauen.
Die Nodes sieht man erst, wenn man herunterscrollt.

Das ist zwar schon näher am originalen Datenmodell,
aber es gibt Programme, die auch damit noch nicht zurechtkommen.
Es gibt die Konvention, Nodes strikt vor Ways und die Elemente untereinander nach Id zu sortieren.
Dann müssen wir die Nodes ergänzend zu den Ways laden, bevor wir etwas ausgeben;
dies leistet das Idiom `(._; node(w););` bestehend aus den drei Kommandos `._`, `node(w)` und `(...)`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    (._; node(w););
    out;

Nodes und Ways gemeinsam erläutern wir im finalen Abschnitt.

<a name="rels"/>
## Relationen

Wie schon bei Ways ist der einfachere Fall im Umgang mit Relationen,
dass das Zielprogramm integrierte Geometrie direkt auswerten kann.
Dazu nocheinmal den passenden Direktvergleich:
[Ohne Koordinaten](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out;

und [mit Koordinaten](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom;

Im Gegensatz zu Ways werden die Daten um eine Größenordnung mehr:
Es liegt daran, dass wir in der Variante ohne Koordinaten von Ways nur die Id sehen,
während tatsächlich jeder Way aus mehreren Nodes besteht und damit entsprechend viele Koordinaten hat.

Relations mit überwiegend Ways als Member sind auch der Regelfall.
Es gibt daher den im Absatz _Ausgabebegrenzung_ auf [Bounding-Boxen](bbox.md#crop) beschriebenen Mechanismus,
die zu liefernde Geometrie auf eine Bounding Box einzuschränken: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom({{bbox}});

Auch für Relationen sind jedoch im originalen Datenmodell von OpenStreetMap keine Koordinaten vorgehesen.
Für Programme, die das originale Datenmodell benötigen, gibt es zunächst wieder zwei Abstufungen.
Möglichst nur die Koordinaten bekommt man, indem man die Relationen ausgibt und dann ihre Referenzen auflöst.
Das benötigt zwei Pfade, da Relationen einerseits Nodes als Member haben können,
andererseits Ways und diese wiederum Nodes als Member.
Insgesamt müssten wir dazu vier Kommandos benutzen.
Weil es aber ein so häufiger Fall ist, gibt es dafür ein besonders kurzes Sammelkommando `>`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out qt;
    >;
    out skel qt;

Gegenüber der vorhergehenden Ausgabe hat sich die Datenmenge etwa verdoppelt,
da immer Verweis und Verweisziel enthalten sein müssen.

Die ganz kompatible Variante erfordert noch mehr Datenaufwand.
Diese bildet das Idiom `(._; >;);` aus den drei Kommandos `._`, `>` und `(...)`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    (._; >;);
    out;

Gibt es eine Lösung, um auch hier die Menge erhaltener Koordinaten auf die Bounding-Box zu beschränken?
Da eine Relation in einer Bounding-Box enthalten ist,
wenn mindestens eines ihrer Member in der Bounding-Box enthalten ist,
können wir dies erreichen,
indem wir nach den Membern fragen und zu den Relationen auflösen.
Hier hilft das Kommando `<`:
es ist eine Abkürzung, um alle Ways und Relationen zu finden,
die die vorgegebenen Nodes oder Ways als Member haben.
Wir suchen also nach allen Nodes und Ways in der Bounding-Box.
Dann behalten wir diese per Kommando `._` und suchen alle Relationen,
die diese als Member haben: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    (._; <;);
    out;

Diejenigen Objekte, die Member der Relations sind, erkennt man an der abweichenden Farbe in der Anzeige.
Noch besser findet man die Relationen in der Anzeige _Daten_, indem man ganz herunterscrollt.

Die meisten Member der Relationen laden wir also gar nicht, sondern nur die in der Bounding-Box befindlichen.
Diese Abfrage ist nicht ganz praxistauglich, da wir zu den Ways nicht alle benutzten Nodes laden.
Eine vollständige Fassung gibt es unten im Abschnitt _Alles zusammen_.

<a name="rels_on_rels"/>
## Relationen auf Relationen

Um das Problem mit Relationen auf Relationen vorzuführen,
müssen wir die Bounding-Box nicht einmal besonders vergrößern.
Wir starten mit der Abfrage von oben ohne Relationen auf Relationen: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

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

<a name="full"/>
## Alles zusammen

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
* alle Ways in der Bounding-Box, auch solche, die die Bounding Box nur ohne Node durchschneiden (Selektion Zeile 2, Ausgabe Zeile 3)
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
