The Data Model of OpenStreetMap
===============================

To understand how Overpass API works
the data model of OpenStreetMap is introduced here ahead of everything else.

In this section we introduce the basic data structures of OpenStreetMap.
OpenStreetMap foremost contains three kinds of data:

* Geometries, more precisely coordinates and references to coordinates, locate the objects on Earth's surface.
* Short bits of text give each object a semantical meaning.
* Meta data facilitates to attribute the sources to the data.

All selection criterions of the query language deal with properties of these data structures.

In addition, multiple dataformats can represent the data.
These data formats are presented in the section [Data Formats](../targets/formats.md).

Handling the different object type such that it results in manageable geometry deserves a tutorial.
This tutorial is the section [Geometries](../full_data/osm_types.md).

<a name="tags"/>
## Tags

The semantical data of OpenStreetMap is encoded in short bits of text, so called _tags_.
_Tags_ always consist of a _key_ and a _value_.
Each object can have for each _key_ at most one _value_.
Beside a length restriction to 255 characters for each key and value no further constraints apply.

The data model does not distinguish any particular tag or key.
Tags can be chosen spotaneously and to best expedience;
this policy is highly likely to have promoted the success of OpenStreetMap.

Latin lowercase letters and rarely the special characters `:` and `\_` virtually exclusively prevail amongst the keys.
The tags fall into the two informal categories:

