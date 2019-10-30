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
Umgekehrt wird ``is\_in`` dann wohl ebendiese Datentypen finden;
es wird sich anbieten, dieses _Statement_ dabei durch einen Filter abzulösen.

Umgekehrt bitte ich Sie, dies nicht als eine konkrete Ankündigung misszuverstehen.
Es gibt andere Anliegen im Projekt mit größerem Leidensdruck.

<a name="per_tag"/>
## Per Name oder per Tag

Der typische Einsatzfall für Flächen in der Overpass API ist,
alle Objekte von einem Typ oder alle Objekte generell in einem Gebiet herunterzuladen.
Wir fangen mit allen Objekten von einem mäßig häufigen Typ an;
alle Objekte generell sind zu viele Daten,
um mit kurzen Reaktionszeiten üben zu können.
Wenn der _Area_-Mechanismus in diesem Abschnitt eingeführt ist,
folgt der Download aller Objekte im [folgenden Abschnitt](#full).

Wir wollen zunächst [alle Supermärkte in London](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB) anzeigen:

    area[name="London"];
    nwr[shop=supermarket](area);
    out center;

Die eigentliche Arbeit wird in Zeile 2 geleistet:
dort beschränkt der _Filter_ ``(area)`` die zu selektierenden Objekte
auf solche nur in den Flächen aus dem Set ``_``;
wir müssen also vorher die _Area_ zu London geliefert haben.

Zeile 1 selektiert alle Objekte vom Typ _Area_,
die ein Tag mit Key ``name`` und Wert ``London`` besitzen.
Dieser Objekttyp wird [unten](#background) erläutert.
Es handelt sich im übrigen um ein spezielles [Query-Statement](../preface/design.md#statements).

Überraschenderweise verteilen sich die Fundstellen über den halben Planeten.
Es gibt eben viele Flächen namens London;
wir müssen ausdrücken, dass uns das große London in England interessiert.
Uns stehen gleich fünf verschiedene Lösungswege zur Verfügung,
unsere Anfrage zu präzisieren.

Wir können eine große Bounding-Box um die ungefähre Zielregion [legen und nutzen](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB):

    area[name="London"];
    nwr[shop=supermarket](area)(50.5,-1,52.5,1);
    out center;

Für Ihre Bequemlichkeit sei darauf hingewiesen, dass dies auch mit dem [Komfortfeature](../targets/turbo.md#convenience) von _Overpass Turbo_ [geht](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB):

    area[name="London"];
    nwr[shop=supermarket](area)({{bbox}});
    out center;

In beiden Fällen ist die Bounding-Box ein Filter parallel zu ``(area)``.
Für das Provisorium _Area_ ist niemals eine Bounding-Box implementiert worden,
auch deswegen, da es reicht,
den Filter eine Anweisung später anzuwenden.

In ähnlicher Weise können wir auch ausnutzen, dass London in Großbritannien liegt.
Ein [späterer Abschnitt](#combining) zeigt alle Möglichkeiten dazu auf.

Nicht zuletzt kann man auch weitere Tags zur Unterscheidung der _Areas_ mit gleichem _name_-Tag heranziehen.
Im Falle von London [hilft das Tag](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB) zum Key _wikipedia_:

    area[name="London"]["wikipedia"="en:London"];
    nwr[shop=supermarket](area);
    out center;

Wie bereits der erste Filter nach Tag ``[name="London"]``
wird auch der zweite Filter ``["wikipedia"="en:London"]`` auf die _Area_-Query in Zeile 1 angewendet.
Dadurch bleibt diesmal nur das eine _Area_-Objekt übrig,
in dem wir tatsächlich suchen wollen.

Andere häufig nützliche Filter können ``admin_level`` mit oder ohne Wert oder ``type=boundary`` sein.
Es hilft dazu, sich zunächst alle gefundenen _Area_-Objekte [anzeigen zu lassen](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB);
bitte nach dem Ausführen per _Daten_ oben rechts auf die Daten-Ansicht umschalten:

    area[name="London"];
    out;

Zeile 2 gibt aus, was Zeile 1 findet.
Bitte sichten Sie die Funde danach, welche _Tags_ die richtige Fläche selektieren.
Mittels _pivot_-Filter in einem Query-Statement können Sie diese auch [visualisieren](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB):

    area[name="London"];
    nwr(pivot);
    out geom;

In Zeile 2 steht dabei ein reguläres Query-Statement.
Der _Filter_ ``(pivot)`` darin lässt genau diejenigen Objekte zu,
die die Erzeuger der in seiner Eingabe befindlichen _Areas_ sind.
Das ist das Set ``_``;
es ist in Zeile 1 befüllt worden.

Als fünfte Möglichkeit gibt es ein Komfort-Feature von [Overpass Turbo](../targets/turbo.md),
um Nominatim [auswählen zu lassen](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB):

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
Das geht zwar mit fast der Abfrage, die wir [zum Üben](#per_tag) verwendet haben.
Aber wir müssen das Werkzeug wechseln:
für ein Gebiet von der Größe Londons kommen schnell 10 Mio. Objekte oder mehr zusammen,
während _Overpass Turbo_ bereits ab etwa 2000 Objekten den Browser bis zur Unbrauchbarkeit verlangsamt.

Zudem sind Sie bei fast allen Gebieten in offiziellen Grenzen von Staaten bis Städten besser bedient mit regionalen Extrakten.
Details dazu [im dazugehörigen Abschnitt](other_sources.md#regional).

Sie können die Rohdaten zur Weiterverarbeitung direkt auf ihren lokalen Rechner herunterladen:
Dazu dient in _Overpass Turbo_ unter _Export_ oben links der Link ``Rohdaten direkt von der Overpass API``.
Es ist normal, dass nach de Klick erst einmal nichts passiert.
London herunterzuladen kann mehrere Minuten dauern.

Alternativ sei auf Download-Werkzeuge wie [Wget](https://www.gnu.org/software/wget/) oder [Curl](https://curl.haxx.se/) verwiesen.
Um das zu üben, speichern Sie bitte eine der Abfragen von oben in eine lokale Datei, z.B. ``london.ql``.

Sie können dann Abfragen ab der Kommandozeile stellen mit
<!-- NO_QL_LINK -->

    wget -O london.osm.gz --header='Accept-Encoding: gzip, deflate' \\
        --post-file=london.ql 'https://overpass-api.de/api/interpreter'

bzw.
<!-- NO_QL_LINK -->

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
<!-- NO_QL_LINK -->

    area[name="London"]["wikipedia"="en:London"];
    (
      nwr(area);
      node(w);
    );
    out;

Alternativ sei noch eine Variante mit mehrfacher Nutzung des _Area_-Filters genannt.
Dann sollten die als Eingabe selektierten Areas in einer _benannten Set-Variable_ [zwischengespeichert](../preface/design.md#sets) werden:
<!-- NO_QL_LINK -->

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

Wir kommen zurück zu dem Problem,
London als Fläche in Großbritannien auszuwählen.
Das ist nicht implementiert,
aber es gibt auch hier wieder zwei andere Möglichkeiten.

Man kann Objekte suchen, die [in der Schnittmenge zweier Flächen](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=8&Q=CGI_STUB) liegen:

    area[name="London"]->.klein;
    area[name="England"]->.grosz;
    nwr[shop=supermarket](area.klein)(area.grosz);
    out center;

Das eigentliche Filtern findet im Query-Statement in Zeile 3 statt;
dort werden nur Objekte zugelassen, die alle drei Filter erfüllen:
Der Filter ``[shop=supermarket]`` lässt nur Objekte mit dem entsprechenden Tag zu.
Der Filter ``(area.klein)`` beschränkt dies auf Objekte,
die innerhalb einer der in ``klein`` befindlichen Flächen liegen.
Der Filter ``(area.grosz)`` reduziert dies weiter auf Objekte,
die innerhalb einer der in ``grosz`` befindlichen Flächen liegen.

Nun müssen wir nur noch sicherstellen,
dass in ``klein`` bzw. ``grosz`` die gewollten Flächen drinstehen.
Die erledigen jeweils Query-Statements nach _Areas_ in den Zeilen 1 und 2,
die ihr Ergebnis in eine benannte Variable speichern.

Das andere Vorgehen verwendet den Zusammenhang zwischen _Area_ und dem erzeugenden Objekt,
allerdings diesmal in die dem Filter _pivot_ entgegengesetzte Richtung.
Wir [selektieren](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=8&Q=CGI_STUB) das erzeugte Objekt der kleinen Fläche:

    area[name="England"];
    rel[name="London"](area);
    map_to_area;
    nwr[shop=supermarket](area);
    out center;

In Zeile 4 wollen wir für den Filter ``(area)`` exakt die _Area_ zu London als Eingabe haben.
Dazu selektieren wir in Zeile 2 alle _Relations_, die den Namen _London_ haben
und innerhalb einer der Flächen liegen,
die ``(area)`` in der EIngabe im Default-Set ``_`` vorfindet.
Für diese hatten wir in Zeile 1 alle Flächen mit Name _England_ ausgewählt.

Nun brauchen wir aber in Zeile 4 ja Flächen,
während der Filter ``(area)`` keine Flächen filtern kann und wir daher _Relations_ selektiert haben.
Dies erledigt ``map_to_area``:
es ordnet den Objekten aus seiner Eingabe die von den Objekten erzeugten Flächen zu.

<a name="background"/>
## Technischer Hintergrund

Bereits am Anfang des Overpass-Projekts im Jahr 2009 sollte es die Möglichkeit geben,
ein geometrisches A-liegt-in-B nutzen zu können.
Das hat sich nur denkbar schlecht mit der Anforderung vertragen,
[OpenStreetMap-Daten treu abzubilden](../preface/assertions.md#faithful):
Flächen sind in OpenStreetMap ein gemischtes Konzept aus Geometrie und Tags,
es gab glaubwürdige Bestrebungen, einen eigenen Datentyp _Area_ zu entwickeln,
und die Regeln dafür, wann genau ein OpenStreetMap-Objekt eine Fläche ist, sind damals noch im Fluss gewesen.
Zuletzt gab es den Eindruck, dass Flächen leicht beschädigt werden könnten und dies häufiger zu erwarten ist.

Daher sind _Areas_ in Overpass API ein eigener Datentyp.
Der Server erzeugt diese in einem zyklischen Hintergrundprozess nach einem vom Code getrennten [Regelsatz](https://github.com/drolbr/Overpass-API/tree/master/src/rules).
Damit haben es potentielle Betreiber eigener Instanzen einfacher,
selbst zu entscheiden, welche Flächen sie erzeugen wollen.
Jede _Area_ übernimmt dabei bei ihrer Erzeugung die Tags des Objektes, aus dem sie erzeugt worden ist.

Dies zieht Folgen nach sich:

* Flächen stehen erst viele Stunden später zu Verfügung als ihre erzeugenden Objekte.
  Entsprechend wirken sich auch Änderungen an den erzeugenden Objekten verzögert aus.
* Ergibt ein erzeugendes Objekt keine gültige Fläche mehr,
  so bleibt das alte _Area_-Objekt bestehen, bis wieder eine neue gültige Fläche erzeugt werden kann.
* Areas haben eigene Regeln, nach denen ihre Ids vergeben werden.
* Nur ein Teil der Filter für OpenStreetMap-Objekte steht auch für _Areas_ zur Verfügung.

Der große Vorteil ist aber, dass die Suche Punkt-in-Fläche effizient und zuverlässig funktioniert.

Als Nachteil hat sich herausgestellt, dass nicht alle nachgefragten _Area_-Objekte existieren:
mittlerweile wird fast jedes Objekt in OpenStreetMap, das von seiner Geometrie her eine Fläche ergibt,
auch als Fläche genutzt.
Wenn aber gemäßg den Tagging-Regeln der Hintergrundprozess das Objekt nicht für eine Fläche hält,
gibt es kein korrespondierendes _Area_-Objekt.

Umgekehrt ist mir in den letzten 10 Jahren keine Instanz begegnet,
die ihre Flächen-Regelwerk an ihre speziellen Bedürfnisse angepasst hat.
Es gab wohl eher einen Tradeoff, weniger Flächen zu akzeptieren,
um Rechenzeit beim Hintergrundprozess zu sparen.
Damit ist der Regelsatz doch de facto zentral festgelegt,
und dies beraubt ihn der meisten seiner Vorteile.

Daher beabsichtige ich mittlerweile,
auch die Flächenoperationen direkt auf den OpenStreetMap-Objekten auszuführen.
