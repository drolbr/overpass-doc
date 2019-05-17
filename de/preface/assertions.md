Grundsätze
==========

Die Overpass API wird Tagging-Schemata weder fördern noch behindern.
Es ist Rückwärtskompatibilität für Jahrzehnte beabsichtigt.

## Lokal schnell

Die Overpass API ist darauf ausgelegt,
räumlich zusammengehörige Daten schnell zu liefern.
Räumlich weit entfernte Daten kann die Overpass API zwar auch liefern,
aber hat dann keinen Vorteil gegenüber einer generischen Datenbank.

An vielen Abschnitten in diesem Handbuch wird daher auf Tools verwiesen,
die für den jeweiligen Anwendungszweck stärker optimiert sind.

## Treue zum Datenmodell

Das OpenStreetMap-Datenmodell hat zwar durch seine Einfachheit maßgeblich zum Erfolg von OpenStreetMap beigetragen.
Aber es muss für nahzu jede Anwendung in ein anderes Datenmodell übersetzt werden,
da sonst die Verarbeitungszeiten zu lang werden.
Das gilt inbesondere auch fürs Rendern einer Landkarte und umso mehr für Routing und POI-Suche.

Keine dieser Konvertierungen ist verlustfrei,
jedes Folge-Datenmodell betont einige Aspekte, ignoriert andere Aspekte und interpretiert den Rest bestmöglich.
Damit führt auch eine möglichst faktentreue Modellierung des Mappers in der Karte, beim Routing, der POI-Suche oder anderen Anwendungsfällen häufig zu unerwarteten Ergebnissen.

In Reaktion darauf verwenden Mapper dann nicht selten faktenwidrige Modellierungen,
die aber im bevorzugten Werkzeug schönere Ergebnisse zeigen.
Dass die Ergebnisse in anderen Werkzeugen schlechter sind,
bemerkt der Mapper dann meist nicht.
Diese Praxis ist unter der Redewendung _für den Renderer Taggen_ berüchtigt.

Das Problem ist,
dass faktenwidriges Modellieren dann durch ein schönes Kartenbild belohnt
und faktentreues Modellieren durch ein schlechtes Kartenbild bestraft wird.
Vor Dritten hat der Mapper es schwer zu begründen,
warum er faktentreu modelliert.

Daher arbeitet die Overpass API auf dem originalen Datenmodell:
Es ist genau die Aufgabe der Overpass API die Daten so zu zeigen, wie sie in OpenStreetMap modelliert sind.

Damit verschieben sich die Gewichte:
faktisch fehlerhafte Modellierungen können dann auch als solche gezeigt werden.
Und für faktrentreue Modellierungen kann zumindest der Gesamtzusammenhang gezeigt werden.

## Tagging-Neutralität

Es liegt im Wesen des Menschen, dass sich dann bald das gegenteilige Phänomen zeigt:
Es treten Propheten ihrer jeweils vermeitlichen reinen Lehre auf.

Ein Beispiel sind Multipolygone:
Die zu lösende Problemstellungen sind,
einerseits Flächen mit Löchern zu modellieren,
andererseits logisch und tatsächlich aneinanderstoßende Flächen zu modellieren
Z.B. Staaten füllen die gesamte Landmasse, d.h. Landgrenzen gehören immer zu mehreren Staaten.
Nur mit geschlossenen Wegen ist das aber nicht mehr möglich.

Aus dem Anwendungsfall _Löcher_ ist die Konvention geblieben,
die relevanten Tags auf dem umschließenden Way zu belassen.
Das lag damals maßgeblich daran,
dass der Renderer Schwierigkeiten mit Relationen gehabt hat.
Gleichzeitig haben einige Verwender Schwierigkeiten mit einigen Besonderheiten,
was unter der Überschrift _Touching Inner Rings_ ein Thema gewesen ist.

In der Summe sind Multipolygon-Relationen ein ständiges Thema gewesen;
ihre Bearbeitung fordert auch heute noch gute Kenntnisse.

Das haben einige Mapper dahingehend missverstanden,
dass Relationen das höherwertige Objekt seien
und haben einfache geschlossene Wege in Multipolygone umgewandelt.
Das bringt aber gar keinen Vorteil,
sondern erschwert einfach nur die Bearbeitung und bläht die Datenbasis auf.

Es gibt allerdings auch zahlreiche nach wie vor kontroverse Meinungen:

- Straßenbelgeitende Fußwege können entweder als separate Wege modelliert
  oder über ein komplexes Regelwerk durch Tags abgebildet werden
  oder man beschränkt implizite Fußwege auf Fälle mit offensichtlicher Deutung.
