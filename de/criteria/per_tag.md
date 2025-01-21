Per Tag
=======

Suche nach allen Objekten, die ein bestimmtes Tag besitzen.

<a name="global"/>
## Global

Wir wollen weltweit alle Objekte finden,
bei denen ein spezielles [Tag](../preface/osm_data_model.md#tags) vorhanden ist.

Das ist per Overpass API nur bei Tags mit weniger als 10.000 Vorkommen sinnvoll;
die jeweilige Anzahl können Sie bei [Taginfo](nominatim.md#taginfo) finden.
Bei größeren Anzahlen kann es zu lange dauern,
die Daten überhaupt zu bekommen,
oder der Browser stürzt beim Anzeigen ab
oder beides.

Suchen [mit räumlicher Beschränkung](#local) funktionieren auch sinnvoll auf häufigen Tags.

Ein typisches Beispiel für seltene Tags sind Namen von Dingen, [hier](https://overpass-turbo.eu/?lat=51.47&lon=0.0&zoom=12&Q=CGI_STUB) _Köln_:

    nwr[name="Köln"];
    out center;

Wie Sie sehen, sehen Sie auch nach dem Klick auf _Ausführen_ nichts.
Erst die [Lupe](../targets/turbo.md#basics) bringt die Daten in Sicht.
Für alle folgenden Abfragen verwenden wir eine globale Sicht,
so dass Sie nicht nachfokussieren müssen.

Auch in naheliegenden Fällen können solche Suchen allerdings scheitern.
Zu _Frankfurt_ [gibt es Treffer](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) quer über den Globus,
und das Objekt für die Stadt am Main ist nicht einmal dabei:

    nwr[name="Frankfurt"];
    out center;

Der Grund dafür ist, das der Zusatz _am Main_ im Namen steht.
Die Overpass API würde ihre [Kernaufgabe](../preface/assertions.md#faithful) vernachlässigen,
wenn sie trotzdem das Objekt findet.
Eine interpretierende Suche ist Aufgabe eines Geocoders, z.B. [Nominatim](nominatim.md).

Es gibt trotzdem Abfragen dafür, z.B. durch _reguläre Ausdrücke_.
Wir können nach allen Objekten [suchen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB), deren Name mit _Frankfurt_ beginnt;
wegen der vielen Treffer dauert die Suche lange,
aber die Ergebnisgröße ist in diesem Fall trotz Warnmeldung noch harmlos:

    nwr[name~"^Frankfurt"];
    out center;

Viele weitere typische Verwendungen für _reguläre Ausdrücke_ werden [weiter unten](#regex) erklärt.

Dies sind nun sehr viele Treffer,
insbesondere Straßen, deren Name mit _Frankfurt_ beginnt.
In der Regel sucht man aber einen spezifischen Objekttyp.
Im Falle einer Stadtgrenze handelt es sich immer um eine _Relation_.
Wir können gezielt danach suchen,
indem wir statt _nwr_ (für Nodes-Ways-Relations) den Ausdruck _relation_ [schreiben](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    relation[name="Köln"];
    out geom;

Hier ist auch [die Ausgabeart](../targets/formats.md#extras) von _center_ auf _geom_ geändert,
damit man die volle Geometrie des Objekts sieht.

Entsprechend gibt es auch die Typen _node_ und _way_ anstelle von _nwr_.
Sie liefern nur Nodes bzw. nur Ways zurück.

Zuletzt sei noch auf Tags mit Sonderzeichen (alles außer Buchstaben, Zahlen und dem Unterstrich) im _Key_ oder _Value_ hingewiesen.
Dem aufmerksamen Beobachter ist nicht entgangen,
dass der _Value_ in den Abfragen oben stets in Anführungszeichen steht.
Dies wäre eigentlich gleicher Weise auch für _Keys_ nötig;
die obige Abfrage lautet also ganz formal:
<!-- NO_QL_LINK -->

    relation["name"="Köln"];
    out geom;

Die Overpass API ergänzt jedoch die Anführungszeichen stillschweigend,
wenn klar ist, dass dies gemeint ist.
Mit Sonderzeichen kann das nicht funktionieren,
da die Sonderzeichen ja auch eine andere Bedeutung haben könnten
und der Benutzer sich an einer anderen Stelle beim Aufschreiben der Anfrage vertippt haben könnte.

Anführungszeichen in Values werden formuliert,
indem man ihnen einen Backslash voranstellt.

<a name="local"/>
## Lokal

Möchte man nach allen Objekten mit einem Tag in einem Gebiet suchen,
so ist dies eigentlich eine Kombination mehrerer Operatoren;
dies wird bei [und/oder-Kombinationen](union.md) und [Verketten](chaining.md) systematisch beschrieben.
Hier geht es daher nur um einige Standardfälle.

Alle Objekte in einem eindeutigen Ort sind z.B. [alle Cafés in Köln](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    area[name="Köln"];
    nwr[amenity=cafe](area);
    out center;

Die genaue Funktionsweise der ersten Zeile wird unter [Areas](../full_data/area.md#per_tag) erklärt.
Uns interessiert vor allem die zweite Zeile:
Dies ist eine _Query_ mit Zieltyp _nwr_ (d.h. wir suchen nach _Nodes_, _Ways_ und _Relations_);
es ist dann zum einen der Filter `[amenity=cafe]` gesetzt,
d.h. wir lassen nur Objekte zu, bei denen das Tag mit Key _amenity_ existiert und auf den Wert _cafe_ gesetzt ist.
Zum zweiten ist der das Gebiet einschränkende Filter `(area)` gesetzt.

Der Filter `(area)` wirkt [durch Aneinanderreihung](../preface/design.md#sequential).

Auf diese Weise suchen wir Obekte bei denen die Tag-Bedingung und die räumliche Bedingung zutrifft.
Diese stehen, wieder [per Aneinanderreihung](../preface/design.md#sequential),
dann in der nachfolgenden Zeile zur Ausgabe bereit.

Wenn Ihnen dies zu kompliziert ist,
gibt es aber auch einen einfacheren Weg:
Sie können [per Bounding-Box](../full_data/bbox.md#filter) räumlich einschränken und dies mit dem Filter nach einem Tag kombinieren ([Beispiel](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB)):

    nwr[amenity=cafe]({{bbox}});
    out center;

Das zentrale Element ist auch hier die mit _nwr_ beginnende Zeile:
der Filter `[amenity=cafe]` wirkt wie im vorhergehenden Beispiel;
den Filter `({{bbox}})` befüllt [Overpass Turbo](../targets/turbo.md#convenience) für uns mit der aktuell sichtbaren Bounding-Box,
und die OVerpass API wendet diese Bounding-Box dann als zweiten Filter an.

Die Reihenfolge der beiden Filter ist, wie bei allen Filtern, [egal](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    nwr({{bbox}})[amenity=cafe];
    out center;

hat das gleiche Ergebnis wie die Abfrage vorher.

Auch hier kann und sollte der Typ der _Query_-Anweisung zwischen _node_, _way_ und _relation_ passend gewählt werden, z.B. [nur Ways](https://overpass-turbo.eu/?lat=50.94&lon=6.95&zoom=14&Q=CGI_STUB) für Gleise:

    way[railway=rail]({{bbox}});
    out geom;

<a name="regex"/>
## Speziell

Im Fall _Frankfurt_ sind wir bereits auf das Problem gestoßen,
dass wir unscharf nach einem Wert suchen wollen.
Ein sehr mächtiges Werkzeug dafür sind [reguläre Ausdrücke](https://www.gnu.org/software/grep/manual/grep.html#Regular-Expressions).
Eine systematische Einführung in reguläre Ausdrücke übersteigt den Umfang dieses Handbuchs,
aber es gibt zumindest Beispiele für ein paar gängige Fälle.

In vielen Fällen kennen wir den Anfang eines Namens.
Z.B. suchen wir hier nach Straßen, deren Name mit _Emmy_ [beginnt](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB):

    way[name~"^Emmy"];
    out geom;

Das wichtigste Zeichen in der ganzen Abfrage ist die Tilde `~`.
Diese zeigt im Filter in der ersten Zeile an,
dass die Werte mit einem regulären Ausdruck verglichen werden sollen.
Es werden jetzt alle für den Key `name` in der Datenbank existierenden Values mit dem regulären Ausdruck hinter der Tilde abgeglichen.

Das zweitwichtigste Zeichen ist das Caret im Ausdruck `^Emmy`;
dieses ist Bestandteil des regulären Ausdrucks
und sorgt dafür, dass nur Werte passen, die mit `Emmy` beginnen.
Insgesamt steht dort also:

Finde alle Objekte vom Typ _way_,
die ein Tag mit Key `name` und einem Value besitzen,
der mit `Emmy` beginnt.

In der zweiten Zeile steht dann noch eine passende [Ausgabeanweisung](../targets/formats.md#extras).

Ebenso kann man nach Werten suchen,
die auf einem bestimmten Wert [enden](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB), z.B. _Noether_:

    way[name~"Noether$"];
    out geom;

Die Tilde `~` zeigt wieder den Filter nach einem regulären Ausdruck an.
Das Dollarzeichen `$` innerhalb des regulären Ausdrucks definiert,
dass der Wert mit `Noether` enden soll.

Die [Lupe](../targets/turbo.md#basics) als Komfortfunktion in _Overpass Turbo_ zoomt auf den nur einen Treffer in Paris.

Es ist auch möglich, nach einer Teilzeichenkette zu suchen,
die irgendwo [in der Mitte](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) steht:

    way[name~"Noether"];
    out geom;

Dazu schreibt man einfach die Teilzeichenkette ohne zusätzliche Zeichen.

Etwas schwieriger wird es,
wenn man zwei (oder mehr) Teilzeichenketten finden will,
z.B. Vor- und Nachnamen,
aber nicht weiß, was dazwischen steht.
Bei _Emmy Noether_ kommt sowohl der Bindestrich als auch das Leerzeichen vor.
Dazu kann man alle in Frage kommenden Zeichen (zwei oder auch mehr) in eckige Klammern [einschließen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB):

    way[name~"Emmy[ -]Noether"];
    out geom;

Alternativ kann man auch gleich [alle Zeichen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) zulassen:

    way[name~"Emmy.Noether"];
    out geom;

Das entscheidende Zeichen ist hier der einzelne Punkt `.`.
Er vertritt ein einzelnes beliebiges Zeichen.

Manchmal ist es auch nötig,
[beliebig viele Zwischenzeichen zuzulassen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB).
Damit sucht man dann also nach zwei getrennten Teilstrings.
Ein Beispiel ist der Komponist _Bach_;
er hat nach _Johann_ noch mehr Vornamen:

    way[name~"Johann.*Bach"];
    out geom;

Hier wirken die beiden Sonderzeichen Punkt `.` und Stern `*` zusammen.
Der Punkt passt auf ein beliebiges Zeichen,
und der Stern bedeutet,
dass das vorangehende Zeichen beliebig oft (gar nicht, einmal oder mehrmals) wiederholt werden darf.

Ergänzt wird das durch das Fragezeichen.
Dann darf ein Zeichen [null oder einmal](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) vorkommen.
Das hilft uns bei _Gerhard_ bzw. _Gerard_ bzw. _Gerardo Mercator_:

    way[name~"Gerh?ardo?.Mercator"];
    out geom;

Zuletzt soll noch der Fall erwähnt werden,
der [gleich](union.md) bei _Und_ und _Oder_ wiederkommt:
Finde einen [Wert aus einer Liste](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) wie z.B. die Standardwerte _trunk_, _primary_, _secondary_, _tertiary_ für Hauptverkehrsstraßen!

    way[highway~"^(trunk|primary|secondary|tertiary)$"]({{bbox}});
    out geom;

Uns interessiert der Filter `[highway~"^(trunk|primary|secondary|tertiary)$"]`;
das Zeichen `~` zeigt den regulären Ausdruck an.
Im regulären Ausdruck bedeuten das Caret am Anfang und das Dollarzeichen am Ende,
dass der volle _Value_ und nicht nur eine Teilzeichenkette auf den Wert dazwischen passen muss.
Der senkrechte Strich `|` steht für _oder_,
und die Klammern sorgen dafür,
dass Caret und Dollarzeichen nicht nur auf einen Wert wirken.

<a name="per_key"/>
## Per Key

Es ist auch möglich, nach dem Vorhandensein eines Keys zu selektieren.

In den meisten Fällen gibt es dabei so viele Objekte mit dem gegebenen Key,
dass es Sinn ergibt, den Filter mit einem räumlichen Filter zu kombinieren,
z.B. [alle benannten Objekte im Stadtkern von London](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[name](51.5,-0.11,51.52,-0.09);
    out geom;

Wir führen die räumliche Selektion mit der Bounding-Box `(51.5,-0.11,51.52,-0.09)` durch.
Der Filter für den Key ist der Ausdruck `[name]`, d.h. der Key in eckigen Klammern.
Üblicherweise soll der Key dabei in Anführungszeichen stehen.
Aber er kann ohne geschrieben werden, wenn der Name des Keys keine Sonderzeichen enthält.
Es haben so viele große Relationen ein Tag `name`,
dass hier gewollt nur Nodes und Ways selektiert worden sind.
Doies wird mit `nw` erreicht.

Der Filter für die Suche nach einem Key kann frei mit allen anderen Filtern kombiniert werden.

Der Vollständigkeit halber soll auch ein Beispiel für einen Key-Filter [ohne](https://overpass-turbo.eu/?lat=15&lon=0&zoom=2&Q=CGI_STUB) räumlichen Filter gegeben werden:

    nw["not:name:note"];
    out geom;

Wir brauchen hier Anführungszeichen, denn der Key enthält die Sonderzeichen `:` (Doppelpunkt).

Es gibt eine gewisse Konvention, Keys per Doppelpunkt aus mehreren Teilen zusammenzusetzen,
und es kann schwierig sein, alle möglichen Varianten abzudecken und sicherzustellen, dass die Liste vollständig ist.
Als Gegenmittel ist es auch möglich, Keys mit Regulären Ausdrücken auszuwählen.

Wir wagen einen ersten Versuch alle Objekte zu finden, die Namen in mehreren Sprachen haben,
d.h. die einen Key haben, der mit `name` startet,
wiederum im [Stadtkern von London](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[~"^name"~"."](51.5,-0.11,51.52,-0.09);
    out geom;

Die wichtigsten Zeichen hier sind die beiden Tilden `~`.
Die erste Tilde vor der ersten Zeichenkette legt fest,
dass wir den Key mit dem Regulären Ausdruck aus der ersten Zeichenkette auswählen wollen.
Und die zweite Tilde zwischen den beiden Zeichenketten zeigt an,
dass die zweite Zeichenkette ein Regulärer Ausdruck für den Value ist.
Es gibt keine Syntaxvariante mit einem Regulären Ausdruck nur für den Key,
aber der einzelne Punkt `.` trifft ohnehin alle tatsächlich verwendeten Werte.

Wir wollen nur Keys auswählen, die mit `name` starten.
Daher gibt es ein Caret an der Spitze der Zeichenkette als die übliche Syntax für Reguläre Ausdrücke dafür.
Das Ergebnis ähnelt aber sehr stark dem vorhergehenden Ergebnis.

Der Grund dafür ist, dass `name` ebenfalls ein Key ist, der mit `name` startet,
und wenige Objekte haben Namen in mehreren Sprachen, aber kein `name`-Tag.
Zum Glück haben die Keys für Namen in anderen Sprachen stets die Form `name:XXX`,
d.h. es ist sichergestellt, dass auf `name` ein Doppelpunkt folgt.
Diese Abfrage zeigt die [Objekte mit Namen in mehreren Sprachen](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[~"^name:"~"."](51.5,-0.11,51.52,-0.09);
    out geom;

Der Doppelpunkt hat keine besondere Bedeutung in der Syntax Regulärer Ausdrücke
und kann daher einfach an `name` angefügt werden.

Der Value-Teil der Syntax kann auch genutzt werden, um den Wert des Vaues tatsächlich einzuschränken.
Wir können z.B. alle Objekte wählen, die [irgendein Fahrrad-Verbot](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB) haben:

    nw[~"bicycle"~"^no$"](51.5,-0.11,51.52,-0.09);
    out geom;

Erneut ist die Zwei-Tilden-Syntax genutzt.
Nun beginnt der Vaue-Teil `^no$` mit einem Caret und endet mit einem Dollar-Zeichen
um die erlaubten Values auf exakt `no` einzuschränken.

Die meisten Ergebnisse sind für Radfahrer geöffnete Einbahnstraßen, d.h. das Tag `oneway:bicycle=no`.
Oder ander ausgedrückt: es ist gar keine Fahrrad-Einschränkung.
Um Objekte auszuschließen, die ein Tag mit Key `oneway` haben,
ist es möglich, den [Negierter-Key-Filter](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB) zu benutzen:

    nw[~"bicycle"~"^no$"][!oneway](51.5,-0.11,51.52,-0.09);
    out geom;

Dieser unterscheidet sich vom positiven Key-Filter durch das Ausrufezeichen hinter der öffnenden Klammer
und vor der Key-Zeichenkette.

Im Prinzip ist es möglich, den Filter Groß-Klein-Schreibung ignorieren zu lassen.
Dies wird [für Key und Value gleichzeitig](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB) umgeschaltet:

    nw[~"^name:"~".",i](51.5,-0.11,51.52,-0.09);
    out geom;

Das `,i` am Ende des Filters ist der Schalter.
Es gibt alerdings keinen wahrnehmbaren Unterschied.

Die ist insofern erwartet als dass Keys per Konvention in OpenStreetMap aus Kleinbuchstaben bestehen.
Wir können trotzdem auch [nach Objekten mit Großbuchstaben in Keys](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB) suchen:

    nw[~"[A-Z]"~"."](51.5,-0.11,51.52,-0.09);
    out geom;

Der Reguläre Ausdruck `[A-Z]` selektiert alle Zeichenketten, die mindestens einen Großbuchstaben enthalten.

<a name="numbers"/>
## Per Zahlwert

...
<!--
  Hilfsmittel zum Umgang mit Tags, die Zahlwerte im Value enthalten.
  Einheiten
-->
