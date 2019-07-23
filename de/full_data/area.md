Suche per Area
==============

Alle Daten in einem benannten Gebiet wie z.B. einer Stadt oder einem Bundesland.

<a name="deprecation"/>
## Warnung zur Zukunft

Der Anspruch an die Inhalte dieses Handbuchs ist,
dass sie auch in vielen Jahren noch zutreffen.
Für das derzeitige _Area_-Konzept gilt dies nicht unbedingt:
Der Datentyp ist entstanden, um kompatibel bleiben zu können,
falls im OpenStreetMap-Datenmodell ein Datentyp für Flächen dazukommt.
Mittlerweile bin ich sehr sicher, dass dies nicht mehr passieren wird.

Daher plane ich nun,
Flächen direkt ab den etablierten Typen _geschlossener Way_ und _Relations_ anzubieten.
Die konkrete Planung und Umsetzung wird sicherlich eher Jahre in Anspruch nehmen.
Am Ende diese Prozesses werden aber einige der hier aufgeführten Syntax-Varianten wohl veraltet sein.
Im Rahmen der [Rückwärtskompatibilität](../preface/assertions.md#infrastructure) werden möglichst wenige Abfragen für veraltet erklärt.

Derzeit ist beabichtigt,
dass _area_ dann als Synonym für _Way_ plus _Relation_ plus einen Evaluator ``is\_closed()`` verwendet wird.
Umgekehrt wird ``is_in`` dann wohl ebendiese Datentypen finden;
es wird sich anbieten, dieses _Statement_ dabei durch einen Filter abzulösen.

Umgekehrt bitte ich Sie, dies nicht als eine konkrete Ankündigung misszuverstehen.
Es gibt andere Anliegen im Projekt mit größerem Leidensdruck.

<a name="per_tag"/>
## Per Name oder per Tag

Der typische Einsatzfall für Flächen in der Overpass API ist,
alle Objekte von einem Typ oder alle Objekte generell in einem Gebiet herunterzuladen.
Wir fangen mit allen Objekten von einem mäßigen häufigen Typ an;
alle Objekte generell sind zum Üben viel zu viele Daten.
Wenn der _Area_-Mechanismus in diesem Abschnitt eingeführt ist,
folgt der Download aller Objekte im [folgenden Abschnitt](area.md#full).

Wir wollen zunächst [alle Supermärkte in London](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=area%5Bname%3D%22London%22%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28area%29%3B%0Aout%20center%3B) anzeigen:

    area[name="London"];
    nwr[shop=supermarket](area);
    out center;

Die eigentliche Arbeit wird in Zeile 2 geleistet:
dort beschränkt der _Filter_ ``(area)`` die zu selektierenden Objekte
auf solche nur in den Flächen aus der Eingabe;
wir müssen als vorher die _Area_ zu London geliefert haben.

Zeile 1 selektiert alle Objekte vom Typ _Area_,
die ein Tag _name_ mit dem Wert _London_ besitzen.
Dieser Objekttyp wird [unten](area.md#background) erläutert.
Es handelt sich im übrigen um ein spezielles [Query-Statement](../preface/design.md#statements).

Überraschenderweise verteilen sich die Fundstellen über den halben Planeten.
Es gibt eben viele Flächen namens London;
wir müssen ausdrücken, dass uns das große London in England interessiert.
Uns stehen gleich fünf verschiedene Lösungswege zur Verfügung,
unsere Anfrage zu präzisieren.

Wir können eine große Bounding-Box um die ungefähre Zielregion [legen und nutzen](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=area%5Bname%3D%22London%22%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28area%29%2850%2E5%2C%2D1%2C52%2E5%2C1%29%3B%0Aout%20center%3B):

    area[name="London"];
    nwr[shop=supermarket](area)(50.5,-1,52.5,1);
    out center;

Der Vollständigkeit halber sei darauf hingewiesen, dass dies auch mit dem [Komfortfeature von Overpass Turbo](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=area%5Bname%3D%22London%22%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28area%29%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) geht:

    area[name="London"];
    nwr[shop=supermarket](area)({{bbox}});
    out center;

In beiden Fällen ist die Bounding-Box ein Filter parallel zu ``(area)``.
Für das Provisorium _Area_ ist niemals eine Bounding-Box implementiert worden,
auch deswegen, da der Filter im Wesentlichen nur eine Anweisung später angewendet werden muss.

In ähnlicher Weise können wir auch ausnutzen, dass London in Großbritannien liegt.
Ein [späterer Abschnitt](area.md#combining) zeigt alle Möglichkeiten dazu auf.

Nicht zuletzt kann man auch weitere Tags zur Unterscheidung der _Areas_ mit gleichem _name_-Tag heranziehen.
Im Falle von London [hilft das Tag](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=area%5Bname%3D%22London%22%5D%5B%22wikipedia%22%3D%22en%3ALondon%22%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28area%29%3B%0Aout%20center%3B) zum Key _wikipedia_:

    area[name="London"]["wikipedia"="en:London"];
    nwr[shop=supermarket](area);
    out center;

Wie bereits der erste Filter nach Tag ``[name="London"]``
wird auch der zweite Filter ``["wikipedia"="en:London"]`` auf die _Area_-Query in Zeile 1 angewendet.
Dadurch bleibt diesmal nur das eine _Area_-Objekt übrig,
in dem wir tatsächlich suchen wollen.

Andere häufig nützliche Filter können ``admin_level`` mit oder ohne Wert oder ``type=boundary`` sein.
Es hilft dazu, sich zunächst alle gefundenen _Area_-Objekte [anzeigen zu lassen](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=area%5Bname%3D%22London%22%5D%3B%0Aout%3B);
bitte nach dem Ausführen per _Daten_ oben rechts auf die Daten-Ansicht umschalten:

    area[name="London"];
    out;

Zeile 2 gibt aus, was Zeile 1 findet.
Bitte sichten Sie die Funde danach, welche _Tags_ die richtige Fläche selektieren.
Mittels _pivot_-Filter in einem Query-Statement können Sie diese auch [visualisieren](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=):

    area[name="London"];
    nwr(pivot);
    out geom;

In Zeile 2 steht dabei ein reguläres Query-Statement.
Der _Filter_ ``(pivot)`` darin lässt genau diejenigen Objekte zu,
die die Erzeuger der in seiner Eingabe befindlichen _Areas_ sind.

Als fünfte Möglichkeit gibt es ein Komfort-Feature von [Overpass Turbo](../targets/turbo.md),
um Nominatim [auswählen zu lassen](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=%7B%7BgeocodeArea%3ALondon%7D%7D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28area%29%3B%0Aout%20center%3B):

    {{geocodeArea:London}};
    nwr[shop=supermarket](area);
    out center;

Dabei löst der Ausdruck ``{{geocodeArea:London}}`` aus,
dass _Overpass Turbo_ bei _Nominatim_ erfragt, was das plausibelste Objekt zu ``London`` ist.
Mittels der von Nominatim zurückgelieferten Id
ersetzt Overpass Turbo den Ausdruck durch eine Id-Query nach der zugehörigen Fläche,
hier z.B. ``area(3600065606)``.

<a name="full"/>
## Wirklich Alles

Wir wollen nun wirklich alle Daten in einem Gebiet herunterladen.
Das geht zwar mit fast der Abfrage, die wir [zum Üben](area.md#per_tag) verwendet haben.
Aber wir müssen das Werkzeug wechseln:
für ein Gebiet von der Größe London kommen schnell 10 Mio. Objekte oder mehr zusammen,
während _Overpass Turbo_ bereits ab etwa 2000 Objekten den Browser bis zur Unbrauchbarkeit verlangsamt.

Zudem sind Sie bei fast allen Gebieten in offiziellen Grenzen von Staaten bis Städten besser bedient mit regionalen Extrakten.
Details dazu [im dazugehörigen Abschnitt](other_sources.md#regional).

Sie können die Rohdaten zur Weiterverarbeitung direkt auf ihren lokalen Rechner herunterladen:
Dazu dient in _Overpass Turbo_ unter _Export_ oben links der Link ``Rohdaten direkt von der Overpass API``.
Es ist normal, dass nach de Klick erst einmal nichts passiert.
London herunterzuladen kann mehrere Minuten dauern.

Alternativ sei auf Download-Werkzeuge wie [Wget](https://www.gnu.org/software/wget/) oder [Curl](https://curl.haxx.se/) verwiesen.
Um das zu üben, speichern Sie bitte eine der Abfragen von oben in eine lokale Datei, z.B. ``london.ql``.

Sie können dann Abfragen stellen mit

    wget -O london.osm.gz --header='Accept-Encoding: gzip, deflate' \\
        --post-file=london.ql 'https://overpass-api.de/api/interpreter'

bzw.

    curl -H'Accept-Encoding: gzip, deflate' -d@- \\
        'https://overpass-api.de/api/interpreter' \\
        <london.ql >london.osm.gz

Beide Anweisungen können natürlich ohne den Rückstrich auch in je einer Zeile geschrieben werden.
In beiden Fällen tuen Sie mir, sich und allen übrigen Benutzern einen großen Gefallen,
wenn Sie den zusätzlichen Header ``Accept-Encoding: gzip, deflate`` setzen.
Dies gestattet dem Server, die Daten zu komprimieren,
was die Datenmengen um ca. den Faktor 7 verkleinert
und beide Enden der Verbindung entlastet.

Nun kommen wir zu der eigentlichen Abfrage.
Da eine Quelle großer Datenmengen bei vollen Daten räumliche ausgedehnte Relationen sind,
gibt es an den endgültigen Anwendungszweck [angepasste Varianten](osm_types.md).
Wir beschränken uns hier zunächst auf eine häufig passende Variante:

    area[name="London"]["wikipedia"="en:London"];
    (
      nwr(area);
      node(w);
    );
    out;

Alternativ sei noch eine Variante mit mehrfacher Nutzung des _Area_-Filters genannt.
Dann sollten die als Eingabe selektierten Areas in einer benannten _Set-Variable_ [zwischengespeichert](../preface/design.md#sets) werden:

    area[name="London"]["wikipedia"="en:London"]->.suchgebiet;
    (
      node(area.suchgebiet);
      way(area.suchgebiet);
      node(w);
    );
    out;

Hier schreibt in Zeile 3 das Query-Statement in die Standard-Auswahl.
Da die _Area_-Auswahl in Zeile 4 aber noch als Eingabe benötigt wird,
muss sie an einem anderen Ort als der Standard-Auswahl liegen.

<a name="combining"/>
## Fläche-in-Fläche

...
<!--
  Area-in-Area geht nicht, 2 Namen
  Overpass-Turbo, Id + 2.4 Mrd/3.6 Mrd
  map_to_area (auch Bbox)
-->

<a name="background"/>
## Technischer Hintergrund

...
<!--
Problem: Generierung
Viele Filter gehen nicht
Bbox-Alternative via map_to_area
...
-->

<!--
  Greenwich
  - Debug-Mode
-->

<!--
- Regex: ...
  Suche per Name, regulärer Ausdruck
  "London Borough of Greenwich"
-->

