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
sowohl alleine stehende Geldautomaten als auch solche in Banken [zu finden](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=%28%0A%20%20nwr%5Bamenity%3Datm%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20nwr%5Batm%3Dyes%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%29%3B%0Aout%20center%3B):

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

...

<!-- Typenmischung -->
<!-- Hinweis auf Regex -->
<!-- Hinweis auf Evals -->
<!-- Around, mehrere Areas -->

<a name="full"/>
## Gemischte Logik

...

<!--
highway mixed + name
Around
Kreuzung
-->
<!-- Normalformen -->
<!-- Negation? -->
<!-- Hinweis auf Evals -->
