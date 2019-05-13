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

...

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
die ihre Abfragen entsprechend verzögert Antworten erhalten.

Falls langlaufende Abfragen in der Größenordnung von Minuten die Slot belegt haben,
gibt die Status-Abfrage ab Zeile 6 Auskunft darüber,
wann welcher Slot wieder verfügbar ist.

### Timeout und Maxsize

...
