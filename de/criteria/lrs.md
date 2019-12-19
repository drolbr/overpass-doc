Semikolon-Listen
================

Hilfsmittel zum Umgang mit Tags, die mehrere Semikolon-getrennte Werte enthalten.

<a name="intro"/>
## Mehrere Werte

In manchen Fällen ist es nötig,
in OpenStreetMap zu einem _Key_ mehrere _Values_ zu erfassen.
Ein Beispiel sind mehrstöcktige Strukturen:
Auch wenn jedes Element für sich meist nur auf einer Etage liegt,
so ist doch der Zweck von Treppen und Aufzügen, mehrere Etagen zu verbinden
und dementsprechend in beiden Etagen Raum einzunehmen.

Entsprechendes gilt für Straßen oder sonstige Verkehrswege,
wenn der Betreiber für einen Abschnitt mehrere Nummern vergeben hat.
Aber auch mehrere Hausnummern an einem Grundstück oder Gebäude [kommen vor](https://overpass-turbo.eu/?lat=51.5&lon=0.0&zoom=13&Q=CGI_STUB):

    nwr["addr:housenumber"~";"]({{bbox}});
    out center;

Der de-facto-Standard für mehrere _Values_ zum gleichen _Key_ ist es,
die Werte durch Semikolons getrennt im _Value_ aneinanderzureihen.
Das ist aus mehreren Gründen ein Problem:

Zunächst einmal ist das Semikolon ein zulässiges Zeichen im _Value_,
so dass ein einzelner _Value_ irrtümlich aufgespalten werden könnte,
wenn die Software grundsätzlich an Semikolons teilt.
Das muss nicht zwangsläufig noch in OSM passieren:
In beliebten Formaten wie CSV wird gerne auch das Semikolon als Trennzeichen verwendet.

Dann wirft die Aneinanderreihung die Frage auf, ob die Reihenfolge der Elemente eine Rolle spielt.
Durch Beispiele wie den Values `-2;-1` und `-1;-2` für das Tag mit Key _level_
drängt sich die Antwort Nein auf.
Dagegen legen Keys wie für Seezeichen oder Wanderzeichen nahe,
dass `red;white;blue` etwas anderes ist als `blue;red;white`.

Die Reihenfolge zu speichern ist aber aufwendig:
Schon für 15 Dinge bräuchte man im Idealfall nur 2 Byte, um das Vorhandensein zu speichern,
aber 5 Byte, um die tatsächliche Reihenfolge zu speichern.

Andere Fragen sind:

* Sind -1 und -1.0 die gleichen Werte?
* Was ist mit führenden oder nachfolgenden Leerzeichen?
* Was bedeutet es, wenn zwei Semikolons direkt nacheinander stehen?

Für die Overpass API habe ich daher eine Konvention festgesetzt,
die bestmöglich mit der heutigen tatsächlichen Nutzung harmoniert:

_Alle Values von Tags werden zunächst im Ganzen und Semikolons in keinster Weise speziell behandelt,
solange nicht der Wert an eine Semikolon-verarbeitende Funktion übergeben wird.
Solche Funktionen können führende oder folgende Leerzeichen ignorieren.
Falls eine Liste ausschließlich Zahlen enthält,
können die Funktionen gleiche Zahlen gleichsetzen und nach Zahlwert sortieren._

In den folgenden Abschnitten stellen wir die Funktionen anhand typischer Problemstellungen vor:

* Wie lassen sich alle Objekte finden, in denen im Tag X ein Wert Y vorkommt?
* Wie lassen sich alle Objekte finden, in denen im Tag X zumindest einer von mehreren Werten vorkommt?
* Wie lassen sich alle Werte auflisten?

Die Funktionen zur Datenanalyse erzeugen mitunter auch Semikolon-getrennte Listen.
Dies und der Umgang damit wird aber dort erläutert.

<a name="single"/>
## Einen Wert finden

Wir versuchen, an einer der wichtigsten U-Bahn-Stationen Londons (_Bank_ und _Monument_)
alle Treppen zu finden, die Ebene `-2` berühren.
Die Suche nach _nur dem Value_ [findet nichts](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way[highway=steps][level=-2]({{bbox}});
    out center;

Infrage käme an dieser Stelle zwar die Suche per regulären Ausdruck.
Aber das ist bestenfalls äußerst unhandlich und wird hier nicht vertieft.
Es sei darauf hingewiesen,
dass ein solcher regulärer Ausdruck leicht auch die hier vorkommenden Werte `-2.3` oder `-2.7` ungewollt findet.

Exakt die Objekte, die den Wert `-2` direkt oder in einer Semikolon-Liste haben,
[selektiert](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB) dagegen die Semikolon-Funktion `lrs_in`:

    way[highway=steps]({{bbox}})
      (if:lrs_in("-2",t["level"]));
    out center;

Objekte mit _Values_ wie `-2;-1` oder `-3;-2` findet der Request also ebenso wie den _Value_ `-2` alleine.

Im einzelnen:
Zeile 1 und 2 sind zusammen ein _Query_-Statement mit insgesamt 3 Filtern;
uns interessiert hier der Filter `(if:lrs_in("-2",t["level"]))`.
Dabei ist `(if:...)` zunächst einmal der generische Filter,
der für jedes in Frage kommende Objekt [den Evaluator](../preface/design.md#evaluators) in seinem Inneren auswertet;
es werden nur die Objekte selektiert, für den der Evaluator zu etwas anderem als `0`, `false` oder dem leeren Wert auswertet.
Wir untersuchen die Objekte mit dem Evaluator `lrs_in("-2",t["level"])`;
dieser hat seinerseits zwei Argumente:

* das erste Argument, hier die Konstante `-2`, ist der zu findende Wert
* das zweite Argument, hier `t["level"]`, ist die zu durchsuchende Liste

Insgesamt steht hier also als Anweisung:
Suche alle _Ways_ (`way`) innerhalb der Bounding-Box (`({{bbox}})`) mit _Value_ `steps` zum _Key_ `highway`,
die zum Key `level` als Semikolon-getrennte Liste aufgefasst den Wert `-2` als Eintrag enthalten.

Alle Semikolon-verarbeitenden Funktionen beginnen mit dem Präfix `lrs_`;
dieses steht für _List represented sets_ (durch Listen dargestellte Mengen).

Der Filter `(if:...)` ist allerdings ein sogennanter _schwacher_ Filter
und kann nicht alleine als einziger Filter stehen, da dafür weltweit alle Objekte inspiziert werden müssten.
Der folgende Versuch  weltweit zu suchen führt also [zu einer Fehlermeldung](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way(if:lrs_in("-2",t["level"]));
    out center;

Für die meisten Anwendungsfälle ist das kein Problem,
denn es liegt schon über die Bounding-Box oder ein anderes räumliches Kriterium ein starker Filter vor.
Für die meisten übrigen Fälle reicht dann der Filter `[level]` nach [nur dem Tag](todo.md) als zusätzlicher Filter.
Für `level` speziell ist das Vorgehen nicht sinnvoll,
da wegen der hohen Häufigkeit dann immer noch sehr viele Objekte inspiziert werden müssen.
Die Datenmenge ist dann zuletzt eine Herausforderung für den Browser:
<!-- NO_QL_LINK -->

    way[level](if:lrs_in("-2",t["level"]));
    out center;

Für andere Tags kann das dagegen eine angemessene Lösung sein.

Der hierbei neu verwendete Filter `[level]` wird im [folgenden Abschnitt](misc_criteria.md#per_key) detailliert diskutiert.

Wenn wir umgekehrt alle Treppen ausblenden wollen, die auf Ebene -2 enden,
dann können wir dies direkt am Evaluator durch `!` für logische Verneinung [tun](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way[highway=steps]({{bbox}})
      (if:!lrs_in("-2",t["level"]));
    out center;

Allerdings sollten wir dann darüber nachdenken,
ob wir Treppen auswählen wollen, die gar kein Tag _level_ gesetzt haben. Nur Treppen [mit _level_](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way[highway=steps]({{bbox}})
      (if:!lrs_in("-2",t["level"]))
      [level];
    out center;

<a name="multiple"/>
## Mehrere Werte finden

Wir wollen nun in London ein Restaurant mit landestypischer Küche finden.
Dabei ist nicht so klar, ob wir nun nach `british`, nach `english` oder nach `regional` suchen sollten.

Im Prinzip könnten wir dies mit einem [Union](union.md#union) über [alle möglichen Werte](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB) lösen:

    (
      nwr[cuisine]({{bbox}})
        (if:lrs_in("english",t["cuisine"]));
      nwr[cuisine]({{bbox}})
        (if:lrs_in("british",t["cuisine"]));
      nwr[cuisine]({{bbox}})
        (if:lrs_in("regional",t["cuisine"]));
    );
    out center;

Das wird aber schnell unhandlich,
und zwar sowohl bei einer größeren Zahl Werte als auch bei anderen Gründen für eine Oder-Verknpüfung.

Wir nutzen daher die Semikolon-verarbeitende Funktion `lrs_isect` (von _intersection_ d.h. Schnittmenge),
die die gemeinsamen Werte zweier Semikolon-Listen [findet](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB):

    nwr[cuisine]({{bbox}})
       (if:lrs_isect(t["cuisine"],"english;british;regional"));
    out center;

Interessant ist am Request der Filter `(if:lrs_isect(t["cuisine"],"english;british;regional")` in Zeile 2:
Dort wertet per Element `(if:...)` darauf aus,
ob ein Wert verschieden von `0`, `false` und dem leeren Wert ermittelt wird.
Der Evaluator `lrs_isect(t["cuisine"],"english;british;regional")` hat wieder zwei Argumente,
die er beide als Listen auffasst
(eine Liste ohne Semikolon ist eine Liste mit dem Value als einzigem Eintrag).
Er liefert die Einträge zurück, die in beiden Listen vorkommen;
also genau dann einen nichtleeren Wert,
wenn mindestens einer der Werte `english`, `british` oder `regional` im Value zum Key `cuisine` vorkommt.

Ein vollständiger Request wird daraus, indem der Filter zusammen mit den Filtern auf die Bounding-Box und dem Filter auf den Key `cuisine` die zu selektierenden Objekte beschränkt.
In Zeile 3 wird ausgegeben.

Auch `lrs_isect` lässt sich verneinen, um logisch Wahr genau dann zu erhalten,
wenn `lrs_isect` eine leere Liste geliefert hat.

Zu Illustration tabellieren wir [alle hier vorkommenden Werte](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB):

    [out:csv(cuisine, isect, negated)];
    nwr[cuisine]({{bbox}});
    for (t["cuisine"])
    {
      make info cuisine=_.val,
        isect="{"+lrs_isect(_.val,"english;british;regional")+"}",
        negated="{"+!lrs_isect(_.val,"english;british;regional")+"}";
      out;
    }

Die Details der Syntax werden im Kaptiel [Daten analysieren](../analysis/index.md) erklärt.
Die Spalte `cuisine` enthält den jeweiligen Value des Tags _cuisine_.
Die Spalte `isect` enthält, was `lrs_isect(_.val,"english;british;regional")` daraus macht.
Für nichtleere Werte müssen Sie ein wenig scrollen,
aber spätestens bei den mit `british` beginnenden Einträgen gibt es sie.
Die Spalte `negated` enthält, was der Negationsoperator `!` aus dem jeweiligen Eintrag bei `isect` macht.
Der leere Eintrag liefert `1`, ein wie auch immer gefüllter Eintrag liefert `0`.

<a name="all"/>
## Alle Werte

...

<!--
  lrs_union
  Kombination lrs_union(set(..), "")
  sinnvoller sonstiger Einsatz?
  Verneinen
-->
