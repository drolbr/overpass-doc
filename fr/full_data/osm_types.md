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

Comme pour _chemins_, le cas le plus simple est celui des _relations_,
que le programme cible peut évaluer directement la géométrie intégrée.
Encore une fois, la comparaison directe appropriée:
[Sans coordonnées](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out;

et [avec coordonnées](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom;

Contrairement à _chemins_, les données deviennent un ordre de grandeur de plus:
C'est parce que dans la variante sans coordonnées de voies nous ne voyons que l'identifiant,
alors que chaque voie se compose en fait de plusieurs nœuds et a donc un nombre correspondant de coordonnées.

Les relations avec les chemins comme majorité des membres sont également la règle.
Par conséquent, il y a le mécanisme décrit dans le paragraphe _Restriction d'affichage_ sur [Rectangle englobant](bbox.md#crop),
pour limiter la géométrie à livrer à un rectangle englobant: [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom({{bbox}});

Cependant, le modèle de données original d'OpenStreetMap ne fournit pas de coordonnées également pour les relations.
Pour les programmes qui nécessitent le modèle de données d'origine, il y a à nouveau deux niveaux.
Si possible, seules les coordonnées peuvent être obtenues en sortant les relations et en résolvant leurs références.
Cela nécessite deux routes, car les relations peuvent avoir des nœuds comme membres,
d'autre part les chemins et ceux-ci à leur tour nœuds comme membres.
En tout, nous devrions utiliser quatre commandes.
Mais parce qu'il s'agit d'un cas courant, il y a une commande de collection très courte `>`: [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out qt;
    >;
    out skel qt;

Par rapport à la requête précédente, la quantité de données a pratiquement doublé,
puisque la référence et la destination de référence doivent toujours être incluses.

La variante entièrement compatible nécessite encore plus de données.
Ceci forme l'idiome `(._; >;);` à partir des trois commandes `._`, `>` et `(...)`:
[(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    (._; >;);
    out;

Existe-t-il une solution pour limiter le nombre de coordonnées reçues à le rectangle englobant?
Parce qu'une relation est contenue dans un rectangle englobant,
si au moins un de ses membres est contenu dans le rectangle englobant,
nous pouvons y arriver,
en demandant les membres et en résolvant les relations.
Ici, la commande `<` aide:
c'est un raccourci pour trouver toutes les _chemins_ et les _relations_,
qui ont les _nœuds_ ou les _chemins_ donnés en tant que membres.
Nous cherchons donc tous les _nœuds_ et tous les _chemins_ dans le rectangle englobant.
Ensuite, nous les gardons par ordre `._` et cherchons toutes les relations,
qui les ont comme membres: [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    (._; <;);
    out;

Les objets qui sont membres des relations peuvent être reconnus par les différentes couleurs de l'affichage.
Mieux encore, vous pouvez trouver les relations dans l'affichage _Données_ en faisant défiler complètement vers le bas.

La plupart des membres des relations ne sont pas téléchargés du tout, mais seulement ceux qui sont dans le rectangle englobant.
Cette requête n'est pas très pratique, car nous ne chargeons pas tous les nœuds utilisés dans les chemins.
Une version complète se trouve dans la section [Tous ensemble](#full) ci-dessous.

<a name="rels_on_rels"/>
## Relations sur relations

Montrer le problème des relations sur les relations,
nous n'avons même pas besoin d'agrandir beaucoup le rectangle englobant.
Nous commençons par la requête d'en haut sans relations sur les relations: [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    (._; >;);
    out;

Nous remplaçons maintenant la résolution des relations vers le bas par

* une résolution rétrograde sur les relations de relations
* la résolution en avant complète des relations trouvées jusqu'aux coordonnées

Ce sont les commandes `rel(br)` et `>>`: [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    ( rel(br); >>;);
    out;

Selon le navigateur, cela ralentira votre navigateur ou produira un message d'avertissement.
Nous voulions un coin dans la banlieue de Greenwich et nous avons obtenu des données de presque tout Londres,
puisqu'il existe une relation de groupement _Quietways_.
La quantité déjà importante de données s'est à nouveau multipliée.

Même s'il ne devrait plus y avoir de relation de groupement à un moment donné,
comme c'est également le cas pour notre zone de test avec une longueur de bord d'environ cent mètres:
Voulez-vous sérieusement rendre votre application sensible à cela
que ça ne marche plus,
dès qu'un cartographe inexpérimenté crée une ou plusieurs relations de groupement dans la zone cible?

C'est pourquoi je déconseille fortement de travailler avec les relations sur les relations.
La structure des données crée le risque,
de connecter involontairement de très grandes quantités de données.

Si vous voulez absolument traiter les relations sur les relations,
est une solution plus facile à gérer,
pour ne charger que les relations,
mais plus faire la résolution en avant.
Par conséquent, nous ajoutons la résolution arrière `rel(br)` à la dernière requête du paragraphe _Relations_: [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    (._; <; rel(br); );
    out;

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