_Classifying tags_ have one of few keys,
and for each key only few values exist.
Deviating values are percieved as errorneous.
For example, the public road grid for motorized vehicles is identified by the key [highway](https://taginfo.openstreetmap.org/keys/highway) and one of fewer than 20 customary values.

In such tags, a value occasionally accomodates multiple customary values concatenated by semicolon.
This is an in general at least tolerated practice to set multiple values for a single key on the same object.

_Describing tags_ have only fixed keys
while anything is accepted in the value
including lowercase and uppercase letters as well as numbers, special charcters, and interpunctation.
Names are the most prominent use case.
But descriptions, identifiers, or even sized as well are commonplace.

The most generally acclaimed sources for key's and value's semantics are:

* the [OSM wiki](https://wiki.openstreetmap.org/wiki/Map_Features).
  It offers longer textual descriptions.
  But it can happen that the texts rather reflect the respective author's vision than the actual use.
* [Taginfo](https://taginfo.openstreetmap.org/).
  Counts tags by their actual appearance.
  Collects links to most other resources of information about the respective tags.

The complete chapter [Find Objects](../criteria/index.md) is devoted to search of objects by tags.

<a name="nwr"/>
## Nodes, Ways, Relations

...
<!--
OpenStreetMap hat drei Objekttypen, von denen jeder eine beliebige Anzahl Tags tragen kann.
Alle drei Objekttypen bestehen grundsätzlich aus einer Id;
dies ist stets eine natürliche Zahl.
Die Kombination aus Objekttyp und Id ist eindeutig,
jedoch nicht die Id alleine.

_Nodes_ haben neben Id und Tags auch stets eine Koordinate.
Sie können einen Point-of-Interest oder ein Objekt mit geringer Ausdehnung repräsentieren.
Da Nodes das einzige Element mit Koordinate sind,
werden die meisten auch nur als Koordinate in Ways genutzt und haben daher keine Tags.

_Ways_ bestehen neben Id und Tags noch aus einer Folge von Verweisen auf Nodes.
Auf diese Weise bekommen Ways sowohl eine Geometrie, indem man die Koordinaten der Nodes nutzt.
Sie bekommen aber auch eine Topologie;
zwei Ways sind verbunden, wenn beide an je einer Stelle auf dasselbe Node verweisen.

Ways können auf dieselbe Node mehrfach verweisen.
Der Standardfall hierfür ist ein geschlossener Weg,
bei dem erste und letzte Node übereinstimmen.
Alle übrigen Fälle sind zwar technisch möglich,
aber fachlich unerwünscht.

_Relations_ bestehen neben Id und Tags noch aus einer Folge von Verweisen auf ihre _Members_.
Grundsätzlich ist jedes Member ein Paar aus einem Verweis auf ein Node, ein Way oder eine Relation und eine Rolle.
Die ursprüngliche Aufgabe von Relations ist die Speicherung von Abbiegeverboten gewesen,
mit dementsprechend nur wenigen Membern.
Mittlerweile werden sie aber auch für Staats- und Gemeindegrenzen, Multipolygone oder Routen verwendet.
Ihre Erscheinungsformen sind daher sehr vielfältig,
und vor allem Grenz- und Routenrelationen können auch Ausmaße von hunderten und tausenden Kilometern erreichen.

Eine Geometrie für Relations entsteht erst durch die Interpretation des Datennutzers.
Allgemein anerkannt sind Interpretationen, die Multipolygone und Routen korrekt deuten:
Wie schon bei Ways werden solche Relations als Flächen verstanden, deren Member geschlossene Ringe formen.
Interpretationen beginnen bei der Frage, inwiefern für diese Deutung das Tag _area_=_yes_ notwendig ist.
Bei anderen Relations, z.B. Routen und Abbiegeverboten, ist die Geometrie die Summe der Geometrien ihrer Member vom Typ Node und Way.

Relations auf Relations sind technisch möglich,
haben aber keine praktische Relevanz.
Hier steigt das Risiko weiter, dass man sich große Datenmengen bereits dann einhandelt,
wenn man nur die Referenzen einer einzelnen Relation auflöst.
Es gibt so viele je nach Kontext sinnvolle Ansätze, die Referenzen von Relations gezielt teilweise aufzulösen,
dass dem [ein eigener Absatz](../full_data/osm_types.md#rels_on_rels) gewidmet ist.
-->

<a name="areas"/>
## Areas

...
<!--
Flächen haben im OpenStreetMap keine eigenständige Datenstruktur.
Sie werden stattdessen durch geschlossene _ways_ oder _relations_ abgebildet.
Die Tags sind zur Unterscheidung zwischen Fläche und aus anderen Gründen geschlossenem Weg relevant,
im einfachsten Fall durch das Tag _area_=_yes_.

Geschlossene Ways werden verwendet,
wenn die Fläche zusammenhängend ist und keine Löcher hat.
Ein Way ist geschlossen, wenn sein erster und letzter Eintrag auf das gleiche Node verweisen.

Relations werden verwendet,
wenn ein einzelner Way nicht mehr ausreicht.
Neben Löchern oder getrennten Flächenteilen passiert dies noch,
wenn der Rand aus mehreren Ways gebildet werden soll.
Das ist eigentlich nur bei Grenzen großer Gebiete (Städte, Bundesländer, Staaten) üblich.

Wie bei Ways wird die Fläche durch den Umriss beschrieben.
Die in der Relation referenzierten Ways müssen dazu aneinanderpassen und geschlossene Ringe bilden.
Mehr Informationen zu den [Konventionen](https://github.com/osmlab/fixing-polygons-in-osm/blob/master/doc/background.md).
-->

<a name="metas"/>
## Meta Data

...
<!--
OpenStreetMap ist ein vollständiges Versionskontrollsystem.
Daher werden sowohl alte Objektzustände gespeichert
als auch die nötigen Daten, um Änderungen Benutzern zuzuweisen.

Im einzelnen gibt es pro Objekt und Zustand eine _Versionsnummer_ und einen _Zeitstempel_.
Alte Zustände mit alten Versionsnummern werden dabei gesichert.
Daher gibt es in der Overpass API [spezielle Methoden](../analysis/museum.md), um auf alte Datenstände zuzugreifen.
Ohne besondere Konfiguration wird immer auf den aktuellen Daten gearbeitet.

Änderungen werden zudem zu _Changesets_ zusammengefasst.
Diese sind dem hochladenden Benutzer zugeordnet.
Die Zusammenfassung nimmt die Editier-Software automatisch vor,
und in der Regel entsteht ein Changeset pro Hochladevorgang.

_Changesets_ haben wiederum Tags und es kann Diskussionen zu Changesets geben.
Diese Texte werden jedoch nicht in der Overpass API verarbeitet.

Auf diese Weise sind dann auch Objekte in ihrer Gesamtheit jeweils einem Benutzer zugeordnet.
Es handelt sich um den letzten Bearbeiter.
Objekte mit höherer Versionsnummer als 1 haben daher in der Regel Eigenschaften aus früheren Versionen behalten,
die nicht dem aktuellen Bearbeiter zuzurechnen sind.
-->

<a name="declined"/>
## Layers, Categories, Identities

...
<!--
Thematische Layer gibt es dagegen in OpenStreetMap nicht,
und dies auch aus gutem Grund.
Für die einen gehören Supermärkte zusammen mit Postämtern, Banken und Geldautomaten zu den Orten,
an denen man Bargeld bekommt.
Für die nächsten bilden Supermärkte dagegen mit Bäckereien und Fleischern eine Gruppe,
weil man dort Lebensmittel einkaufen kann.

Daher spielt die Klassifikation nur eine untergeordnete Rolle in OpenStreetMap.
Es werden stattdessen lieber objektive Eigenschaften gemappt.
Streitigkeiten über Klassifikation sind so weitgehend vermieden worden,
und die meisten Mapper können ihre Weltsicht ohne große Verrenkungen abbilden.

Eine ebenfalls häufig erwartete Struktur sind Kategorien,
egal ob sehr generell wie weltweit alle Filialen einer Fast-Food-Kette
oder speziell wie alle Briefkästen in Hessen.

OpenStreetMap ist eine räumliche Datenbank.
Listen aller Objekte mit einer speziellen Eingeschaft in einem beschränkten Gebiet lassen sich gezielt filtern.
Die Overpass API ist übrigens eines der dafür geeingeneten Tools,
und [Objekte Filtern](../criteria/index.md) das zuständige Kapitel.

Listen weltweit aller Objekte mit einer Eigenschaft haben dagegen allenfalls eine schwache räumliche Relevanz.
Zwar hat jede Filiale einen Standort,
aber die Fast-Food-Kette an sich erhält ihre räumliche Information ausschließlich vermittels dieser Filialen.

Zuletzt muss auch das Konzept der Identität eine Objektes hinter seinen Raumbezug zurücktreten.
Wie schon in Bezug auf den Layer haben verschiedene Mapper verschiedene Sichtweisen dazu,
was zu einer so komplexen Anlage wie einem großen Bahnhof dazugehört.
Nur Gleise und Bahnsteige? Das Empfangsgebäude, oder nur, wenn es für Reisende geöffnet ist oder der Bahngesellschaft gehört? Der Bahnhofsvorplatz, die nach dem Bahnhof benannte Umsteigehaltestelle?
Die Weichen im Vorfeld des Bahnhofs?

Wenn eine Bezugnahme auf die Darstellung eines Objekt der materiellen Welt genommen wird,
geht dies am Besten mit einer Koordinate.
Ortsfeste Anlagen ziehen per Definition nicht um,
und die Lagegenauigkeit in OpenStreetMap ist so gut,
dass eine Koordinate des Zielobjekts die beste Identifikation ist.
-->