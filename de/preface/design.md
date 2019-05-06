Laufzeitmodell
==============

Das Konzept der Overpass API:
Eine Nur-Lesen-Spiegelung der vollen OpenStreetMap-Daten
in eine Datenbank mit zugeschnittener Abfragesprache
zum Zweck, diese nach möglichst jedem Kriterium durchsuchen zu können.

TODO: Diagramm mit Komponenten!

# Anweisung für Anweisung

Die meisten fortgeschrittenen Anwendungsfälle für Abfragen erfordern relative Auswahlen.
Ein gutes Beispiel sind Supermärkte,
die nahe an einem Bahnhof liegen.
Die Supermärkte sind mit den Bahnhöfen nur dadurch verbunden,
dass sie räumlich nahe beieinander sind.

Dem Satzbau zufolge suchen wir eigentlich erst Supermärkte,
suchen dann an jedem Supermarkt nach Bahnhöfen in der Nähe
und behalten nur Supermärkte in der Auswahl, bei denen wir einen Bahnhof gefunden haben.
Diese Herangehensweise führt bei natürlicher Sprache schnell zu Relativsatzungetümen;
auch in formaler Sprache wird das nicht besser.

Daher folgt die Abfragesprache der Ovepass API stattdessen einem Schritt-für-Schritt-Paradigma,
der sogenannten _imperativen Programmierung_.
Zu jedem Zeitpunkt wird nur eine überschaubare Aufgabe gelöst,
und die komplexe Aufgabe durch Aneinanderreihung erreicht.
Das Herangehen ist dann wie folgt:

* Wähle alle Bahnhöfe im Zielgebiet aus
* Ersetze die Auswahl durch alle Supermärkte in der Nähe dieser Bahnhöfe
* Gib die Liste der Supermärkte aus

Das ergibt Zeile für Zeile folgende Abfrage.
Sie können Sie jetzt [ausführen](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Bpublic_transport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%3B%0Anwr%5Bshop%3Dsupermarket%5D%28around%3A100%29%3B%0Aout%20center%3B):

    nwr[public_transport=station]({{bbox}});
    nwr[shop=supermarket](around:100);
    out center;

Die Details der Syntax werden später erläutert.

Für einfachere Fälle mag man zwar eine noch einfachere Syntax wünschen,
aber die Zwei-Zeilen-Lösung spiegelt die klare Aufgabenteilung wider:

- Die Auswahlanweisung oder -Anweisungen legen fest, _was_ ausgegeben wird.
- Die Ausgabeanweisung _out_ legt fest, _wie_ die angewählten Objekte ausgegeben werden. Details dazu bei den [Ausgabeformaten](../targets/formats.md)

# Statements, Conditionals

Wir vergleichen die Abfrage nach einfach nur den Supermärkten im Sichtbarkeitsbereich

    nwr[shop=supermarket]({{bbox}});
    out center;

mit der obigen Abfrage

    nwr[public_transport=station]({{bbox}});
    nwr[shop=supermarket](around:100);
    out center;

um die einzelnen Komponenten zu identifizieren.

Das wichtigste Zeichen ist das Semikolon; es beendet jeweils ein _Statement_.
Zeilenumbrüche, Leerzeichen (und Tabulatoren) sind dafür und auch für die Syntax insgesamt irrelevant.
Im beiden Abfragen gibt es also zusammen vier Statements:

* ``nwr[shop=supermarket]({{bbox}});``
* ``nwr[public_transport=station]({{bbox}});``
* ``nwr[shop=supermarket](around:100);``
* ``out center;``

Das Statement ``out center`` ist ein Ausgabestatement ohne weitere Unterstrukturen.
Die Möglichkeiten, das Ausgabeformat zu steuern, werden im Abschnitt [Datenformate](../targets/formats.md) thematisiert.

Die übrigen _Statements_ sind alle _query_-Statements, d.h. sie dienen dazu Objekte anzuwählen.
Dies gilt für alle mit ``nwr`` beginnenden Statements und weitere spezielle Schlüsselwörter.
Sie haben hier mehrfach auftretende Unterstrukturen:

* ``[shop=supermarket]`` und ``[public_transport=station]``
* ``({{bbox}})``
* ``(around:100)``

Alle Unterstrukturen eines _query_-Statements filtern die anzuwählenden Objekte und heißen daher _Filter_.
Es ist möglich, beliebig viele Filter in einem Statement zu kombinieren;
das _query_-Statement wählt genau solche Objekte an,
die alle Filter erfüllen.
Die Reihenfolge der Filter spielt keine Rolle.

Während ``[shop=supermarket]`` und ``[public_transport=station]`` alle Objekte zulassen,
die ein spezifisches Tag besitzen (Supermärkte im einen Fall, Bahnhöfe im anderen),
dienen ``({{bbox}})`` und ``(around:100)`` der räumlichen Filterung.

Der Filter ``({{bbox}})`` lässt genau solche Objekte zu,
die ganz oder teilweise in der übergebenen Bounding-Box liegen.

Etwas komplizierter arbeitet ``(around:100)``.
Es benötigt eine Vorgabe und lässt genau alle Objekte zu,
die zu irgendeinem der Vorgabe-Objekte einen Abstand von höchstens 100 Metern haben.

# Block-Statements

Wie kann man eine Oder-Verknpüfung erreichen?
[Auf diese Weise](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=%28%0A%20%20nwr%5Bpublic%5Ftransport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20nwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%29%3B%0Aout%20center%3B) findet man alle Objekte, die ein Supermarkt _oder_ ein Bahnhof sind:

    (
      nwr[public_transport=station]({{bbox}});
      nwr[shop=supermarket]({{bbox}});
    );
    out center;

Hier bilden die beiden _query_-Statements einen Block innerhalb einer größeren Struktur.
Die durch die Klammern gekennzeichnete Struktur heißt daher _Block-Statement_.

Diese spezielle Block-Struktur heißt _union_,
und sie dient dazu, mehrere Statements so zu verknüpfen,
dass sie alle Objekte anwählt,
die in irgendeinem der Statements im Block gefunden werden.
Es muss mindestens eine und es können beliebig viele Statements im Block stehen.

Es gibt zahlreiche weitere Block-Statements:

* Das Block-Statement _difference_ erlaubt, eine Auswahl aus einer anderen auszuschneiden.
* _if_ führt seinen Block nur aus, wenn die im Kopf stehende Bedingung erfüllt ist.
  Auch ein zweite _else_-Block ist möglich.
* _foreach_ führt seinen Block einmal pro Objekt in seiner Eingabe aus.
* _for_ fasst die Objekte erst zu Gruppen zusammen und führt dann seinen Block einmal pro Gruppe aus.
* _complete_ erfüllt Aufgaben einer _while_-Schleife.
* Weitere Block-Statements erlauben es, gelöschte oder überholte Daten wieder zurückzuholen.

# Evaluators und Deriveds

Nicht geklärt ist damit,
wie im Block-Statement _if_ oder auch _for_ die Bedingungen formuliert werden können.

Der dafür genutzte Mechanismus hilft aber auch für andere Aufgaben.
Man kann damit z.B. eine [Liste aller Straßennamen](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28name%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%3B%0A%20%20out%3B%0A%7D) in einem Gebiet erstellen:

    [out:csv(name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val;
      out;
    }

...

# Mehrere Auswahlen gleichzeitig

- Set-Entsorgung in Union

- Ausführungsmodell

  Standard-Conditionals als Sofort-Beispiele?

  Datenfluss
  Umgang mit Sets
