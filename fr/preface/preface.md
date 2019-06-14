OpenStreetMap et l'API Overpass
===============================

Comment fonctionne OpenStreetMap?
Où là-dedans se trouve l'API Overpass?

## Qu'est-ce que est OpenStreetMap?

OpenStreetMap est premièrement une base des données géographiques de le monde entier.
Les routes, rues, chemins de fér et eaux sont probablement présents complètement,
et aussi les boutiques, restaurants leur noms et heures d'overture y compris sont très bienvenues.

En général, tous qu'on peut observer sur place peuvent être ajoutés à OpenStreetMap.
Pour example pour le nom, une rue a une plaque, un restaurant a un panneau sur la porte.
Les noms d'un fleuve ou d'une ligne de chemin de fér sont souvent disponible de des panneaus explicatifs.

Quelque exceptions existent mais ils sont rares.
Le seul exception qui est accepté par tout le monde est les contours des pays, régions et villes.

Les données personelles sont jamais enregristrées.
Par example, on ne copie pas des noms sur de plaques de sonnette vers OpenStreetMap.

Ça permet en conjunction avec 
...
<!--
Dies erlaubt, zusammen mit der [freien Datenlizenz](https://wiki.osmfoundation.org/wiki/Licence),
die OpenStreetMap-Daten in komplett herunterzuladen und weiterzuverarbeiten.
Damit lassen sich im Prinzip Fragen beantworten wie

1. Wo liegt Stadt X, Fluss Y, Restaurant Z?
1. Was liegt in der Nähe von X oder in X?
1. Wie komme ich zu Fuß, mit dem Fahrrad oder per PKW von Punkt X nach Punkt Y?

Ebenso lässt sich damit auf viele verschiedene Weisen eine Weltkarte zeichnen.
Um die grundsätzliche Eignung der Daten beurteilen zu können,
ist über eine [Beispielkarte](https://openstreetmap.org) hinaus auch ein Beispielwerkzeug zum _Geocoding_ implementiert.
Es heißt [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim), beantwortet Frage (1) von oben,
und es kann zusätzlich auch zu einer Koordinate eine Adresse angeben, sogenanntes _Reverse Geocoding_.
Ebenso sind über die Haupt-Website [openstreetmap.org](https://openstreetmap.org/) auch Werkzeuge für sogenanntes _Routing_ verfügbar.
Diese beantworten, wie man von Punkt X nach Punkt Y kommt.

Allerdings sind es sehr viele Daten,
und es werden in jeder Minute Änderungen durch Mapper in den Daten eingetragen.
Die Daten en-bloc herunterzuladen und zu verarbeiten ist daher für sehr viele Fragestellungen unpraktikabel.
Um zumindest im Prinzip jedem unabhängig von OpenStreetMap die Datenverarbeitung zu ermöglichen,
gibt es zusätzlich zum [Gesamtdatenbestand](https://planet.openstreetmap.org/) auch jede Minute eine Datei mit den Updates.
-->

## Qu'est-ce que est l'API Overpass?

...
<!--
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

Tatsächlich ist die Overpass API aber vor allem darauf ausgelegt,
auf Abfragen anderer Software über das Internet zu antworten.
Das ist auch der Grund für den Namensbestandteil [API](https://de.wikipedia.org/wiki/Programmierschnittstelle).
Für viele beliebte Beispielprogramme wird daher die direkte Anbindung im Kapitel [Verwendung](../targets/index.md) erläutert.
-->
