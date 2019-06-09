Und- und Oder-Verknüpfung
=========================

Suche nach Objekten anhand mehrerer Tags.

<a name="intersection"/>
## Und-Verknüpfung

Zunächst wollen wir zwei oder mehr Bedingungen so verknüpfen,
dass nur Objekte gefunden werden, die alle Bedingungen erfüllen.
Einige Beispiele für Und-Verknüpfungen haben wir bereits gesehen:
[Tag und Bounding-Box](per_tag.md#local),
[Tag und Gebiet, Tag und zwei Gebiete sowie zwei Tags](chaining.md#lateral)

Wir arbeiten und an dem Standardfall entlang,
einen Geldautomaten finden zu wollen.
Es gibt dafür das Tag ``amenity`` mit Wert ``atm``.
Wegen der großen Anzahl hat das [Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Bamenity%3Datm%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) eine kleine Bounding-Box:

    nwr[amenity=atm]({{bbox}});
    out center;

Es werden also ein Filter nach einem Tag (hier ``amenity=atm``) mit einem Filter nach einer Bounding-Box kombiniert,
indem man beide Filter einfach hintereinander schreibt.

Die Reihenfolge spielt dabei [keine Rolle](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%28%7B%7Bbbox%7D%7D%29%5Bamenity%3Datm%5D%3B%0Aout%20center%3B):

    nwr({{bbox}})[amenity=atm];
    out center;

Es gibt aber eine weitere Möglichkeit Geldautomaten einzutragen:
Oft sind sie Bestandteil einer Bankfiliale;
sie werden dann als [Eigenschaft der Filiale](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Bamenity%3Dbank%5D%28%7B%7Bbbox%7D%7D%29%5Batm%3Dyes%5D%3B%0Aout%20center%3B) eingetragen:

    nwr[amenity=bank]({{bbox}})[atm=yes];
    out center;

Wie in allen anderen Beispielen können auch hier die Filter innerhalb der _Query_-Anweisung [beliebig gereiht](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Batm%3Dyes%5D%5Bamenity%3Dbank%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) werden:

    nwr[atm=yes][amenity=bank]({{bbox}});
    out center;

Wie man beide Mapping-Arten kombiniert, wird im [nächsten Abschnitt](union.md#union) erläutert.
Erst soll noch klargestellt werden,
dass beliebig viele Tags oder sonstige Kriterien kombiniert werden können:
Lassen Sie zum Ausprobieren [im folgenden Beispiel](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=9&Q=way%0A%20%20%5Bname%3D%22Venloer%20Stra%C3%9Fe%22%5D%0A%20%20%5Bref%3D%22B%2059%22%5D%0A%20%20%2850%2E96%2C6%2E85%2C50%2E98%2C6%2E88%29%0A%20%20%5Bmaxspeed%3D50%5D%0A%20%20%5Blanes%3D2%5D%0A%20%20%5Bhighway%3Dsecondary%5D%0A%20%20%5Boneway%3Dyes%5D%3B%0Aout%20geom%3B) mal ein oder mehrere Filter weg;
es wird sich immer das Ergebnis ändern, da jeder der sechs Tag-Filter und auch die Bounding-Box Einfluss hat:

    way
      [name="Venloer Straße"]
      [ref="B 59"]
      (50.96,6.85,50.98,6.88)
      [maxspeed=50]
      [lanes=2]
      [highway=secondary]
      [oneway=yes];
    out geom;

Auf überraschende Weise trifft das übrigens auch auf unser Geldautomaten-Beispiel zu:
Oft reicht es, gezielt nach einem speziellen Tag zu suchen,
denn an allen Objekten mit dem speziellen Tag steht auch das allgemeine Tag:

* An über 95% aller Objekte mit einem Tag ``admin_level`` steht [laut Taginfo](https://taginfo.openstreetmap.org/tags/boundary=administrative#combinations) (Zahl und Balken in den Spalten ganz rechts) das Tag ``boundary=administrative``.
* An über 99% aller Objekte mit einem Tag ``fence_type`` steht [laut Taginfo](https://taginfo.openstreetmap.org/tags/barrier=fence#combinations) das Tag ``barrier=fence``.

Eine [Suche nach](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=14&Q=nwr%5Bbarrier%3Dfence%5D%5Bfence%5Ftype%3Dwood%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B) Zäunen (``barrier=fence``) mit Eigenschaft ``fence_type=wood`` liefert dann auch praktisch das gleiche Ergebnis ...

    nwr[barrier=fence][fence_type=wood]({{bbox}});
    out geom;

... wie eine [Suche nach](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=14&Q=nwr%5Bfence%5Ftype%3Dwood%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B) nur ``fence_type=wood``:

    nwr[fence_type=wood]({{bbox}});
    out geom;

Bei den Geldautomaten haben wir dagegen mehr Treffer,
wenn wir nur nach ``atm=yes`` [suchen](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Batm%3Dyes%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B):

    nwr[atm=yes]({{bbox}});
    out center;

Fachlich ist das durchaus überzeugend:
Geldautomaten können eben auch an Tankstellen, in Einkaufszentren oder anderen Gebäuden stehen.

<a name="union"/>
## Oder-Verknüfung

Wir wollen nun zwei oder mehr Bedingungen so verknüpfen,
dass alle Objekte gefunden werden, die mindestens eine der Bedingungen erfüllen.
Auch hier haben wir schon einige Beispiele gesehen:
[Alle Objekte in Bounding-Boxen](../targets/formats.md#faithful),
[Ergänzung benutzter Objekte](chaining.md#topdown),
[Als Beispiel eines Block-Statements](../preface/design.md#block_statements)

Für unser Beispiel von oben müssen wir das Problem lösen,
sowohl alleine stehende Geldautomaten als auch solche in Banken [zu finden](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=%28%0A%20%20nwr%5Bamenity%3Datm%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20nwr%5Batm%3Dyes%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%29%3B%0Aout%20center%3B):

    (
      nwr[amenity=atm]({{bbox}});
      nwr[atm=yes]({{bbox}});
    );
    out center;

Unsere Verknpüfung übernimmt das _Union_-Statement in den Zeilen 1 bis 4.
Es führt seinen inneren Block aus.
Zeile 2 schreibt als Ergebnis in das Set ``_`` alle Objekte,
die ein Tag ``amenity`` mit Wert ``atm`` haben und in der von [Overpass-Turbo](../targets/turbo.md#convenience) befüllten Bounding-Box liegen.
_Union_ behält eine Kopie dieses Ergebnisses.
Zeile 3 schreibt als Ergebnis in das Set ``_`` alle Objekte,
die ein Tag ``atm`` mit Wert ``yes`` haben und in der erneut von _Overpass-Turbo_ befüllten Bounding-Box liegen.
Danach schreibt _Union_ ins Set ``_`` als Ergebnis alle Objekte,
die in mindestens einem der Teilergebnisse vorkommen - die gewünschte _Oder-Verknüpfung_.

Ein gängiger Fall ist es,
eine recht lange Liste an Werten eines Tags prüfen zu müssen.
Möchte man z.B. alle PKW-tauglichen Straßen finden,
so entsteht an Werten für ``highway`` eine Liste der Art
``motorway``, ``motorway_link``,
``trunk``, ``trunk_link``,
``primary``, ``secondary``, ``tertiary``,
``unclassified``, ``residential``.
Mit _Union_ kann man dies [abfragen als](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=15&Q=%28%0A%20%20way%5Bhighway%3Dmotorway%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dmotorway%5Flink%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dtrunk%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dtrunk%5Flink%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dprimary%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dsecondary%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dtertiary%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dunclassified%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20way%5Bhighway%3Dresidential%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%29%3B%0Aout%20geom%3B):

    (
      way[highway=motorway]({{bbox}});
      way[highway=motorway_link]({{bbox}});
      way[highway=trunk]({{bbox}});
      way[highway=trunk_link]({{bbox}});
      way[highway=primary]({{bbox}});
      way[highway=secondary]({{bbox}});
      way[highway=tertiary]({{bbox}});
      way[highway=unclassified]({{bbox}});
      way[highway=residential]({{bbox}});
    );
    out geom;

Man kann aber auch die im vorherigen Abschnitt vorgestellten [regulären Ausdrücke](per_tag.md#regex) benutzen
und [braucht nur noch](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=15&Q=way%5Bhighway%7E%22%5E%28motorway%7Cmotorway%5Flink%7Ctrunk%7Ctrunk%5Flink%7Cprimary%7Csecondary%7Ctertiary%7Cunclassified%7Cresidential%29%24%22%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B):

    way({{bbox}})
      [highway~"^(motorway|motorway_link|trunk|trunk_link|primary|secondary|tertiary|unclassified|residential)$"];
    out geom;

Zeilen 1 und 2 bilden ein _Query_-Statement für _Ways_ mit zwei Filtern;
der Filter ``({{bbox}})`` für Bounding-Boxen [ist bekannt](../full_data/bbox.md#filter).
Vom anderen Filter ist die Tilde ``~`` das wichtigste Zeichen;
sie passt auf Objekte, die ein Tag mit Key links von der Tilde, hier ``highway``, und mit einem Wert tragen,
der auf den Ausdruck rechts von der Tilde passt.

Die Syntax mit Caret ``^`` am Anfang und ``$`` am Ende kennzeichnet,
dass der Wert im Ganzen und nicht nur die bestmögliche Teilzeichenkette des Wertes passen muss.
Der senkrechte Strich wiederum trennt verschiedene Alternativen voneinander,
hier insgesamt 9 potentielle Werte für das Tag.

Der Abschnitt zu [regulären Ausdrücken](per_tag.md#regex) enthält mehr Beispiele.

In unserem Geldautomaten-Beispiel haben wir allerdings keinen gemeinsamen Key.
Die Regulären Ausdrücke helfen uns daher hier nicht.

Was sich aber wiederholt, ist die Bedingung auf die Bounding-Box.
Will man die Wiederholung vermeiden,
so kann man die gemeinsame Bedingung vorziehen und das Ergebnis in einem Set zwischenspeichern;
``all`` ist ein sprechender Name dafür.
Oft verkürzt es auch die Laufzeit der [Abfrage](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%28%7B%7Bbbox%7D%7D%29%2D%3E%2Eall%3B%0A%28%0A%20%20nwr%2Eall%5Bamenity%3Datm%5D%3B%0A%20%20nwr%2Eall%5Batm%3Dyes%5D%3B%0A%29%3B%0Aout%20center%3B):

    nwr({{bbox}})->.all;
    (
      nwr.all[amenity=atm];
      nwr.all[atm=yes];
    );
    out center;

Dem _Union_-Statement in den Zeile 2 bis 5 ist jetzt ein _Query_-Statement in Zeile 1 vorangestellt.
Dort werden alle Objekte, die in der Bounding-Box liegen, im Set ``all`` abgelegt.
Dieses Set wird im _Union_-Block zweimal benutzt:
In Zeile 3 und Zeile 4 ist jeweils ``.all`` ein Filter, der das Ergebnis auf den Inhalt von ``all`` beschränkt.
Es werden also in Zeile 3 genau die Objekte gefunden,
die im Set ``all`` liegen und die ein Tag ``amenity`` mit Wert ``atm`` besitzen.
In Zeile 4 werden genau die Objekte gefunden,
die im Set ``all`` liegen und die ein Tag ``atm`` mit Wert ``yes`` besitzen.

Warum nehmen wir nicht einfach das Set ``_``?
Zwar wäre dies technisch möglich.
Allerdings müssten wir dann bei jeder Zeile im Block daran denken, die Ausgabe umzuleiten.
Das zu vergessen ist dann eine beliebte Quelle von Fehlern.

<a name="full"/>
## Gemischte Logik

<!--
highway mixed + name
-->

...

<!-- Hinweis auf Evals -->
<!-- [](../preface/design.md#evaluators) -->

<!-- Around, mehrere Areas -->

<!-- Normalformen -->
<!-- Negation? -->
