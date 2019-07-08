Modèle de données d'OpenStreetMap
=================================

Pour permettre la compréhension de l'API Overpass, 
il faut d'abord introduire le modêle de données d'OpenStreetMap.

Dans cette section, nous présentons les structures de données de base dans OpenStreetMap.
OpenStreetMap contient principalement trois types de données:

* Géométries, coordonnées et références réellement, localisent les objets dans l'espace.
* Les données factuelles sous forme de courts extraits de texte donnent un sens aux objets.
* Les métadonnées permettent de retracer l'origine et l'origine des données.

Tous les critères de requête visent les propriétés de ces structures de données.

De plus, il existe différents formats de données pour représenter ces données.
Celles-ci sont expliquées dans la section [Formats de données](../targets/formats.md).

L'interaction des types d'objets par rapport à la géométrie utilisable
nécessite également une explication particulière.
La section [Géométries](../full_data/osm_types.md) fournit un guide pratique à cet effet.

<a name="tags"/>
## Attributs

Les données factuelles dans OpenStreetMap sont stockées dans de courts extraits de texte, appelés _Attributs_.
Les _attributs_ sont toujours composés d'une _clé_ et d'une _valeur_.
Chaque objet ne peut avoir qu'une seule _valeur_ pour chaque _clé_.
En dehors d'une longueur maximale de 255 caractères pour chaque clé et chaque valeur, il n'y a pas d'autre restriction.

Formellement, toutes les Attributs sont égales,
Les étiquettes peuvent être attribuées spontanément et librement;
cela aurait dû contribuer de manière significative au succès d'OpenStreetMap.

De facto, on n'utilise presque que des touches avec des lettres minuscules latines et parfois les caractères spéciaux `:` et `\_`.
Deux types d'_attributs_ de base sont établis:

Les _attributs de classification_ ont l'une des quelques _clés_,
pour chacune des quelques _clés_, il n'y a aussi que des _valeurs_ gérables.
Les _valeurs_ qui s'en écartent sont considérées comme des erreurs.
Ainsi, l'ensemble du réseau routier public pour les véhicules automobiles est identifié par la clé [highway](https://taginfo.openstreetmap.org/keys/highway) et l'une de moins de 20 valeurs communes.
Pour les bâtiments, seul [building](https://taginfo.openstreetmap.org/keys/building) avec la valeur _yes_ est généralement saisi.

Occasionnellement, des _valeurs_ séparées par des points-virgules apparaissent également dans ces _attributs_.
Il s'agit d'une approche généralement au moins tolérée pour saisir plusieurs _valeurs_ pour la même _clé_ sur le même objet.

Les _attributs descriptives_, par contre, n'ont que des clés fixes,
alors que la _valeur_ est un texte libre en majuscules et minuscules et bien peut contenir des caractères spéciaux.
Les cas d'utilisation les plus importants sont les noms.
Des descriptions, des identificateurs ou des spécifications de taille peuvent également être utilisés.

Les sources les plus importantes pour les clés et les valeurs établies sont les suivantes

* le [OSM-Wiki](https://wiki.openstreetmap.org/wiki/Map_Features).
  Il a des textes de description plus longs.
  Parfois, les textes reflètent le souhait du documentateur plutôt que l'utilisation réelle.
* [Taginfo](https://taginfo.openstreetmap.org/).
  Compter les étiquettes en fonction de l'occurrence réelle.
  Fournit des liens vers des ressources pertinentes à l'étiquette.

Le chapitre complet [Trouver des objets](../criteria/index.md) est consacré à la recherche par _attributs_.

<a name="nwr"/>
## Nœuds, Chemins et Relations

OpenStreetMap possède trois types d'objets, dont chacun peut porter un nombre illimité de _attributs_.
Les trois types d'objet sont fondamentalement constitués d'un identifiant;
c'est toujours un nombre naturel.
La combinaison du type d'objet et de l'identifiant est unique,
mais pas seulement l'identifiant sans type.

Les _nœuds_ ont toujours une coordonnée en plus de l'identifiant et des attributs.
Ils peuvent représenter un point d'intérêt ou un petit objet.
Parce que les nœuds sont le seul élément avec une coordonnée,
la plupart d'entre eux ne sont utilisés que comme coordonnées dans les _chemins_
et n'ont donc pas de attributs.

Les _chemins_ sont constituées d'identifiant et des attributs ainsi que d'une séquence de références à des _nœuds_.
De cette façon, les chemins obtient à la fois une géométrie en utilisant les coordonnées des _nœuds_.
Mais ils obtiennent aussi une topologie;
deux chemins sont connectées si les deux pointent vers le même nœud.

Les chemins peuvent se référer au même nœud plusieurs fois.
Le cas ordinaire est un chemin fermé,
où le premier et le dernier nœud correspondent.
Tous les autres cas sont techniquement possibles,
mais des contenus indésirables.

...
<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
<!--
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
## Surfaces

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
## Métadonnées

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
## Calques, Catégories, Identités

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
aber die Fast-Food-Kette an sich erhält ihre räumliche Information ausschließlich vermittels der Filialen.

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
