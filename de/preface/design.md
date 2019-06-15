Laufzeitmodell
==============

Das Konzept der Overpass API:
Eine Nur-Lesen-Spiegelung der vollen OpenStreetMap-Daten
in eine Datenbank mit zugeschnittener Abfragesprache
zum Zweck, diese nach möglichst jedem Kriterium durchsuchen zu können.

<a name="sequential"/>
## Anweisung für Anweisung

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
und die komplexe Aufgabe durch Aneinanderreihung bewältigt.
Das Herangehen ist dann wie folgt:

* Wähle alle Bahnhöfe im Zielgebiet aus
* Ersetze die Auswahl durch alle Supermärkte in der Nähe dieser Bahnhöfe
* Gib die Liste der Supermärkte aus

Das ergibt Zeile für Zeile folgende Abfrage.
Sie können sie jetzt [ausführen](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=13&Q=nwr%5Bpublic_transport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%3B%0Anwr%5Bshop%3Dsupermarket%5D%28around%3A100%29%3B%0Aout%20center%3B):

    nwr[public_transport=station]({{bbox}});
    nwr[shop=supermarket](around:100);
    out center;

Die Details der Syntax werden später erläutert.

Für einfachere Fälle mag man zwar eine noch einfachere Syntax wünschen,
aber die entstehende Zwei-Zeilen-Lösung spiegelt die klare Aufgabenteilung wider:

    nwr[shop=supermarket]({{bbox}});
    out center;

- Die Auswahlanweisung oder -anweisungen legen fest, _was_ ausgegeben wird.
- Die Ausgabeanweisung _out_ legt fest, _wie_ die angewählten Objekte ausgegeben werden. Details dazu bei den [Ausgabeformaten](../targets/formats.md#faithful)

<a name="statements"/>
## Statements, Filter

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
Diese _Statements_ werden nacheinander in der Reihenfolge ausgeführt,
in der sie aufgeschrieben sind.
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
Die Reihenfolge der Filter spielt keine Rolle,
denn die Filter eines Statements werden gleichzeitig angewendet.

Während ``[shop=supermarket]`` und ``[public_transport=station]`` alle Objekte zulassen,
die ein spezifisches Tag besitzen (Supermärkte im einen Fall, Bahnhöfe im anderen),
dienen ``({{bbox}})`` und ``(around:100)`` der räumlichen Filterung.

Der Filter ``({{bbox}})`` lässt genau solche Objekte zu,
die ganz oder teilweise in der übergebenen Bounding-Box liegen.

Etwas komplizierter arbeitet ``(around:100)``.
Es benötigt eine Vorgabe und lässt genau alle Objekte zu,
die zu irgendeinem der Vorgabe-Objekte einen Abstand von höchstens 100 Metern haben.

<a name="block_statements"/>
## Block-Statements

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

<a name="evaluators"/>
## Evaluators und Deriveds

Nicht geklärt ist damit,
wie im Block-Statement _if_ oder auch _for_ die Bedingungen formuliert werden können.

Der dafür genutzte Mechanismus hilft aber auch für andere Aufgaben.
Man kann damit z.B. eine [Liste aller Straßennamen](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28name%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%3B%0A%20%20out%3B%0A%7D) in einem Gebiet erstellen.
(Die Meldung _Nur unstrukturierte Daten erhalten_ ist normal,
da Overpass Turbo zwar JSON und XML, aber kein CSV verarbeiten kann.
CSV ist jedoch das für eine Liste oder Tabelle nötige Format.
Klicken Sie bitte oben rechts auf den Reiter _Daten_
bzw. auf Mobiltelefonen scrollen Sie bitte nach unten.)

    [out:csv(name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val;
      out;
    }

Die Zeilen 2 und 6 enthalten die einfachen Statements ``way[highway]({{bbox}})`` bzw. ``out``.
Mit ``[out:csv(name)]`` in Zeile 1 wird das Ausgabeformat gesteuert ([siehe dort](../targets/csv.md)).
Die Zeilen 3, 4 und 7 bilden das Block-Statement ``for (t["name"])``;
dieses muss wissen, nach welchem Kriterium es gruppieren soll.

Dies wird durch den _Evaluator_ ``t["name"]`` beantwortet.
Ein _Evaluator_ ist ein Ausdruck,
der im Rahmen der Ausführung eines Statements ausgewertet sind.

Hier handelt es sich um einen Ausdruck, der pro Element ausgewertet wird,
da _for_ pro Element Informationen benötigt.
Der Ausdruck ``t["name"]`` wertet zu einem Objekte den Wert von dessen Tag mit Schlüssel _name_ aus.
Hat das Objekt kein Tag mit Schlüssel _name_,
so liefert der Ausdruck eine leere Zeichenkette als Wert.

Zeile 5 enthält mit ``_.val`` ebenfalls einen _Evaluator_.
Hier geht es darum, den auszugebenden Wert zu erzeugen.
Das Statement _make_ erzeugt stets nur ein Objekt aus potentiell vielen Objekten,
daher darf der Wert von ``_.val`` nicht von einzelnen Objekten abhängen.
Der Evalutor ``_.val`` liefert innerhalb einer Schleife den Wert des aktuellen Schleifenausdrucks,
hier also den Wert des Tags _name_ aller hier einschlägigen Objekte.

Wenn ein unabhängiger Wert erwartet, aber ein objektabhängiger Wert angegeben wird,
führt dies zu einer Fehlermeldung.
Das passiert z.B., wenn wir uns die Längen der Straßen ausgeben lassen wollten:
[Probieren](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dlength%28%29%3B%0A%20%20out%3B%0A%7D) Sie es bitte aus:

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=length();
      out;
    }

Die verschiedene Segmente einer Straße gleichen Namens können verschiedene Längen haben.
Wir können dies beheben, indem wir vorgeben, auf welche Art die Objekte zusammengefasst werden sollen.
Häufig möchte man [eine Liste](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dset%28length%28%29%29%3B%0A%20%20out%3B%0A%7D):

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=set(length());
      out;
    }

