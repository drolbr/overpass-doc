Formats de données
==================

Il y a plusieurs formats de données pour récupérer des objets d'OpenStreetMap.
Nous présenterons tous les formats qui ont une application immédiate.

<a name="scope"/>
## Démarcation

Les types de données ont déjà été présentés dans [la section appropriée de l'introduction](../preface/osm_data_model.md).
Vous devriez donc déjà être familier avec les _nœuds_, les _chemins_ et les _relations_.

Cette section explique les formats de sortie.
D'autre part, les différents degrés de détail possibles sont présentés.
L'outil qui a besoin de quel format de sortie est expliqué dans la section sur l'outil.

Le problème commun de compléter la géométrie des objets OpenStreetMap,
est dédié à [la section sur les géométries](../full_data/osm_types.md) dans le chapitre [Toutes les données dans une région](../full_data/index.md).

<a name="faithful"/>
## Niveaux de verbosité traditionnels

D'abord au niveau de détail:
Alors que les formats de sortie sont contrôlés par un paramètre global pour chaque requête,
les niveaux de détail de chaque instruction de sortie sont contrôlés par ses paramètres.
Il est ainsi possible de mélanger différents niveaux de détail dans une même requête;
cette capacité est nécessaire pour une quantité optimale de données [de certaines variantes géométriques](../full_data/osm_types.md#full).
C'est ce qui est noté pour [chaque application](index.md).

Nous donnons également un exemple autour de Greenwich, la banlieue de Londres.
L'exemple est principalement choisi de telle sorte qu'il fournit seulement une quantité maitrisable des _nœuds_, _chemins_ et _relations_,
pour bien voir les données de l'onglet _Données_ d'Overpass Turbo.

Pour les niveaux de détail originaux d'OpenStreetMap, il existe une hiérarchie pour les activer:

L'instruction _out ids_ [revient](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids;

* les identifiants des objets

L'instruction _out skel_ [fournit](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) en outre les informations nécessaires,
pour construire la géométrie:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out skel;

* aux _nœuds_, leurs coordonnées
* à _chemins_ et _relations_ la liste des membres

<!--
Das Kommando _out_ (ohne Zusätze) [liefert](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) die vollständen Geodaten, also zusätzlich:
-->

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out;

<!--
* die Tags aller Objekte

Das Kommando _out meta_ [liefert](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) zusätzlich:
-->

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out meta;

<!--
* die Version pro Objekt
* den Zeitstempel pro Objekt

Schlussendlich liefert das Kommando _out attribution_ die folgenden Daten mit:

* die Changeset-Id
* die User-Id
* den Usernamen zu dieser User-Id

Dieser letzte Detailgrad betrifft allerdings Daten, die nach herrschender Meinung unter den Datenschutz fallen.
Daher ist dafür ein [erhöhter Aufwand](../analysis/index.md) nötig.
Da diese Daten für keines der in diesem Kapitel diskutierten Anwendungen erforderlich sind,
verzichten wir hier auf ein Beispiel.
-->

<a name="extras"/>
## Variantes

...
<!--
Es ist möglich, drei Detailgrade an zusätzlicher Geometrie zuzuschalten.
Alle Kombinationen zwischen den gerade vorgestellten Detailgraden und den zusätzlichen Geometrie-Detailgraden sind möglich.

Das Flag _center_ schaltet pro Objekt eine einzelne Koordinate zu.
Diese hat keine besondere mathematische Bedeutung,
sondern liegt einfach in der Mitte der das Objekt einschließenden Bounding-Box: [Beispiel 1](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids center;

[Beispiel 2](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

Das Flag _bb_ (für _Bounding-Box_) schaltet pro Objekt die einschließende Bounding-Box zu: [Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids bb;

Das Flag _geom_ (für _Geometrie_) ergänzt die vollen Koordinaten.
Dafür ist als Mindest-Detailgrad die Stufe _skel_ notwendig,
es funktioniert also bis einschließlich _attribution_: [Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out skel geom;

Wir haben jetzt allerdings jetzt nicht nur einige hundert Meter in einem Park von Greenwich
sondern auch mehrere hundert Kilometer Fußweg im Osten Englands zurückerhalten.
Dies ist ein generelles Problem von Relations.
Als Abhilfe gibt es eine Bounding-Box auch für das Ausgabe-Kommando, [siehe dort](../full_data/bbox.md#crop).

Zuletzt gibt es noch das Ausgabeformat _tags_.
Dieses basiert auf _ids_ und zeigt zusätzlich Tags, aber keine Geometrien oder Strukturen an.
Es ist vor allem nützlich, wenn man die Koordinaten im Ergebnis [nicht braucht](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out tags;

Es ist aber auch mit den beiden Geometriestufen _center_ und _bb_ [kombinierbar](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out tags center;
-->

<a name="json"/>
## JSON et GeoJSON

...
<!--
Nun zu den Datenformaten:
Während die Detailgrade pro Ausgabe-Kommando gewählt werden können,
wird das Ausgabeformat nur einmal global pro Abfrage festgelegt.
Zudem ändert die Wahl des Ausgabeformats zwar die Form, aber nicht den Inhalt.

Innerhalb von JSON gilt es damit, einen Spagat zu überbrücken.
Einerseits gibt es ein durchaus verbreitetes Format für Geodaten, sogenanntes GeoJSON.
Andererseits sollen die OpenStreetMap-Daten ja ihre Struktur behalten,
und diese passt nicht zu den Vorgaben von GeoJSON.

Als Lösung gibt es die Möglichkeit,
GeoJSON-konforme Objekte aus den OpenStreetMap-Objekten zu erzeugen.
Die originalen OpenStreetMap-Objekte werden jedoch originalgetreu in JSON abgebildet und sind kein GeoJSON.

OpenStreetMap-Objekte [in JSON](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:json];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out geom;

Abgeleitete Objekte [in GeoJSON](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:json];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    convert item ::=::,::geom=geom(),_osm_type=type();
    out geom;

Die Erzeugung abgeleiteter Objekte ist ein großer Themenkomplex mit [eigenem Kapitel](../counting/index.md).
-->

<a name="csv"/>
## CSV

...
<!--
Oft ist es nützlich, Daten in Tabellenform organisieren zu können.
Für OpenStreetMap-Daten bedeutet dies vom Nutzer ausgewählte Spalten
und eine Zeile je gefundenes Objekt.

Die Auswahl der Spalten schränkt dabei für die meisten Objekte die über das Objekt verfügbare Information wieder ein.
Z.B. werden nicht als Spalte angeforderte Tags nicht ausgegeben.
Komplexere Geometrien als eine einfache Koordinate können ebenfalls nicht in diesem Format abgebildet werden.
Dies unterscheidet dieses Format von den potentiell verlustfreien Formaten XML und JSON.

Der Standardfall einer Spalte ist der Key eines Tags.
Es wird dann zu jedem Objekt der Wert dieses Tags am Objekt ausgegeben.
Hat das Objekt das Tag nicht, so wird ein leerer Wert ausgegeben.
Für die weiteren Eigenschaften des Objekts gibt es spezielle Werte;
diese mit `::` beginnen.
[Beispiel](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    [out:csv(::type,::id,name)];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

CSV selbst stand ursprünglich für _comma separated value_.
Allerdings haben die zahlreichen nutzenden Programme unterschiedliche Erwartungen an Trennzeichen entwickelt.
Daher lässt sich sowohl das Trennzeichen konfigurieren als auch die Überschrift [ein- und ausschalten](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:csv(::type,::id,name;false;"|")];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

Bei den [jeweiligen Anwendungen](index.md) ist vermerkt, welche Variante sich eignet.
-->
