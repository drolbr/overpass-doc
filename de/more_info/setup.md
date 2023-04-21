Eigene Instanz aufsetzen
========================

Wie kann ich eine eigene Instanz aufsetzen,
um beliebig viele Abfragen ausführen zu können?

In Englisch ist eine [kurze](https://overpass-api.de/no_frills.html) und eine [lange](https://overpass-api.de/full_installation.html) Anleitung verfügbar.
Es sind drei Schritte erforderlich:

1. Die Software installieren
2. OpenStreetMap-Daten laden
3. Service und Webserver konfigurieren

Die Schritte 1 und 2 sind getrennt,
da die Datenmengen so groß sind,
dass die meisten Nutzer ihr Vorgehen daran ausrichten werden wollen.

Alternativ kann die Overpass API auch [mit Docker-Containern](https://github.com/drolbr/docker-overpass) installiert werden.

## Software installieren

Stellen Sie sicher, dass die GNU-Autotools, ein C++-Compiler, das Hilfsprogramm _wget_ und die Bibliotheken _expat_, _zlib_ und _lz4_ installiert sind.
Versionen dieser Programme spielen keine Rolle;
die Overpass API nutzt ausdrücklich nur deren versionsunabhängige Kernfunktionen.

Unter z.B. Ubuntu erreichen Sie wie folgt, dass alle benötigen Programme installiert sind:

    sudo apt-get install wget g++ make expat libexpat1-dev zlib1g-dev \
        liblz4-dev

Von der Overpass API laden Sie bitte das jeweils [neueste Release](https://dev.overpass-api.de/releases/) herunter.
Mit älteren Releases funktioniert dies auch;
wegen der Rückwärtskompatibilität wird es aber eigentlich nie einen Grund für ältere Releases geben.

Packen Sie die heruntergeladene Gzip-Datei aus und wechseln Sie in das angelegte Verzeichnis.

Es wird an der Kommandozeile mit

    ./configure --enable-lz4
    make
    chmod 755 bin/*.sh cgi-bin/*

kompiliert und installiert.
Wir verwenden hier ein Kommando, um im Installationsverzeichnis die Dateien auszuführen,
damit wir keine Root-Rechte für den Zugriff aufs Systemverzeichnis benötigen.

Normalerweise würde eine Linux-Software mit der Dreierfolge `configure` - `make` - `make install` installiert.
Dieser letzte Schritt kopiert die ausführbaren Dateien ins Standard-Programmverzeichnis
und schaltet die Dateien im Dateisystem auf ausführbar.
Das Kopieren braucht aber zurecht Root-Rechte.
Also lassen wir die ausführbaren Dateien am den Ort,
an dem sie kompiliert worden sind
und schalten sie mit `chmod` ausführbar.

Die ausführbaren Dateien sind im Dateisystem grundsätzlich frei beweglich.
Einige der Skripte vermuten jedoch die übrigen Dateien im gleichen Verzeichnis wie sich selbst oder in `../bin`.
Daher sollten Sie die Verzeichnisse `bin` und `cgi-bin` vollständig und gemeinsam verschieben.

## Daten laden

Im Gegensatz zu der relativ kleinen Datenmenge für die Software sind die OpenStreetMap-Daten sehr groß.
Weltweite Daten füllen auch mit nur den aktuellsten Geodaten bereits 150 GB (Stand 2022).
Mit allen alten Datenständen und Metadaten sind 360 GB notwendig.

Die Daten können aus einem öffentlich zugänglichen, täglich aktualisierten Datenbestand eins zu eins kopiert werden.
Dieser Vorgang heißt auch _klonen_:

    mkdir -p db
    bin/download_clone.sh --db-dir="db/" --meta=no \\
        --source="https://dev.overpass-api.de/api_drolbr/"

Dabei steuert `meta` den Detaillierungsgrad und damit die Datenmenge:
Mit dem Wert `no` bleibt es bei den Sachdaten,
`meta` lädt zusätzlich auch die Metadaten der Bearbeiter
und `attic` lädt sowohl Metadaten als auch alle alten Datenstände.

Die Sachdaten sind datenschutzrechtlich unkritisch.
Die Meta- und/oder alten Datenstände dagegen dürfen Sie nur laden,
wenn Sie ein berechtigtes Interesse haben.

Nach erfolgreichem Klonen können Sie per

    bin/osm3s_query --db-dir="db/"

bereits Abfragen stellen, indem Sie die Abfrage auf der Standardeingabe übergeben.

## Daten erzeugen

Wenn Sie nur mit einem lokalen Ausschnitt der OpenStreetMap-Daten arbeiten wollen,
dann können Sie auch aus [einem Extrakt im OSM-XML-Format](https://download.geofabrik.de) selbst eine Datenbank erstellen.

Diese Extrakte sind üblicherweise komprimiert.
Sie können aber in einem Schritt dekomprimieren und die Daten importieren.
Ersetzen Sie im nachfolgenden Kommando `$OSM_XML_FILE` durch den Namen der heruntergeladenen Datei,
`$EXEC_DIR` durch das Verzeichnis, in das Sie kompiliert haben,
und `$DB_DIR` durch das Verzeichnis, in dem die Daten abgelegt werden sollen.

Normalerweise können Sie `$META` weglassen.
Falls Sie ein berechtigtes Interesse haben, das den Datenschutz der OSM-Nutzer überwiegt,
können Sie mit `--meta` die Metadaten oder mit `--keep-attic` zusätzlich die alten Datenstände laden.

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

## Service konfigurieren

Zur Anwendung von Updates benötigen Sie drei permanent laufende Prozesse.

Das Skript `fetch_osc.sh` lädt die minütlichen Updates herunter,
sobald sie jeweils verfügbar werden;
sie werden in einem ausgewiesenen Verzeichnis gespeichert.
Das Skript `apply_osc_to_db.sh` wendet die in diesem Verzeichnis vorgefundenen Dateien auf die Datenbank an.

Der Daemon `dispatcher` kümmert sich darum,
dass sich der schreibende und die lesenden Prozesse nicht in die Quere kommen
- sonst könnte ein Prozess Daten lesen wolllen,
die von einem Update bereits auf einen späteren Stand geändert worden sind.
Lesende und schreibende Prozesse kommunizieren mit dem `dispatcher` über zwei spezielle Dateien;
ein Shared Memory mit festem Namen hilft den Prozessen, den `dispatcher` zu finden,
der Socket im Datenverzeichnis ist für die Kommunikation zuständig.

Mit den folgenden Kommandos können die benötigten Prozesse dauerhaft gestartet werden;
damit muss `$DB_DIR` durch den Namen des Datenverzeichnisses ersetzt werden,
und `$ID` muss durch den Inhalt von `$DB_DIR/replicate_id` ersetzt werden.

    nohup bin/dispatcher --osm-base --meta --db-dir="$DB_DIR/" &
    chmod 666 "$DB_DIR"/osm3s_v*_osm_base
    nohup bin/fetch_osc.sh $ID \\
        "https://planet.openstreetmap.org/replication/minute/" \\
        "diffs/" &
    nohup bin/apply_osc_to_db.sh "diffs/" auto --meta=yes &

Sie sollten nun in der Lage sein, mit

    bin/osm3s_query

Abfragen auszuführen, indem Sie die Abfrage auf der Standardeingabe übergeben.

## Webserver konfigurieren

Die Datenbank kann übers Web angesprochen werden,
indem sie von einem Webserver per _Common Gateway Interface_ [(CGI)](https://de.wikipedia.org/wiki/Common_Gateway_Interface) angesprochen wird.

Es gibt viele verschiedene Webserver;
die öffentliche Instanzen werden aktuell mit Apache betrieben,
aber es sind auch über Jahre erfolgreich Versionen mit Nginx betrieben worden.
Wir erläutern hier beispielhaft eine Konfiguration mit Apache.

Das _Common Gateway Interface_ muss in Apache erst zugeschaltet werden,
indem das Modul `cgi.load` im Unterzeichnis `mods-enabled` auf ihr Gegenstück im Unterverzeichnis `mods-available` verlinkt wird.

Danach muss im zugehörigen `VirtualHost`,
üblicherweise im Verzeichnis `sites-enabled`,
das CGI-Verzeichnis deklariert werden.
Bei den öffentlichen Instanzen mit Apache 2.4 erledigt dies der nachfolgende Block;
dabei muss `$ABSPATH_TO_EXEC_DIR` durch den absoluten Pfad zum Zielverzeichnis ersetzt werden.

    ScriptAlias /api/ "$ABSPATH_TO_EXEC_DIR"
    <Directory "$ABSPATH_TO_EXEC_DIR">
        AllowOverride None
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Require all granted
    </Directory>
