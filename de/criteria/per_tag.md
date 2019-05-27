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

Ein typisches Beispiel für seltene Tags sind Namen von Dingen, [hier](https://overpass-turbo.eu/?Q=nwr%5Bname%3D%22K%C3%B6ln%22%5D%3B%0Aout%20center%3B) _Köln_:

    nwr[name="Köln"];
    out center;

Wie Sie sehen, sehen Sie auch nach dem Klick auf _Ausführen_ nichts.
Erst die [Lupe](../targets/turbo.md#basics) bringt die Daten in Sicht.
Für alle folgenden Abfragen verwenden wir eine globale Sicht,
so dass Sie nicht nachfokussieren müssen.

Auch in naheliegenden Fällen können solche Suchen allerdings scheitern.
Zu _Frankfurt_ [gibt es Treffer](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=nwr%5Bname%3D%22Frankfurt%22%5D%3B%0Aout%20center%3B) quer über den Globus,
und das Objekt für die Stadt am Main ist nicht einmal dabei:

    nwr[name="Frankfurt"];
    out center;

Der Grund dafür ist, das der Zusatz _am Main_ im Namen steht.
Die Overpass API würde ihre [Kernaufgabe](../preface/assertions.md#faithful) vernachlässigen,
wenn sie trotzdem das Objekt findet.
Eine interpretierende Suche ist Aufgabe eines Geocoders, z.B. [Nominatim](nominatim.md).

Es gibt trotzdem Abfragen dafür, z.B. durch _reguläre Ausdrücke_.
Wir können nach allen Objekten [suchen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=nwr%5Bname%7E%22%5EFrankfurt%22%5D%3B%0Aout%20center%3B), deren Name mit _Frankfurt_ beginnt;
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
indem wir statt _nwr_ (für Nodes-Ways-Relations) den Ausdruck _relation_ [schreiben](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=relation%5Bname%3D%22K%C3%B6ln%22%5D%3B%0Aout%20geom%3B):

    relation[name="Köln"];
    out geom;

Hier ist auch [die Ausgabeart](../targets/formats.html#extras) von _center_ auf _geom_ geändert,
damit man die volle Geometrie des Objekts sieht.

Entsprechend gibt es auch die Typen _node_ und _way_ anstelle von _nwr_.
Sie liefern nur Nodes bzw. nur Ways zurück.

Zuletzt sei noch auf Tags mit Sonderzeichen (alles außer Buchstaben, Zahlen und dem Unterstrich) im _Key_ oder _Value_ hingewiesen.
Dem aufmerksamen Beobachter ist nicht entgangen,
dass der _Value_ in den Abfragen oben stets in Anführungszeichen steht.
Dies wäre eigentlich gleicher Weise auch für _Keys_ nötig;
die obige Abfrage lautet also ganz formal:

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

Alle Objekte in einem eindeutigen Ort sind z.B. [alle Cafés in Köln](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=area%5Bname%3D%22K%C3%B6ln%22%5D%3B%0Anwr%5Bamenity%3Dcafe%5D%28area%29%3B%0Aout%20geom%3B):

    area[name="Köln"];
    nwr[amenity=cafe](area);
    out center;

Die genaue Funktionsweise der ersten Zeile wird unter [Areas](../full_data/polygon.md) erklärt.
Uns interessiert vor allem die zweite Zeile:
Dies ist eine _Query_ mit Zieltyp _nwr_ (d.h. wir suchen nach _Nodes_, _Ways_ und _Relations_);
es ist dann zum einen der Filter ``[amenity=cafe]`` gesetzt,
d.h. wir lassen nur Objekte zu, bei denen das Tag mit Key _amenity_ existiert und auf den Wert _cafe_ gesetzt ist.
Zum zweiten ist der das Gebiet einschränkende Filter ``(area)`` gesetzt.

Der Filter ``(area)`` wirkt [durch Aneinanderreihung](../preface/design.md#sequential).

Auf diese Weise suchen wir Obekte bei denen die Tag-Bedingung und die räumliche Bedingung zutrifft.
Diese stehen, wieder [per Aneinanderreihung](../preface/design.md#sequential),
dann in der nachfolgenden Zeile zur Ausgabe bereit.

Wenn Ihnen dies zu kompliziert ist,
gibt es aber auch einen einfacheren Weg:
Sie können [per Bounding-Box](../full_data/bbox.md#filter) räumlich einschränken und dies mit dem Filter nach einem Tag kombinieren ([Beispiel](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=nwr%5Bamenity%3Dcafe%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B)):

    nwr[amenity=cafe]({{bbox}});
    out center;

Das zentrale Element ist auch hier die mit _nwr_ beginnende Zeile:
der Filter ``[amenity=cafe]`` wirkt wie im vorhergehenden Beispiel;
den Filter ``({{bbox}})`` befüllt [Overpass Turbo](../targets/turbo.md#convenience) für uns mit der aktuell sichtbaren Bounding-Box.

Die Reihenfolge der beiden Filter ist [egal](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=nwr%28%7B%7Bbbox%7D%7D%29%5Bamenity%3Dcafe%5D%3B%0Aout%20center%3B):

    nwr({{bbox}})[amenity=cafe];
    out center;

hat das gleiche Ergebnis wie die Abfrage vorher.

Auch hier kann und sollte der Typ der _Query_-Anweisung zwischen _node_, _way_ und _relation_ passend gewählt werden, z.B. [nur Ways](https://overpass-turbo.eu/?lat=50.94&lon=6.95&zoom=14&Q=way%5Brailway%3Drail%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B) für Gleise:

    way[railway=rail]({{bbox}});
    out geom;

<a name="regex"/>
## Speziell

Im Fall _Frankfurt_ sind wir bereits auf das Problem gestoßen,
dass wir unscharf nach einem Wert suchen wollen.
Ein sehr mächtiges Werkzeug dafür sind _reguläre Ausdrücke_.
Eine systematische Einführung in reguläre Ausdrücke übersteigt den Umfang dieses Handbuchs,
aber es gibt zumindest Beispiele für ein paar gängige Fälle.

In vielen Fällen kennen wir den Anfang eines Namens.
Z.B. suchen wir hier nach Straßen, deren Name mit _Emmy_ [beginnt](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=way%5Bname%7E%22%5EEmmy%22%5D%3B%0Aout%20geom%3B):

    way[name~"^Emmy"];
    out geom;

Das wichtigste Zeichen in der ganzen Abfrage ist die Tilde ``~``.
Diese zeigt im Filter in der ersten Zeile an,
dass die Werte mit einem regulären Ausdruck verglichen werden sollen.
Es werden jetzt alle für den Key ``name`` in der Datenbank existierenden Values mit dem regulären Ausdruck hinter der Tilde abgeglichen.

Das zweitwichtigste Zeichen ist das Caret im Ausdruck ``^Emmy``;
dieses ist Bestandteil des regulären Ausdrucks
und sorgt dafür, dass nur Werte passen, die mit ``Emmy`` beginnen.
Insgesamt steht dort also:

Finde alle Objekte vom Typ _way_,
die ein Tag mit Key ``name`` und einem Value besitzen,
der mit ``Emmy`` beginnt.

In der zweiten Zeile steht dann noch eine passende [Ausgabeanweisung](../targets/formats.html#extras).

Ebenso kann man nach Werten suchen,
die auf einem bestimmten Wert [enden](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=way%5Bname%7E%22Noether%24%22%5D%3B%0Aout%20geom%3B), z.B. _Noether_:

    way[name~"Noether$"];
    out geom;

Die Tilde ``~`` zeigt wieder den Filter nach einem regulären Ausdruck an.
Das Dollarzeichen ``$`` innerhalb des regulären Ausdrucks definiert,
dass der Wert mit ``Noether`` enden soll.

Die [Lupe](../targets/turbo.md#basics) als Komfortfunktion in _Overpass Turbo_ zoomt auf den nur einen Treffer in Paris.

Es ist auch möglich, nach einer Teilzeichenkette zu suchen,
die irgendwo [in der Mitte](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=way%5Bname%7E%22Noether%22%5D%3B%0Aout%20geom%3B) steht:

    way[name~"Noether"];
    out geom;

Dazu schreibt man einfach die Teilzeichenkette ohne zusätzliche Zeichen.

Etwas schwieriger wird es,
wenn man zwei (oder mehr) Teilzeichenketten finden will,
z.B. Vor- und Nachnamen,
aber nicht weiß, was dazwischen steht.
Bei _Emmy Noether_ kommt sowohl der Bindestrich als auch das Leerzeichen vor.
Dazu kann man alle in Frage kommenden Zeichen (zwei oder auch mehr) in eckige Klammern [einschließen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=way%5Bname%7E%22Emmy%5B%20%2D%5DNoether%22%5D%3B%0Aout%20geom%3B):

    way[name~"Emmy[ -]Noether"];
    out geom;

Alternativ kann man auch gleich [alle Zeichen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=way%5Bname%7E%22Emmy%2ENoether%22%5D%3B%0Aout%20geom%3B) zulassen:

    way[name~"Emmy.Noether"];
    out geom;

Das entscheidende Zeichen ist hier der einzelne Punkt ``.``.
Er vertritt ein einzelnes beliebiges Zeichen.

Manchmal ist es auch nötig,
[beliebig viele Zwischenzeichen zuzulassen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=way%5Bname%7E%22Johann%2E%2ABach%22%5D%3B%0Aout%20geom%3B).
Damit sucht man dann also nach zwei getrennten Teilstrings.
Ein Beispiel ist der Komponist _Bach_;
er hat nach _Johann_ noch mehr Vornamen:

    way[name~"Johann.*Bach"];
    out geom;

Hier wirken die beiden Sonderzeichen Punkt ``.`` und Stern ``*`` zusammen.
Der Punkt passt auf ein beliebiges Zeichen,
und der Stern bedeutet,
dass das vorangehende Zeichen beliebig oft (gar nicht, einmal oder mehrmals) wiederholt werden darf.

Ergänzt wird das durch das Fragezeichen.
Dann darf ein Zeichen [null oder einmal](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=way%5Bname%7E%22Gerh%3Fardo%3F%2EMercator%22%5D%3B%0Aout%20geom%3B) vorkommen.
Das hilft uns bei _Gerhard_ bzw. _Gerard_ bzw. _Gerardo Mercator_:

    way[name~"Gerh?ardo?.Mercator"];
    out geom;

Zuletzt soll noch der Fall erwähnt werden,
der [gleich](union.md) bei _Und_ und _Oder_ wiederkommt:
Finde einen [Wert aus einer Liste](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=way%5Bhighway%7E%22%5E%28trunk%7Cprimary%7Csecondary%7Ctertiary%29%24%22%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20geom%3B) wie z.B. die Standardwerte _trunk_, _primary_, _secondary_, _tertiary_ für Hauptverkehrsstraßen!

    way[highway~"^(trunk|primary|secondary|tertiary)$"]({{bbox}});
    out geom;

Uns interessiert der Filter ``[highway~"^(trunk|primary|secondary|tertiary)$"]``;
das Zeichen ``~`` zeigt den regulären Ausdruck an.
Im regulären Ausdruck bedeuten das Caret am Anfang und das Dollarzeichen am Ende,
dass der volle _Value_ und nicht nur eine Teilzeichenkette auf den Wert dazwischen passen muss.
Der senkrechte Strich ``|`` steht für _oder_,
und die Klammern sorgen dafür,
dass Caret und Dollarzeichen nicht nur auf einen Wert wirken.
