OpenStreetMap und die Overpass API
==================================

Wie funktioniert OpenStreetMap?
Wo befindet sich darin die Overpass API?

## Was ist OpenStreetMap

OpenStreetMap ist zunächst einmal eine Datenbank weltweiter Geodaten.
Dabei handelt es sich um Geobasisdaten,
z.B. Straßen, Eisenbahnlinien, Gewässer sollen vollständig vorhanden sein,
und auch Geschäfte und Restaruants mit Namen und Öffnungszeiten sind hochwillkommen.

Generell wird in OpenStreetMap alles eingetragen,
dass vor Ort beobachtbar ist.
Eine Straße hat ein Straßenschild, ein Restuarant hat ein Schild über der Tür hängen.
Bei einem Fluss oder einer Eisenbahnstrecke lassen sich die Bzeiechnungen meist indirekt aus Hinweisschildern ablesen.

Sehr vereinzelte Ausnahmen vom Sichtbarkeitserfordernis gibt es.
Die einzige unstrittige Ausnahme sind Staats-, Landes- und Gemeindegrenzen.

Nicht eingetragen werden personenbezogene Daten:
Es ist in OpenStreetMap unzulässig,
z.B. Klingelschilder abzuschreiben und in OpenStreetMap einzutragen.

Dies erlaubt, zusammen mit der [freien Datenlizenz](https://wiki.osmfoundation.org/wiki/Licence),
die OpenStreetMap-Daten in komplett herunterzuladen und weiterzuverarbeiten.
Damit lassen sich im Prinzip Fragen beantworten wie

1. Wo liegt Stadt X, Fluss Y, Restaurant Z?
1. Was liegt in der Nähe von X oder in X?
1. Wie komme ich zu Fuß, mit dem Fahrrad oder per PKW von Punkt X nach Punkt Y?

Ebenso lässt sich damit auf viele verschiedene Weisen eine Weltkarte zeichnen.
Um die grundsätzliche Eignung der Daten beurteilen zu können,
sind über eine Beispielkarte hinaus auch ein Beispielwerkzeug zum _Geocoding_ implementiert.
Es heißt [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim), beantwortet Frage (1) von oben,
und es kann zusätzlich auch zu einer Koordinate eine Adresse angeben, sogenanntes _Reverse Geocoding_.
Ebenso sind über die Haupt-Website [openstreetmap.org](https://openstreetmap.org/) auch Werkzeuge für sogenanntes _Routing_ verfügbar.
Diese beantworten, wie man von Punkt X nach Punkt Y kommt.

Allerdings sind es sehr viele Daten,
und es werden in jeder Minute Änderungen durch Mapper in den Daten eingetragen.
Die Daten en-bloc herunterzuladen und zu verarbeiten ist daher für sehr viele Fragestellungen unpraktikabel.
Um zumindest im Prinzip jedem unabhängig von OpenStreetMap die Datenverarbeitung zu ermöglichen,
gibt es zusätzlich zum [Gesamtdatenbestand](https://planet.openstreetmap.org/) auch jede Minute eine Datei mit den Updates.

## Was ist die Overpass API

Die Overpass API hält diese Daten vor, spielt die Updates ein
und stellt die Daten zum Durchsuchen zur Verfügung.
Einerseits gibt es [öffentliche Instanzen](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances), an die die Abfrage geschickt werden kann.
Andererseits ist Overpass API auch [freie Software](https://github.com/drolbr/Overpass-API),
so dass jedermann eine eigene Instanz betreiben kann.

Zum ersten Kennenlernen bietet sich das Frontend [Overpass Turbo](https://overpass-turbo.eu) an.
Dort werden die Daten auch gleich auf einer Karte angezeigt.
Als [Beispiel](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=2&Q=nwr%5Bname%3D%22Sylt%22%5D%3B%0Aout%20center%3B) suchen wir nach allem, was den Namen Sylt hat:
Dazu wird der Abfragetext

    nwr[name="Sylt"];
    out center;

in den Textbereich links eingetragen und per Klick auf "Ausführen" die Abfrage an die Overpass API gesendet.
Die Abfragesprache ist mächtig, aber auch umfangreich,
und es ist Gegenstand dieses gesamten Handbuchs die Abfragesprache zu erläutern.

Tatsächlich ist die Overpass API aber vor allem auf Abfragen die andere Software über das Internet ausgelegt.
Das ist auch der Grund für den Namensbestandteil [API](https://de.wikipedia.org/wiki/Programmierschnittstelle).
Für viele beliebte Beispielprogramme wird daher die direkte Anbindung im Kapitel [Verwendung](../targets/index.md) erläutert.