- In Straßen können entweder alle Teile der Straße einen Namen bekommen.
  Oder man beschränkt den Namen auf maximal eine Fahrbahn des schnellsten Verkehrsmittels je Fahrtrichtung.
- In Gebäuden mit Geschäften kann das Geschäft das gleiche Objekt wie das Gebäude sein
  oder nur ein _Node_ innerhalb des Gebäudes.
  Die Adresse kann dann an jedem der beiden Objekte oder auch an beiden gemappt sein.

Um ein unversell akzeptiertes Tool zu schaffen,
halte ich mich aus solchen Dissenzen heraus.

Die Overpass API ist daher strikt neutral bzgl. Tagging,
d.h. kein Tag bekommt eine besondere Behandlung.

## Unverletzlichkeit

Ein anderes Problem in diesem Zusammenhang ist das Bestreben,
Daten automatisch zu ändern.
So naheliegend die Idee ist, sie führt zu [zahlreichen Problemen](https://www.geofabrik.de/media/2016-07-04-automatische_edits_und_importe_in_osm.pdf).

Daher lässt die Overpass API nicht zu,
OpenStreetMap-Objekte zur Laufzeit umzuschrieben.
Für den zweifelsohne und auch durchaus berechtigten bestehenden Bedarf,
umgeschriebene Objekte zu bekommen,
ist eigens die Klasse der _Deriveds_ eingeführt worden.
Diese sind ausreichend verschieden von OpenStreetMap-Objekten,
dass sie nicht direkt zurückgeschrieben werden können.

Bei Edits in verschiedenen Automatisierungsgraden kann die Overpass API trotzdem hilfreich sein.
Beispiele dafür sind im Abschnitt [JOSM](../targets/josm.md) zu finden.

## Allzweck-Abfragesprache

Geodaten bringen mit dem Konzept _Räumliche Nähe_ ihr eigenes Ordnungskriterium mit.
Damit fallen sie in keine der Kategorien,
die durch Standard-Abfragesprachen bereits abgedeckt sind.
Daher gibt es überhaupt eine eigene Abfragesprache.

Die Abfragesprache orientiert sich so nicht nur an räumlicher Nähe,
sondern kann auch voll den Eigenheiten des OpenStreetMap-Datenmodells Rechnung tragen.
Dazu kommt das Erfordernis,
dass sich die Abfragen auf einem öffentlichen geteilten Server vernüftig verhalten sollen,
d.h. weder große Angriffsflächen für Sicherheitslücken noch Performance-Probleme bieten sollen.

Im übrigen hat sich herausgestellt,
dass die OpenStreetMap-Community Bedarf auch an komplexen Suchen hat.
Diese sollen bedient werden,
indem die Sprache möglichst logisch rigide und orthgonal ist,
so dass nahezu alles mit allem kombinieren lässt.

## Infrastruktur

Die Overpass API ist als Infrastruktur konzipiert.
Sie ist also keine Endanwender-Software und auch kein Prototyp.

Entscheidungen über Schnittstellen,
inbesondere der Abfragesprache,
und über benutzte Abhängigkeiten werden voraussichtlich Jahrzehnte nachwirken.
Daher gibt es Neuerungen auch eher behutsam und erst,
wenn eine für langfristige Untersützung geeignete Form gefunden ist.

Eine über das Internet erreichbare Infrastuktur zu sein bedeutet auch,
vernüftiges Lastverhalten auch bei unvernüftigen Anfragemustern zu behalten.
Mehr dazu im [nächsten Abschnitt](commons.md#magnitudes).

## Offen

Die Overpass API lässt sich an den [Vier Freiheiten](https://www.gnu.org/philosophy/free-sw.de.html) von Open Source messen.

### Ausführen, Verteilen

Dazu reicht es nicht aus,
die öffentlichen Instanzen anzubieten,
da diese unvermeidlich eine endliche Kapazität haben.

Erst mit der Veröffentlichung des [Quellcodes](https://github.com/drolbr/Overpass-API) in einer Form,
der die [Installation eigener Instanzen](https://dev.overpass-api.de/no_frills.html) einfach macht,
sind die Freiheiten gewahrt.
Das schließt auch ein,
den Ressourcenbedarf der Software so zu bemessen,
dass geeignete Hardware leicht zu bekommen ist.

### Anpassen, Weiterentwickeln

Der [Quellcode](https://github.com/drolbr/Overpass-API) ist hier wesentliche Voraussetzung.
Die [Lizenz](https://github.com/drolbr/Overpass-API/blob/master/COPYING) sichert dies auch rechtlich ab.
