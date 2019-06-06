Und- und Oder-Verknüpfung
=========================

Suche nach Objekten anhand mehrerer Tags.

<a name="intersection"/>
## Und-Verknüpfung

Zunächst wollen wir zwei oder mehr Bedingungen verknpüfen,
so dass nur Objekte gefunden werden, die alle Bedingungen erfüllen.
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

<a name="union"/>
## Oder-Verknüfung

...

<!-- einfacher Fall -->
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
