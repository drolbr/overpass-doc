Allmende
========

Es gibt eine öffentliche Instanz, die größtmögliche Ressourcen bereitstellt,
aber auch gegen Übernutzung verteidigt.
Großnutzer können leicht eine eigene Instanz aufsetzen.

## Größenordnungen

Ziel der öffentlichen Instanzen ist es,
möglichst vielen Nutzern zur Verfügung zu stehen.
Die Rechenleistung der Server muss zwischen den täglich etwa 30.000 Nutzern aufgeteilt werden.

Die typische Abfrage hat eine Laufzeit von unter 1 Sekunde,
es gibt jedoch auch deutlich länger laufende Anfragen.
Jeder Server der Overpass API kann davon etwa 1 Mio. Anfragen pro Tag beantworten,
und es werden zwei Server im Rahmen von [overpass-api.de](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances) betrieben.

Beispiele für problematisches Verhalten sind:

1. zehntausende Male pro Tag die exakt gleiche Abfrage (von der gleichen Adresse) auszuführen
2. millionenweise nach jeweils einem einzelnen Element per Id zu fragen
3. Bounding-Boxen aneinanderzuhängen, um insgesamt die gesamten Daten der Welt herunterzuladen
4. eine App für mehr als nur alle OSM-Mapper aufzusetzen
   und sich auf die öffentlichen Instanzen als Backend zu verlassen

