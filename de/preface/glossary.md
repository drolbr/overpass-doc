Glossar
=======

Sowohl für OpenStreetMap als auch für die Overpass API werden einige benutzte Begriffe erläutert.

### Abfrage

Der formalisierte Text,
der vom Client (z.B. aus dem Textfenster von _Overpass Turbo_) an den Server gesendet wird.
Der Inhalt der Abfrage entscheidet alleine darüber,
was aus den OpenStreetMap abgerufen wird.

### Bounding-Box

Eine Bounding-Box wird durch zwei Längengradangaben und zwei Breitengradangaben beschrieben.
Sie besteht aus allen Koordinaten,
deren Breitengrad zwischen den beiden Breitengradangaben
und deren Längengrad zwischen den beiden Längengradangaben liegt.

### Derived

Ein spezieller Typ _Objekt_ in den Daten der Overpass API.
Im Gegensatz zu _Nodes_, _Ways_ und _Relations_ kommen Deriveds nicht aus den OpenStreetMap-Daten,
sondern werden zur Laufzeit erzeugt.
Sie ermöglichen damit, Tags umzuschreiben oder Geometrien zu vereinfachen.

### Evaluator

Dies meint einen der möglichen Bausteine einer Abfrage.
Ein _Evaluator_ wird im Rahmen eines Statements, Block-Statements oder des speziellen Filters _if_ aufgerufen.
Je nach seinem Typ wirkt er entweder auf alle durch eine _Set-Variable_ ausgewählte Objekte oder auf jedes Objekt einzeln.
Er liefert je nach seinem Typ eine Zahl, eine Zeichenkette oder eine Geometrie.

### Filter

Dies meint einen der möglichen Bausteine einer Abfrage.
_Filter_ sind stets Bestandteile eines _query_-Statements und filtern dort die anzuwählenden Objekte.
Sie wirken per Und-Verknüpfung zusammen;
es werden also immer genau die Objekte gefunden, die alle _Filter_ des jeweiligen _query_-Statements erfüllen.

### Key

Bestandteil eines _Tags_,
und zwar die Schlüssel-Zeichenkette, der ein _Value_ (d.h. Wert) zugeordnet wird.

### Node

Ein spezieller Typ _Objekt_ im Datenmodell von OpenStreetMap.
Repräsentiert eine einzelne Koordinate.
Mit Tags ist er ein abgrenzbares Objekt,
ohne Tags normalerweise nur Bestandteil eines _Ways_,
um jenen mit Koordinaten auszustatten.

### Relation

Ein spezieller Typ _Objekt_ im Datenmodell von OpenStreetMap.
Modelliert Dinge,
die nicht schon allein mit Nodes und Ways modelliert werden können.

### Set

siehe Variable

### Statement

Dies meint einen der möglichen Bausteine einer Abfrage.
_Statements_ sind solche Teile, die eigenständig ausgeführt werden können.
Es wird weiter unterschieden in _Block-Statements_ (s.o.) und einfache Statements.
Die beiden wichtigsten Vertreter sind _query_ zur Anwahl von OpenStreetMap-Objekten
und _print_ zur Ausgabe von angewählten OpenStreetMap-Objekten.

### Tag

Datenstruktur in OpenStreetMap und Overpass API, um Sachdaten zu speichern.
Jedes _Tag_ besteht aus einem _Key_ und einem _Value_
und ist Bestandteil eines Objekts, d.h. Node, Way, Relation oder Derived.

### Value

Bestandteil eines _Tags_,
und zwar die Wert-Zeichenkette, die dem _Key_ (d.h. Schlüssel) zugeordnet wird.

### Variable

Eine Variable ist bei der Overpass API immer eine _Set-Variable_.
_Set-Variablen_ werden benutzt,
um bei der Ausführung Objekt-Auswahlen von Statement zu Statement weitergeben zu können.

### Way

Ein spezieller Typ _Objekt_ im Datenmodell von OpenStreetMap.
Repräsentiert einen Linienzug.
Falls es sich um einen geschlossenen Linienzug handelt,
kann dies auch eine Fläche sein.