In diesem speziellen Fall dürfte aber Summieren [sinnvoller sein](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dsum%28length%28%29%29%3B%0A%20%20out%3B%0A%7D):

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=sum(length());
      out;
    }

Das Statement _make_ erzeugt immer genau ein neues Objekt, ein sogenanntes _Derived_ (von englisch: abgeleitet).
Warum überhaupt ein Objekt, warum nicht einfach ein OpenStreetMap-Objekt?
Die Gründe dafür variieren von Anwendung zu Anwendung:
hier brauchen wir etwas, das wir ausgeben können.
In anderen Fällen möchte man Tags von OpenStreetMap-Objekten ändern und entfernen
oder die Geometrie des OpenStreetMap-Objekts vereinfachen
oder braucht einen Träger für spezielle Information.
Scheinbare OpenStreetMap-Objekte müssen den Regeln für OpenStreetMap-Objekte folgen
und lassen daher viele hilfreiche Freiheiten nicht zu.
Vor allem aber könnten sie mit echten OpenStreetMap-Objekten verwechselt und irrtümlich hochgeladen werden.

Die erzeugten Objekte können Sie sehen, wenn Sie als Ausgabeformat es bei XML [belassen](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=way%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dsum%28length%28%29%29%3B%0A%20%20out%3B%0A%7D):

    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=sum(length());
      out;
    }

<a name="sets"/>
## Mehrere Auswahlen gleichzeitig

In vielen Fällen kommt man aber mit einer einzigen Auswahl nicht aus.
Daher können Auswahlen auch in benannten Variablen abgelegt
und so mehrere Auswahl gleichzeitig behalten werden.

Wir wollen alle Objekte der einen Art finden,
die nicht in der Nähe von Objekten der anderen Art sind.
Praxisnähere Beispiel sind dabei häufig eher Suche nach Fehlern,
z.B. Bahnsteige ohne Gleise oder Adressen ohne Straße.
Wir werden uns aber jetzt nicht mit Feinheiten des Taggings auseinandersetzen.

Wir ermitteln daher alle Supermärkte,
die [nicht in der Nähe](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Bpublic%5Ftransport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%2D%3E%2Eall%5Fstations%3B%0A%28%0A%20%20nwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20%2D%20nwr%2E%5F%28around%2Eall%5Fstations%3A300%29%3B%0A%29%3B%0Aout%20center%3B) von Bahnhöfen sind:

    nwr[public_transport=station]({{bbox}})->.all_stations;
    (
      nwr[shop=supermarket]({{bbox}});
      - nwr._(around.all_stations:300);
    );
    out center;

