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
Wir können nach allen Objekten [suchen](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=nwr%5Bname%7E%22%5EFrankfurt%22%5D%3B%0Aout%20center%3B), deren Name mit _Frankfurt_ beginnt:

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
und der Benutzer sich an einer anderen Stelle beim Aufschreiben der Anfrage vertippt hat.

Anführungszeichen in Values werden formuliert,
indem man ihnen einen Backslash voranstellt.

<a name="local"/>
## Lokal

...

<!--
Typen n,w,r,nwr
mit/ohne Bounding-Box
Anführungszeichen
-->

<a name="regex"/>
## Speziell

...

<!--
Hinweis auf reguläre Ausdrücke
enthält
beginnt mit, endet mit
Groß-/Kleinschreibweise
Einzelzeichen
Alternativen
-->

<a name="equal"/>
## Relative Suche

...

<!--
Wertgleichheit via Evaluator
-->
