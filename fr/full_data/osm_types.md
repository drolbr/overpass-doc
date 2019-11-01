Des géométries
==============

Pour expliquer les variantes pour les données complètes d'OpenStreetMap,
des détails des modèles des données d'OpenStreetMap sont introduits ici.

<a name="scope"/>
## Démarcation

Les types des objets ont déjà été présentés dans la [section correspondante de l'introduction](../preface/osm_data_model.md).
Vous devriez donc déjà être familier avec les _nœuds_, les _chemins_ et les _relations_.

Ceux-ci peuvent être représentés de différentes manières;
les formats de sortie tels que JSON ou XML sont expliqués dans la section [Formats de données](../targets/formats.md).
Il explique également les niveaux de détail possibles en termes de structure, de géométrie, de attributs, de versions et d'attributs.

Ici, il s'agit de savoir comment l'achèvement des _chemins_ et des _relations_ leur fournit une géométrie utilisable,
sans que la taille du résultat de la requête ne devienne incontrôlable.

<a name="nodes_ways"/>
## Chemins et nœuds

Avec les _nœuds_, une géométrie utilisable est facile à obtenir:
Tous les modes de sortie sauf les `out ids` et les `out tags` ont les coordonnées des nœuds avec eux,
parce que, par définition, ils font partie des nœuds dans le modèle de données de l'OSM.

Par contre, en équipant les _chemins_ de la géométrie, il y a déjà plusieurs possibilités:
Dans le cas le plus simple, votre programme peut traiter des coordonnées supplémentaires sur les chemins.
Vous pouvez visualiser la différence, par exemple dans Overpass Turbo,
en comparant les résultats des deux requêtes suivantes dans l'onglet _Données_ (en haut à droite):
[Sans coordonnées](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out;

et [avec coordonnées](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out geom;

Dans le modèle de données original d'OpenStreetMap, cependant, aucune coordonnée n'est fournie à _chemins_.
Les _chemins_ ont déjà des références à des identifiants de noeuds.
Par conséquent, il y a encore des programmes qui ne peuvent pas traiter les coordonnées sur _chemins_.
Pour ces derniers, il y a deux gradations pour fournir la géométrie de la manière traditionnelle.

Le minimum de données supplémentaires est nécessaire pour ne demander que les coordonnées des nœuds.
La commande `node(w)` demande après la sortie des chemins de trouver les nœuds référencés dans les chemins;
le mode `out skel` réduit la quantité de données aux coordonnées pures; l'addition `qt` économise l'effort de tri de la sortie: [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out qt;
    node(w);
    out skel qt;

Je recommande à nouveau de regarder la sortie dans l'onglet _Données_ dans le coin supérieur droit.
Vous ne pouvez voir les nœuds que lorsque vous faites défiler vers le bas.

Ce modèle est plus proche du modèle de données original,
mais il y a des programmes qui ne peuvent pas le gérer.
Il y a une convention pour trier les nœuds strictement avant les chemins et les éléments entre eux par identifiant.
Pour ça, nous devons stocker les nœuds en plus des chemins avant de sortir;
Ceci est fait par l'idiome `(._ ; node(w) ;);` constitué des trois commandes `._`, `node(w)` et `(...)`:
[(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    (._; node(w););
    out;

Les nœuds et les chemins de faire ensemble sont expliqués [dans la section terminale](#full).

<a name="rels"/>
## Relations

...
<!--
Wie schon bei Ways ist der einfachere Fall im Umgang mit Relationen,
dass das Zielprogramm integrierte Geometrie direkt auswerten kann.
Dazu nocheinmal den passenden Direktvergleich:
[Ohne Koordinaten](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out;

und [mit Koordinaten](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom;

Im Gegensatz zu Ways werden die Daten um eine Größenordnung mehr:
Es liegt daran, dass wir in der Variante ohne Koordinaten von Ways nur die Id sehen,
während tatsächlich jeder Way aus mehreren Nodes besteht und damit entsprechend viele Koordinaten hat.

Relations mit überwiegend Ways als Member sind auch der Regelfall.
Es gibt daher den im Absatz _Ausgabebegrenzung_ auf [Bounding-Boxen](bbox.md#crop) beschriebenen Mechanismus,
die zu liefernde Geometrie auf eine Bounding Box einzuschränken: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom({{bbox}});

Auch für Relationen sind jedoch im originalen Datenmodell von OpenStreetMap keine Koordinaten vorgehesen.
Für Programme, die das originale Datenmodell benötigen, gibt es zunächst wieder zwei Abstufungen.
Möglichst nur die Koordinaten bekommt man, indem man die Relationen ausgibt und dann ihre Referenzen auflöst.
Das benötigt zwei Pfade, da Relationen einerseits Nodes als Member haben können,
andererseits Ways und diese wiederum Nodes als Member.
Insgesamt müssten wir dazu vier Kommandos benutzen.
Weil es aber ein so häufiger Fall ist, gibt es dafür ein besonders kurzes Sammelkommando `>`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out qt;
    >;
    out skel qt;

Gegenüber der vorhergehenden Ausgabe hat sich die Datenmenge etwa verdoppelt,
da immer Verweis und Verweisziel enthalten sein müssen.

Die ganz kompatible Variante erfordert noch mehr Datenaufwand.
Diese bildet das Idiom `(._; >;);` aus den drei Kommandos `._`, `>` und `(...)`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    (._; >;);
    out;

Gibt es eine Lösung, um auch hier die Menge erhaltener Koordinaten auf die Bounding-Box zu beschränken?
Da eine Relation in einer Bounding-Box enthalten ist,
wenn mindestens eines ihrer Member in der Bounding-Box enthalten ist,
können wir dies erreichen,
indem wir nach den Membern fragen und zu den Relationen auflösen.
Hier hilft das Kommando `<`:
es ist eine Abkürzung, um alle Ways und Relationen zu finden,
die die vorgegebenen Nodes oder Ways als Member haben.
Wir suchen also nach allen Nodes und Ways in der Bounding-Box.
Dann behalten wir diese per Kommando `._` und suchen alle Relationen,
die diese als Member haben: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    (._; <;);
    out;

Diejenigen Objekte, die Member der Relations sind, erkennt man an der abweichenden Farbe in der Anzeige.
Noch besser findet man die Relationen in der Anzeige _Daten_, indem man ganz herunterscrollt.

Die meisten Member der Relationen laden wir also gar nicht, sondern nur die in der Bounding-Box befindlichen.
Diese Abfrage ist nicht ganz praxistauglich, da wir zu den Ways nicht alle benutzten Nodes laden.
Eine vollständige Fassung gibt es unten im Abschnitt _Alles zusammen_.
-->

<a name="rels_on_rels"/>
## Relations sur relations

...
<!--
Um das Problem mit Relationen auf Relationen vorzuführen,
müssen wir die Bounding-Box nicht einmal besonders vergrößern.
Wir starten mit der Abfrage von oben ohne Relationen auf Relationen: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    (._; >;);
    out;

Jetzt ersetzen wir die Auflösung ab den Relationen abwärts durch

* eine Rückwärtsauflösung auf Relationen von Relationen
* die vollständige Vorwärtsauflösung der gefundenen Relationen bis zu den Koordinaten

Dies sind die Kommandos `rel(br)` und `>>`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    ( rel(br); >>;);
    out;

Je nach System wird dies Ihren Browser verlangsamen oder eine Warnmeldung produzieren.
Wir haben eine Ecke im Vorort Greenwich gewollt und tatsächlich Daten aus fast ganz London bezogen,
da es eine Sammelrelation _Quietways_ gibt.
Da hat die sowieso schon große Datenmenge wiederum vervielfacht.

Selbst wenn es hier irgendwann keine Sammelrelation mehr geben sollte,
wie dies auch für unsere Testregion mit etwa hundert Metern Kantenlänge gilt:
Wollen Sie ernsthaft Ihre Anwendung dafür anfällig machen,
dass sie nicht mehr funktioniert,
sobald irgendein ein unbedarfter Mapper im Zielgebiet eine oder mehrere Sammelrelationen anlegt?

Daher rate ich recht dringend davon ab, mit Relationen auf Relationen zu arbeiten.
Die Datenstruktur schafft das Risiko,
ungewollt sehr große Datenmengen miteinander zu verbinden.

Wenn man unbedingt Relationen auf Relationen verarbeiten will,
dann ist eine eher beherrschbare Lösung,
nur die Relationen zu laden,
aber keine Vorwärtsauflösung mehr durchzuführen.
Dazu ergänzen wir die letzte Abfrage aus dem Absatz _Relationen_ um die Rückwärtsauflösung `rel(br)`: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    (._; <; rel(br); );
    out;
-->

<a name="full"/>
## Tous les objets ensemble

...
<!--
Wir stellen hier die am ehesten sinnvollen Varianten zusammen.

Wenn Ihr Zielprogramm mit Koordinaten am Objekt umgehen kann,
dann können Sie alle Nodes, Ways und Relations in der Bounding Box komplett wie folgt bekommen: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    out geom qt;
    <;
    out qt;

Dies sammelt

* alle Nodes in der Bounding-Box (Selektion Zeile 1, Ausgabe Zeile 3)
* alle Ways in der Bounding-Box, auch solche, die die Bounding Box nur ohne Node durchschneiden (Selektion Zeile 2, Ausgabe Zeile 3)
* alle Relationen, die mindestens eine Node oder Way in der Bounding-Box als Member haben, ohne eigenständige Geometrie (Selektion Zeile 4, Ausgabe Zeile 5)

Die gleichen Daten ganz ohne Relationen erhalten Sie, wenn Sie nur die Zeilen 1 bis 3 als Abfrage verwenden.

Relationen auf Relationen erhalten Sie, wenn Sie Zeile 4 durch die Sammlung von Relationen und Relationen auf Relationen ergänzen: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    out geom qt;
    ( <; rel(br); );
    out qt;

Alternativ können Sie die Daten auch im strikt traditionellen Format mit Sortierung nach Elementtypen und nur indirekter Geometrie ausgeben.
Dies erfordert insbesondere, die Vorwärtsauflösung der Ways, um alle Nodes für die Geometrie zu bekommen.
Dann müssen wir das Kommando `<` durch eine präzisere Variante ersetzen,
da sonst das Kommando `<` Wege an den hinzugefügen Nodes aufsammelt.
Die erste Variante wird dann zu: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    ( ._;
      (
        rel(bn)->.a;
        rel(bw)->.a;
      ); );
    ( ._;
      node(w); );
    out;

Hier sind Zeilen 3 bis 7 für die Relationen zuständig.
Ohne Zeilen 4 bis 8, aber mit Zeilen 9 bis 11 für die Vervollständigung der Ways und die Ausgabe
erhält man dann nur Nodes und Ways.

Umgekehrt können Relationen auf Relationen gesammelt werden,
indem Zeile 7 entsprechend durch die neue Zeile 8 ergänzt wird: [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    ( ._;
      (
        rel(bn)->.a;
        rel(bw)->.a;
      );
      rel(br); );
    ( ._;
      node(w); );
    out;

Weitere Varianten existieren,
auch wenn sie eher historische Bedeutung haben.
Zwei stellen wir im [nächsten Unterkapitel](map_apis.md) vor.
-->