In Zeile 3 wählt das Statement ``nwr[shop=supermarket]({{bbox}})`` alle Supermärkte in der Bounding-Box aus.
Wir wollen davon eine Teilmenge abziehen und verwendet daher ein Block-Statement vom Typ _difference_;
dieses ist an den drei Komponenten ``(`` in Zeile 3, ``-`` in Zeile 4 und ``);`` in Zeile 5 zu erkennen.

Wir müssen Supermärkte in der Nähe von Bahnhöfen auswählen.
Dazu müssen wir wie oben vorher die Bahnhöfe gewählt haben;
wir brauchen aber auch alle Supermärkte als Auswahl.
Daher leiten wir die Auswahl der Bahnhöfe durch die getrennte _Set-Variable_ ``all_stations``.
Sie wird in Zeile 1 von einem gewöhnlichen Statement ``nwr[public_transport=station]({{bbox}})`` mittels der Syntax ``->.all_stations`` in eben diese Variable geleitet.
Der Zusatz ``.all_stations`` in ``(around.all_stations:300)`` sorgt dann dafür,
dass diese Variable als Quelle anstelle der letzten Auswahl verwendet wird.

Damit wäre ``nwr[shop=supermarket]({{bbox}})(around.all_stations:300)`` das richtige Statement,
um die genau zu entfernenen Supermärkte anzuwählen.
Zur Verkürzung der Laufzeit nutzen wir aber lieber die Auswahl des unmittelbar vorhergehenden Statements in Zeile 3 - dort stehen ja genau die Supermärkte in der Bounding-Box drin.
Dies passiert mittels des _Filters_ ``._``.
Es schränkt die Auswahl auf solche Ergebnisse ein,
die beim Start des Statements in der Eingabe stehen.
Da wir hier die Standardeingabe benutzt haben,
sprechen wir sie über ihren Namen ``_`` (einfacher Unterstrich) an.

Der Ablauf mit Datenfluss nocheinmal im Detail:

* Vor Beginn der Ausführung sind alle Auswahlen leer.
* Zuerst wird Zeile 1 ausgeführt.
  Wegen ``->.all_stations`` sind danach alle Bahnhöfe als ``all_stations`` ausgewählt;
  die Standardauswahl bleibt dagegen leer.
* Zeilen 2 bis 5 sind ein Block-Statement vom Typ _difference_,
  und dieses führt zunächst seinen Ausweisungblock aus.
  Daher wird als nächstes Zeile 3 ``nwr[shop=supermarket]({{bbox}})`` ausgeführt.
  Zeile 3 hat keine Umleitung,
  so dass danach alle Supermärkte in der Standard-Auswahl ausgewählt sind.
  Die Auswahl ``all_stations`` wird nicht erwähnt und bleibt daher erhalten.
* Das Block-Statement _difference_ greift das Ergebnis seines ersten Operanden ab,
  also von Zeile 3.
* Zeile 4 benutzt die Standarauswahl per ``._`` als Einschränkung für sein Ergebnis,
  und zusätzlich wird per ``(around.all_stations:300)`` die Auswahl ``all_stations`` als Quelle für die Umkreissuche _around_ herangezogen.
  Das Ergebnis ist die neue Standard-Auswahl und ersetzt daher die vorherige Standard-Auswahl.
  Die Auswahl ``all_stations`` bleibt unverändert.
* Das Block-Statement _difference_ greift das Ergebnis seines ersten Operanden ab,
  also von Zeile 4.
* Das Block-Statement _difference_ bildet jetzt die Differenz der beiden abgegriffenen Ergebnisse.
  Da nichts anderes gefordert ist, wird das Ergebnis die neue Standard-Auswahl.
  Die Auswahl ``all_stations`` bleibt nach wie vor unverändert.
* Zuletzt wird Zeile 5 ausgeführt.
  Ohne besondere Angabe verwendet ``out`` als Quelle die Standard-Auswahl.
