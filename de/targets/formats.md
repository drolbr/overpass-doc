Datenformate
============

Es gibt verschiedene Datenformate, um OpenStreetMap-Daten zu transportieren.
Wir stellen alle vor, die einen unmittelbaren Anwendungszweck haben.

<a name="scope"/>
## Abgrenzung

Die Datentypen sind bereits im [passenden Abschnitt der Einleitung](../preface/osm_data_model.md) eingeführt worden.
Sie sollten hier also bereits mit Nodes, Ways und Relations vertraut sein.

Dieser Abschnitt erläutert zum einen Ausgabeformate.
Zum anderen werden die verschiedenen möglichen Detailgrade vorgestellt.
Welches Tool welches Ausgabeformat benötigt ist jeweils im Abschnitt zum Tool erläutert.

Dem häufigen Problem, die Geometrie von OpenStreetMap-Objekten zu Vervollständigen,
ist [der Abschnitt zu Geometrien](../full_data/osm_types.md) im Kapitel [Räumliche Datenauswahl](../full_data/index.md) gewidmet.

<a name="faithful"/>
## Traditionelle Detailgrade

Zunächst zu den Detailgraden:
Während die Ausgabeformate über eine pro Abfrage globale Einstellung gesteuert werden,
werden die Detailgrade bei jedem Ausgabe-Kommando über dessen Parameter gesteuert.
Dadurch ist es möglich, verschiedene Detailgrade in einer Anfrage zu mischen;
diese Fähigkeit wird für die jeweils optimale Datenmenge [einiger Geometrievarianten](../full_data/osm_types.md#full) benötigt.
Bei den [Anwendungen](index.md) ist dies jeweils vermerkt.

Wir geben zu den Detailgraden jeweils auch ein Beispiel rund um den Londoner Vorort Greenwich.
Das Beispiel ist dabei hauptsächlich so gewählt, dass es nur überschaubar wenige Nodes, Ways und Relations liefert,
damit man sich die Daten gut im Tab _Daten_ von Overpass Turbo anschauen kann.

Für die originalen OpenStreetMap-Detailgrade gibt es eine Hierarchie sie zuzuschalten:

Das Kommando _out ids_ [liefert](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids;

* die Ids der Objekte

Das Kommando _out skel_ [liefert](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) zusätzlich die nötigen Informationen,
um die Geometrie aufzubauen:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out skel;

* bei Nodes deren Koordinate
* bei Ways und Relations die Liste der Member

Das Kommando _out_ (ohne Zusätze) [liefert](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) die vollständen Geodaten, also zusätzlich:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out;

* die Tags aller Objekte

Das Kommando _out meta_ [liefert](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) zusätzlich:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out meta;

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

<a name="extras"/>
## Varianten

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

<a name="json"/>
## JSON und GeoJSON

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

<a name="csv"/>
## CSV

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
