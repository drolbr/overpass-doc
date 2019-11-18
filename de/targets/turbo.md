Overpass Turbo
==============

Das Standardtool zum Entwicklen von Abfragen.

<a name="overview"/>
## Überblick

Overpass Turbo ist eine Website,
um Overpass-API-Anfragen auszuführen
und das Ergebnis auf einer Karte zu sehen.

Viele Beispiele dieses Handbuchs verlinken auf Overpass Turbo mit einer passend vorbelegten Abfrage.

Eine öffentliche Instanz ist verfügbar unter [https://overpass-turbo.eu](https://overpass-turbo.eu).
Der Quellcode liegt ebenso wie bei der Overpass API auf [Github](https://github.com/tyrasd/overpass-turbo).
Martin Raifer hat Overpass Turbo entwickelt;
an dieser Stelle möchte ich ihm ausdrücklich meinen Dank aussprechen.

Nahezu alle Ausgabeformate,
die bei der Overpass API zur Verfügung stehen,
können von Overpass Turbo auch verstanden werden.
Schwierigkeiten gibt es bei Abfragen mit sehr großen Ergebnismengen;
auch heute kommen dann die JavaScript-Engines der genutzten Browser an die Grenzen ihres Speichermanagements.
Daher fragt Overpass Turbo nach,
wenn es eine große Ergebnismenge erhalten hat,
ob der Endbenutzer das Risiko eingehen will, den Browser einfrieren zu lassen.

Es gibt viele beliebte und sinnvolle Features,
die aber den Rahmen dieses Handbuchs übersteigen.
Dazu sei auf die [Dokumentation](https://wiki.openstreetmap.org/wiki/DE:Overpass_turbo) zu Overpass Turbo verwiesen.
Dies gilt insbesondere für _Styles_ und zum Query-Generator _Wizard_.
Dieses Handbuch beschränkt sich auf die unmittelbare Wechselwirkung mit der Abfragesprache.

<a name="basics"/>
## Rüstzeug

Die Ansicht der Website ist in mehrere Teile aufgeteilt;
sie unterscheiden sich in der Anordnung zwischen Desktop- und Mobilversion.
Öffnen Sie [sie](https://overpass-turbo.eu) am besten jetzt in einem separaten Tab.

In der Desktop-Version ist links ein großes Textfeld;
hier sollen Sie Ihre Abfrage eingeben.
Rechts ist zunächst ein Kartenausschnitt.
Über die beiden Reiter _Karte_ und _Daten_ kann zwischen dem Kartenausschnitt
und einem Textfeld für die empfangenen Daten umgeschaltet werden.

In der Mobil-Version steht das Textfeld für die Abfrage über dem Kartenausschnitt.
Das zweite Textfeld für die empfangenen Daten ist unter dem Kartenausschnitt;
statt der Reiter kommt man durch beherztes Scrollen zwischen beiden Teilen hin und her.

Wir üben den Standard-Anwendungsfall:
Geben Sie

    nwr[name="Canary Wharf"];
    out geom;

in das Textfeld ein (oder nutzen Sie [diesen Link](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=18&Q=CGI_STUB))!

Klicken Sie nun auf _Ausführen_.
Es kommt kurz eine Fortschrittsmeldung,
dann sehen Sie wieder das fast gleiche Bild wie vorher.

Klicken Sie daher nun auf die Lupe.
Dies ist am linken Rand des Kartenausschnitts das dritte Symbol von oben, unter den Plus/Minus-Schaltern.
Die Kartenansicht springt jetzt auf die feinste Auflösung,
die noch alle Ergebnisse anzeigt.

Die markierten Objekte im Kartenausschnitt sind jetzt exakt die Objekte,
die die Abfrage gefunden hat.

Oft ist es nützlich,
sich die tatsächlich gelieferten Daten direkt anzuschauen.
Das geht mit dem Reiter _Daten_ oben rechts oberhalb der Kartenansicht
bzw. mit Herunterscrollen in der Mobilvariante.

Unabhängig davon sind alle auf der Karte hervorgehobenen Objekte anklickbar und zeigen dann,
je nach Umfang ihrer Daten,
ihre Id, ihre Tags oder ihre Metadaten.

Irgendwann wird Ihnen die Meldung begegnen,
dass nicht zu allen Objekten die Geometrie mitgeliefert worden ist.
Sie können dann die Query-Änderung zur automatischen Vervollständig erproben.
Oder Sie ersetzen alle Vorkommen von `out` durch ihre Gegenstücke mit Geometrie `out geom`.

Wenn Sie ein großes Ergebnis erwarten
oder die Daten sowieso mit einem anderen Programm weiterverarbeiten wollen,
dann können Sie die Daten auch ohne Anzeige direkt zum Abspeichern exportieren:
Gehen Sie auf _Export_,
bleiben Sie im erscheinenden Fenster im Reiter _Daten_
und wählen Sie `Rohdaten direkt von der Overpass API`.
Bei langlaufenden Abfragen ist es normal,
dass nach dem Klick erst einmal scheinbar nichts passiert.

Auf zwei nützliche Extras sei hingewiesen:

* Unten rechts im Kartenausschnitt stehen Zähler,
  wie viele Objekte welchen Typs bei der letzten Abfrage zurückgeliefert worden sind.
* Oben links im Kartenausschnitt gibt es ein Suchfeld.
  Dieses hat zwar eine geringere Leistungsfähigkeit als [Nominatim auf openstreetmap.org](../criteria/nominatim.md),
  aber die verfügbare Suche nach Ortsnamen reicht in der Regel,
  um den Kartenausschnitt schnell am richtigen Ort zu plazieren.

<a name="symbols"/>
## Legende

Die [Dokumentation](https://wiki.openstreetmap.org/wiki/DE:Overpass_turbo) erläutert die Farben bereits.
Wir konzentrieren uns hier daher eher auf das Zusammenspiel:
Zu einem konkreten Objekt oder Objektart haben Sie eine Vorstellung,
ob es ein Punkt, Linie, Fläche, eine Zusammensetzung davon, etwas Abstraktes oder etwas mit unscharfen Grenzen ist.
In den OpenStreetMap-Datenstrukturen ist es auf irgendeine Weise modelliert;
diese kann, aber muss nicht zwingend mit Ihrer Erwartung übereinstimmen.

Die Overpass API bietet [Hilfsmittel](formats.md#extras),
um von der OpenStreetMap-Modellierung zu einer zu wechseln,
die besser zur Darstellung passt;
sei es durch Beschaffen der Koordinaten oder auch geometrische Vereinfachung oder [Zuschnitt](../full_data/bbox.md#crop).
Overpass Turbo muss nun in jedem Fall eine möglichst gute Darstellung liefern,
egal, ob die Modellierung in OpenStreetMap noch naheliegend ist,
und egal, ob das in der Abfrage gewählte Ausgabeformat sinnvoll zu den Daten passt.

Dieser Abschnitt soll erläutern,
was dann final in der Kartendarstellung herauskommt
und wie dies mit der Abfrage und den Daten zusammenhängt.

Punktobjekte können ein gelbes oder rotes Inneres haben.
Mit gelbem Inneren sind es echte _Nodes_,
mit rotem Inneren sind es _Ways_.

Ways können entweder wegen ihrer geringen Länge zu Punkten werden,
da sie sonst zu unauffällig wären:
Zoomen Sie bitte in [diesem Beispiel](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=CGI_STUB) heraus
und beobachten, wie Gebäude und Straße zu Punkten werden!

    ( way({{bbox}})[building];
      way({{bbox}})[highway=steps]; );
    out geom;

Wenn das bei einer konkreten Abfrage stört,
können Sie es unter _Einstellungen_, _Karte_, _Kleine Features nicht wie POIs darstellen_ abschalten.
Die Änderung wirkt erst nach dem Ausführen der nächsten Abfrage.

Oder sie können als Punkte dargestellt werden,
weil [die Abfrage](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=CGI_STUB) per `out center` ausgegeben hat:

    way({{bbox}})[building];
    out center;

Punktobjekte können ein blauen oder lilanen Rand haben;
das gilt auch für als Linienzug oder Fläche gezeichnete Objekte.
In allen solchen Fällen sind _Relations_ [beteiligt](https://overpass-turbo.eu/?lat=51.5045&lon=-0.0195&zoom=16&Q=CGI_STUB):

    rel[name="Canary Wharf"];
    out geom;

Im Gegensatz zu _Nodes_ oder _Ways_ sind die Details der _Relation_ dann aber nicht per Klick aufs Objekt verfügbar,
sondern in der Blase gibt es nur einen Link auf die _Relation_ auf _openstreetmap.org_.
Unter gewöhnlichen Umständen ist dies kein Problem.

Hat man aber gezielt einen alten Versionsstand angefragt,
so sind die Daten von der Hauptseite andere als die per Overpass API bezogenen Daten.
Es führt dann kein Weg daran vorbei,
in die zurückgelieferten Daten selbst per Reiter _Daten_ hineinzuschauen.

Ist dagegen die Linie oder Umrandung der Fläche gestrichelt,
so ist die Geometrie des Objekts unvollständig.
Das ist zumeist ein gewollter Effekt der [Ausgabebegrenzung](../full_data/bbox.md#crop) ([Beispiel](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=16&Q=CGI_STUB)):

    (
      way(51.475,-0.002,51.478,0.003)[highway=unclassified];
      rel(bw);
    );
    out geom(51.475,-0.002,51.478,0.003);

Es kann aber auch Folge einer Abfrage sein,
die zu _Ways_ einige, aber nicht alle _Nodes_ geladen hat.
Hier haben wir _Ways_ auf Basis von _Nodes_ geladen,
aber [vergessen](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB), die fehlenden Nodes direkt oder indirekt nachzuladen:

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out;

Die Abfrage kann durch `out geom` [repariert](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB) werden;
mehr Möglichkeiten sind im Abschnitt zu [Geometrien](../full_data/osm_types.md#nodes_ways) erklärt:

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out geom;

<a name="convenience"/>
## Komfort

Overpass Turbo bietet einige Komfortfunktionen.

Es kann die Bounding-Box des aktuellen Fensters automatisch in eine Query einfügen.
Dazu ersetzt Overpass Turbo jedes Vorkommen der Zeichenfolge `{{bbox}}` durch die vier Ränder,
so dass eine gültige Bounding-Box entsteht.

Man kann die übertragene Bounding-Box sogar sehen,
wenn man sie an einer anderen als der üblichen Stelle [einfügt](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB) (und nach dem Ausführen auf _Daten_ klickt):

    make Beispiel Infotext="Die aktuelle Bounding-Box ist {{bbox}}";
    out;

Eine zweite nützliche Funktion verbirgt sich hinter der Schaltfläche _Teilen_ oben links.
Dies erzeugt einen Link,
unter dem sich dauerhaft die zu dem Zeitpunkt eingegebene Abfrage abrufen lässt.
Auch wenn jemand Drittes den Link aufruft und die Abfrage editiert,
dann bleibt trotzdem die originale Abfrage unter dem Link erhalten.

Es lässt sich ebenfalls auch per Checkbox die aktuelle Kartenansicht mitgeben.
Dies meint Zentrum der Ansicht und Zoomstufe,
d.h. auf verschieden großen Bildschirmen sind verschiedene Kartenausschnitte sichtbar.

<a name="limitations"/>
## Schranken

Overpass Turbo beherrscht zwar nahezu alle Ausgabearten der Overpass API.
Es gibt aber dennoch ein paar Grenzen:

Pro Objekt-Id und -Typ zeigt Overpass Turbo nur ein Objekt an.
Daher lassen sich [Diffs](index.md) nicht sinnvoll mit Overpass Turbo anzeigen.

Overpass Turbo zeigt [GeoJSON](formats.md#json) direkt von der Overpass API nicht an.
Overpass Turbo bringt sein eigenes Konvertierungsmodul für GeoJSON mit,
und Martin hält die Benutzer-Verwirrung für zu groß,
wenn beide Mechanismen parallel im Einsatz sind.
Vorläufig muss für diesen Fall daher auf die experimentelle Instanz [https://olbricht.nrw/ovt/](https://olbricht.nrw/ovt/) verwiesen werden.