Im ersten Fall muss das abfragende Skript repariert werden,
in den Fällen 2 und 3 sollte anstatt der Overpass API lieber ein [Planet-Dump](https://wiki.openstreetmap.org/wiki/Planet.osm) verwendet werden.
Im vierten Fall ist eine eigene Instanz die bessere Wahl;
Hinweise zur Einrichtung gibt der folgende Absatz.

Tatsächlich stellen die meisten Nutzer aber nur jeweils wenige Anfragen.
Die automatische Lastbegrenzung zielt also darauf ab,
die ersten paar Abfragen pro Nutzer gegenüber massenhaften Abfragen einzelner Nutzer zu bevorzugen.
Eine manuelle Lastbeschränkung wird also zuerst bei den intensivsten Nutzer orientieren,
und die nachfolgenden Schätzungen zur Maximalnutzung halten von deren Nutzungsintensität einen sicheren Abstand.

Über die öffentlichen Instanzen lässt sich üblicherweise noch ein Abfrageaufkommen abwickeln,
dass weder 10000 Abfragen pro Tag noch 1 GB Downloadvolumen pro Tag überschreitet.

Zu den Zielen gehört aber auch, den Betrieb einer eigenen Instanz möglichst einfach zu gestalten.
Wer seinen Bedarf auf mehr als die obigen Nutzungsgrenzen schätzt,
lese also bitte den nachfolgenden Absatz.

Wer dagegen mehr über die automatische Lastbegrenzung wissen will oder muss,
lese bitte den letzten Absatz.

## Eigene Instanz

In Englisch ist eine [kurze](https://overpass-api.de/no_fills.html) und eine [lange](https://overpass-api.de/full_installation.html) Anleitung verfügbar.
Es sind drei Schritte erforderlich:

1. Die Software installieren
2. OpenStreetMap-Daten laden
3. Service und Webserver konfigurieren

Die Schritte 1 und 2 sind getrennt,
da die Datenmengen so groß sind,
dass die meisten Nutzer ihr Vorgehen daran ausrichten werden wollen.

### Software installieren

Stelle Sie sicher, dass die GNU-Autotools, ein C++-Compiler, das Hilfsprogramm _wget_ und die Bibliotheken _expat_ und _zlib_ installiert sind.
Versionen dieser Programme spielen keine Rolle;
die Overpass API nutzt ausdrücklich nur deren versionsunabhängige Kernfunktionen.

Unter z.B. Ubuntu erreichen Sie wie folgt, dass alle benötigen Programme installiert sind:

    sudo apt-get install wget g++ make expat libexpat1-dev zlib1g-dev

Von der Overpass API laden Sie bitte das jeweils [neueste Release](https://dev.overpass-api.de/releases/) herunter
und packen Sie das Archiv aus.
Mit älteren Releases funktioniert dies auch;
wegen der Rückwärtskompatibilität wird es aber eigentlich nie einen Grund für ältere Releases geben.

Es wird an der Kommandozeile mit

    ./configure
    make
    chmod 755 bin/*.sh cgi-bin/*

kompiliert und installiert.
Das letzte Kommando ist erforderlich,
damit wir keine Root-Rechte benötigen.

Normalerweise würde eine Linux-Software mit der Dreierfolge ``configure`` - ``make`` - ``make install`` installiert.
Dieser letzte Schritt kopiert die ausführbaren Dateien ins Standard-Programmverzeichnis
und schaltet die Dateien im Dateisystem auf ausführbar.
Das Kopieren braucht aber zurecht Root-Rechte.
Also lassen wir die ausführbaren Dateien am den Ort,
an dem sie kompiliert worden sind
und schalten sie mit ``chmod`` ausführbar.

Die ausführbaren Dateien sind im Dateisystem grundsätzlich frei beweglich.
Einige der Skripte vermuten jedoch die übrigen Dateien im gleichen Verzeichnis wie sich selbst oder in ``../bin``.
Daher sollten Sie die Verzeichnisse ``bin`` und ``cgi-bin`` vollständig und gemeinsam verschieben.

### Daten laden

Im Gegensatz zu der relativ kleinen Datenmenge für die Software sind die OpenStreetMap-Daten sehr groß.
Weltweite Daten füllen auch mit nur den aktuellsten Geodaten bereits 100 GB (Stand 2019).
Mit allen alten Datenständen und Metadaten sind 300 GB notwendig.

Die Daten können aus einem öffentlich zugänglichen, täglich aktualisierten Datenbestand eins zu eins kopiert werden.
Dieser Vorgang heißt auch _klonen_:

    mkdir -p db
    bin/download_clone.sh --db-dir="db/" --meta=no \\
        --source="https://dev.overpass-api.de/api_drolbr/"

Dabei steuert ``meta`` den Detaillierungsgrad und damit die Datenmenge:
Mit dem Wert ``no`` bleibt es bei den Sachdaten,
``meta`` lädt zusätzlich auch die Metadaten der Bearbeiter
und ``attic`` lädt sowohl Metadaten als auch alle alten Datenstände.

Die Sachdaten sind datschutzrechtlich unkritisch.
Die Meta- und/oder alten Datenstände dagegen dürfen Sie nur laden,
wenn Sie ein berechtigtes Interesse haben.

Nach erfolgreichem Klonen können Sie per

    bin/osm3s_query --db-dir="db/"

bereits Abfragen stellen, indem Sie die Abfrage auf der Standardeingabe übergeben.

### Daten erzeugen

Wenn Sie nur mit einem lokalen Ausschnitt der OpenStreetMap-Daten arbeiten wollen,
dann können Sie auch aus [einem Extrakt im OSM-XML-Format](https://download.geofabrik.de) selbst eine Datenbank erstellen.

Diese Extrakte sind üblicherweise komprimiert.
Sie können aber in einem Schritt dekomprimieren und die Daten importieren.
Ersetzen Sie im nachfolgenden Kommando ``$OSM_XML_FILE`` durch den Namen der heruntergeladenen Datei,
``$EXEC_DIR`` durch das Verzeichnis, in das Sie kompiliert haben,
und ``$DB_DIR`` durch das Verzeichnis, in dem die Daten abgelegt werden sollen.

Normalerweise können Sie ``$META`` weglassen.
Falls Sie ein berechtigtes Interesse haben, das den Datenschutz der OSM-Nutzer überwiegt,
können Sie mit ``--meta`` die Metadaten oder mit ``--keep-attic`` zusätzlich die alten Datenstände laden.

Für eine BZ2-komprimierte Datei:

    bunzip2 <$OSM_XML_FILE \\
        | $EXEC_DIR/bin/update_database --db-dir="$DB_DIR/" $META

Für eine Gzip-komprimierte Datei:

    gunzip <$OSM_XML_FILE \\
        | $EXEC_DIR/bin/update_database --db-dir="$DB_DIR/" $META

Die Ausführung dieses Kommandos kann sehr lange dauern.
Je nach Größe der Datei kann die Laufzeit zwischen Minuten und durchaus 24 Stunden liegen.

Nach erfolgreichem Import können Sie per

    bin/osm3s_query --db-dir="$DB_DIR/"

bereits Abfragen stellen, indem Sie die Abfrage auf der Standardeingabe übergeben.

### Service konfigurieren

Zur Anwendung von Updates benötigten Sie drei permanent laufende Prozesse.

Das Skript ``fetch_osc.sh`` lädt die minütlichen Updates herunter,
sobald sie jeweils verfügbar werden;
sie werden in einem ausgewiesenen Verzeichnis gespeichert.
Das Skript ``apply_osc_to_db.sh`` wendet die in diesem Verzeichnis vorgefundenen Dateien auf die Datenbank an.

Der Daemon ``dispatcher`` kümmert sich darum,
dass sich der schreibende und die lesenden Prozesse nicht in die Quere kommen
- sonst könnte ein Prozess Daten lesen wolllen,
die von einem Update bereits auf einen späteren Stand geändert worden sind.
Lesende und schreibende Prozesse kommunizieren mit dem ``dispatcher`` über zwei spezielle Dateien;
ein Shared Memory mit festem Namen hilft den Prozessen, den ``dispatcher`` zu finden,
der Socket im Datenverzeichnis ist für die Kommunikation zuständig.

Mit den folgenden Kommandos können die benötigten Prozesse dauerhaft gestartet werden;
damit muss ``$DB_DIR`` durch den Namen des Datenverzeichnisses ersetzt werden,
und ``$ID`` muss durch den Inhalt von ``$DB_DIR/replicate_id`` ersetzt werden.

    nohup bin/dispatcher --osm-base --meta --db-dir="$DB_DIR/" &
    chmod 666 "$DB_DIR/osm3s_v0.7.55_osm_base"
    nohup bin/fetch_osc.sh $ID \\
        "https://planet.openstreetmap.org/replication/minute/" \\
        "diffs/" &
    nohup bin/apply_osc_to_db.sh "diffs/" auto --meta=yes &


Sie sollten nun in der Lage sein, mit

    bin/osm3s_query

Abfragen auszuführen, indem Sie die Abfrage auf der Standardeingabe übergeben.

### Webserver konfigurieren

Die Datenbank kann übers Web angesprochen werden,
indem sie von einem Webserver per _Common Gateway Interface_ [(CGI)](https://de.wikipedia.org/wiki/Common_Gateway_Interface) angesprochen wird.

Es gibt viele verschiedene Webserver;
die öffentliche Instanzen werden aktuell mit Apache betrieben,
aber es sind auch über Jahre erfolgreich Versionen mit Nginx betrieben worden.
Wir erläutern hier beispielhaft eine Konfiguration mit Apache.

Das _Common Gateway Interface_ muss in Apache erst zugeschaltet werden,
indem das Modul ``cgi.load`` im Unterzeichnis ``mods-enabled`` auf ihr Gegenstück im Unterverzeichnis ``mods-available`` verlinkt wird.

Danach muss im zugehörigen ``VirtualHost``,
üblicherweise im Verzeichnis ``sites-enabled``,
das CGI-Verzeichnis deklariert werden.
Bei den öffentlichen Instanzen mit Apache 2.4 erledigt dies der nachfolgende Block;
dabei muss ``$ABSPATH_TO_EXEC_DIR`` durch den absoluten Pfad zum Zielverzeichnis ersetzt werden.

    ScriptAlias /api/ "$ABSPATH_TO_EXEC_DIR"
    <Directory "$ABSPATH_TO_EXEC_DIR">
        AllowOverride None
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Require all granted
    </Directory>

## Regeln

Die automatische Lastbegrenzung ordnet Abfragen (anonymen) Benutzern zu
und stellt die Erreichbarkeit für Wenignutzer sicher,
wenn das Abfragevolumen aller Nutzer die Serverkapazität übersteigt.

Es gibt derzeit zwei voneinander unabhängige öffentliche Instanzen,
[z.overpass-api.de](https://z.overpass-api.de/api/status) und [lz4.overpass-api.de](https://lz4.overpass-api.de/api/status).
Wir beginnen mit der Erläuterung dieser Status-Abfragen.

### Rate-Limit

Die Zuordnung zu Benutzern erfolgt üblicherweise per IP-Adresse.
Ist ein Benutzerschlüssel gesetzt, so wird dieser vorrangig verwendet.
Bei IPv4-Adressen wird die volle IP-Adresse ausgewertet;
bei IPv6-Adressen die oberen 64 Bit der IP-Adresse.
Für IPv6-Adressen ist noch nicht klar,
welche Gepflogenheiten sich durchsetzen,
so dass eine Verkürzung auf weniger Bits vorbehalten bleibt.
Die vom Server ermittelte Benutzernummer steht in der ersten Zeile der [Status-Abfrage](https://overpass-api.de/api/status) hinter ``Connected as:``.

Jede Ausführung einer Abfrage belegt einen Slot pro Benutzer,
und zwar für die Ausführungsdauer der Abfrage plus eine Beruhigungszeit.
Der Zweck der Beruhigungszeit ist,
anderen Benutzern die Chance zu Abfragen zu geben.
Die Beruhigungszeit wächst mit der Auslastung des Servers und proportional zur Ausführungsdauer.
Bei geringer Auslastung beträgt die Beruhigungszeit nur einen Bruchteil der Ausführungsdauer,
bei hoher Auslastung auch durchaus ein Vielfaches.

Eine Slippy-Map würde nun viele kurzlaufende Abfragen in kurzer Zeit absetzen.
Damit ein Benutzer alle diese Abfragen beantwortet bekommen kann,
gibt es zwei Kulanzmechanismen:

- Es gibt üblicherweise mehrere Slots.
  Die Anzahl der Slots steht in der dritten Zeile hinter ``Rate limit:``.
- Abfragen werden bis zu 15 Sekunden auf dem Server offengehalten,
  wenn ihnen noch kein Slot zur Verfügung steht.

Benötigt eine solche Slippy-Map also z.B. 20 Abfragen zu 1 Sekunde Laufzeit,
ist die Anzahl der Slots gleich 2 und das Verhältnis von Abfragedauer zu Beruhigungszeit 1:1,
so würden

- die ersten zwei Abfragen sofort abgewickelt
- die nächsten zwei Abfragen entgegengenommen
  und nach 2 Sekunden (1 Sekunde Ausführungsdauer plus 1 Sekunde Beruhigungszeit) ausgeführt
- die weiteren Abfragen entsprechend später ausgeführt
- die Abfragen 15 und 16 an jeweils fünfter Position nach 14 Sekunden ausgeführt
- die Abfragen 17 bis 20 nach 15 Sekunden verworfen,
  da sie bis dahin keinen Slot bekommen haben

Wenn der Benutzer die Inhalte der Abfragen 17 bis 20 noch braucht,
(und nicht bereits weggescrollt hat)
dann sollte das Client-Framework die Abfragen 17 bis 20 nach Ablauf der 15 Sekunden erneut stellen.
Im [Abschnitt über OpenLayers und Leaflet](../targets/openlayers.md) gibt es eine Referenz-Implementierung.

Die Grund für diesen Mechanismus sind Skripte in Endlosschleife:
viele führen je eine Abfrage parallel aus und werden dann sinnvoll verzögert,
da ihre Abfragen entsprechend verzögert Antworten erhalten.

Falls langlaufende Abfragen in der Größenordnung von Minuten den Slot belegt haben,
gibt die Status-Abfrage ab Zeile 6 Auskunft darüber,
wann welcher Slot wieder verfügbar ist.

Wegen des Rate-Limits abgelehnte Abfragen werden mit dem [HTTP-Statuscode 429](https://tools.ietf.org/html/rfc6585#section-4) beantwortet.

### Timeout und Maxsize

unabhängig von diesem Rate-Limit gibt es einen zweiten Mechanismus;
er bevorzugt kleine Abfragen vor großen Abfragen,
damit viele Nutzer mit kleinen Abfragen auch dann noch bedient werden können,
wenn die Kapazität für die Nutzer mit den größen Abfragen zusammen nicht mehr reicht.

Es gibt zwei Kriterien dafür, pro Laufzeit und pro Speicherbedarf.
Jede Abfrage enthält eine Deklaration zu ihrer erwarteten Maximallaufzeit und zu ihrem erwarteten maximalen Speicherbedarf.
Die Deklaration der Maximallaufzeit kann explizit durch ein vorangestelltes ``[timeout:...]`` erfolgen;
die Deklaration des maximalen Speicherbedarfs durch ein vorangestelltes ``[maxsize:...]``.

Überschreitet eine Abfrage ihre deklarierte Maximallaufzeit oder ihren deklarierten maximalen Speicherbedarf,
so wird sie vom Server abgebrochen.
Dieses [Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=10&Q=%5Btimeout%3A3%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) bricht nach 3 Sekunden ab:

    [timeout:3];
    nwr[shop=supermarket]({{bbox}});
    out center;

Das [gleiche Beispiel mit mehr Zeit](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=10&Q=%5Btimeout%3A90%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) funktioniert:

    [timeout:90];
    nwr[shop=supermarket]({{bbox}});
    out center;

Ist bei einer Abfrage keine Maximallaufzeit deklariert,
so wird eine Maximallaufzeit von 180 Sekunden gesetzt.
Für den maximalen Speicherbedarf ist der Defaultwert 536870912;
dies entspricht 512 MiB.

Der Server lässt nun eine Abfrage genau dann zu,
wenn sie in beiden Kriterien höchstens die Hälfte der noch verfügbaren Ressourcen belegt.
Für den maximalen Speicherbedarf ist der Wert z.B. 12 GiB.
Wenn also gerade 8 Abfragen zu 512 MiB laufen,
so sind 4 GiB belegt.
Eine weitere Abfrage würde also genau dann zugelassen,
wenn sie weniger als 4 GiB anfordert.
Mit dieser neunten Abfrage zusammen wäre dann noch 4 GiB frei,
so dass dann nur noch eine weitere Abfrage zu weniger als 2 GiB akzeptiert würde.

Bei der Laufzeit verhält es sich entsprechend.
Der übliche Gesamtwert für zulässige Zeiteinheiten sind 262144.
Es wird also eine Abfrage mit Maximallaufzeit 1 Tag recht bequem zugelassen,
aber jede weitere parallele Abfrage mit einer so langen Maximallaufzeit dann abgelehnt.
Der Rate-Limit-Mechanismus sorgt dann mit der anschließenden Beruhigungszeit in der Größenordnung von Tagen dafür,
dass nicht immer derselbe Nutzer eine so lange Maximallaufzeit anfordern kann.

Wie beim Rate-Limit lehnt der Server zu große Abfragen nicht sofort ab,
sondern wartet 15 Sekunden,
ob nicht in der Zwischenzeit genügend andere Abfragen beendet worden sind.

Wegen unzureichender Ressourcen abgelehnte Abfragen werden mit dem [HTTP-Statuscode 504](https://tools.ietf.org/html/rfc7231#section-6.6.5) beantwortet.
