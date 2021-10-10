Modèle de données d'OpenStreetMap
=================================

Pour permettre la compréhension de l'API Overpass, 
il faut d'abord introduire le modêle de données d'OpenStreetMap.

Dans cette section, nous présentons les structures de données de base dans OpenStreetMap.
OpenStreetMap contient principalement trois types de données:

* Géométries, coordonnées et références aux coordonnées, localisent les objets dans l'espace.
* Les données factuelles sous forme de courts extraits de texte donnent un sens aux objets.
* Les métadonnées permettent de retracer l'origine des données.

Tous les critères de requête visent les propriétés de ces structures de données.

De plus, il existe différents formats d'encodage de ces données.
Ils sont expliqués dans la section [Formats de données](../targets/formats.md).

L'interaction des types d'objets par rapport à la géométrie utilisable
nécessite également une explication particulière.
La section [Géométries](../full_data/osm_types.md) fournit un guide pratique à cet effet.

<a name="tags"/>
## Attributs

Les données sémantiques d'OpenStreetMap sont stockées dans de courts morceau de texte, appelés _Attributs_.
Les _attributs_ sont toujours composés d'une _clé_ et d'une _valeur_.
Chaque objet ne peut avoir qu'une seule _valeur_ pour chaque _clé_.
En dehors d'une longueur maximale de 255 caractères pour chaque clé et chaque valeur, il n'y a pas d'autre restriction.

Formellement, tous les Attributs sont égaux,
Les étiquettes peuvent être attribuées spontanément et librement;
cela aurait contribué de manière significative au succès d'OpenStreetMap.

De facto, on n'utilise presque que des touches avec des lettres minuscules latines et parfois les caractères spéciaux `:` et `\_`.
Deux types d'_attributs_ de base sont établis:

Les _attributs de classification_ correspondent à des rares _clés_,
dont les _valeurs_ sont limitées et prédéfinis.
Les _valeurs_ qui s'en écartent sont considérées comme des erreurs.
Ainsi, l'ensemble du réseau routier public pour les véhicules automobiles est identifié par la clé [highway](https://taginfo.openstreetmap.org/keys/highway) et l'une 20 valeurs uniques possibles.
Pour les bâtiments, seul [building](https://taginfo.openstreetmap.org/keys/building) avec la valeur _yes_ est généralement saisi.

Occasionnellement, des _valeurs_ séparées par des points-virgules apparaissent également dans ces _attributs_.
Il s'agit d'une approche, généralement au moins tolérée, pour saisir plusieurs _valeurs_ pour la même _clé_ sur le même objet.

Les _attributs descriptives_, par contre, n'ont que des clés fixes,
alors que la _valeur_ est un texte libre en majuscules et minuscules et peut bien peut contenir des caractères spéciaux.
Les cas d'utilisation les plus importants sont les noms.
Des descriptions, des identificateurs ou des spécifications de taille peuvent également être utilisés.

Les sources les plus importantes pour connaître les clés et les valeurs établies sont les suivantes :

* le [OSM-Wiki](https://wiki.openstreetmap.org/wiki/Map_Features).
  Il a des des descriptions plus longues.
  Parfois, ces textes peuvent plus reflèter le souhait du contributeur plutôt que l'utilisation réelle.
* [Taginfo](https://taginfo.openstreetmap.org/).
  Il permet de compter les étiquettes en fonction de l'occurrence réelle et fournit des liens vers des ressources pertinentes à l'étiquette.

Le chapitre complet [Trouver des objets](../criteria/index.md) est consacré à la recherche par _attributs_.

<a name="nwr"/>
## Nœuds, Chemins et Relations

OpenStreetMap possède trois types d'objets, dont chacun peut porter un nombre illimité de _attributs_.
Les trois types d'objet sont fondamentalement constitués d'un identifiant;
c'est toujours un nombre naturel.
La combinaison du type d'objet et de l'identifiant est unique, ce qui n'est pas le cas si l'on prend uniquement l'identifiant. 

Les _nœuds_ ont toujours une paire de coordonnées en plus de l'identifiant et des attributs.
Ils peuvent représenter un point d'intérêt ou un petit objet.
Parce que les nœuds sont le seul élément avec une paire de coordonnées,
la plupart d'entre eux ne sont utilisés que comme point de coordonnées dans les _chemins_
et n'ont donc pas de attributs.

Les _chemins_ sont constituées d'identifiant et d'attributs ainsi que d'une séquence de références à des _nœuds_.
De cette façon, les chemins obtiennent à la fois une géométrie en utilisant les coordonnées des _nœuds_.
Mais ils obtiennent aussi une topologie;
deux chemins sont connectées si les deux pointent vers le même nœud.

Les chemins peuvent se référer au même nœud plusieurs fois.
Le cas ordinaire est un chemin fermé,
où le premier et le dernier nœud correspondent.
Tous les autres cas sont techniquement possibles,
mais certains sont indésirables.

Les _relations_ se composent d'identifiant et d'attributs ainsi que d'une séquence de références à leurs _membres_.
Fondamentalement, chaque membre est une paire de références à un nœud, un chemin ou une relation et un rôle.
Un rôle est un séquence de caractères.
Les relations ont été développées pour représenter des interdictions ou restriction de circulation (comme une interdiction de tournée à gacuhe),
avec, par conséquent, peu de membres.
Entre-temps, elles ont également été utilisées pour les frontières des états et des municipalités, les multipolygones ou les routes.
Elles peuvent donc représenter des objets très divers,
et surtout, les relations frontalières et routières peuvent aussi atteindre des centaines et des milliers de kilomètres.

Une géométrie des relations n'est créée que par l'interprétation de l'utilisateur des données.
Les interprétations généralement acceptées sont celles
qui interprètent correctement les multipolygones et les routes:
ainsi des chemins, peuvent être compris comme des polygones si les membres de leur relation forment des cercles fermés.
Les interprétations commencent par la question de savoir dans quelle mesure l'attribut _area_=_yes_ est nécessaire pour cette interprétation.
Pour d'autres relations, par exemple les routes et les interdictions tourner, la géométrie est la somme des géométries de leurs membres de type _nœud_ et _chemin_.

Les relations sur les relations sont techniquement possibles,
mais n'ont aucune pertinence pratique.
Ceci augmente le risque que de grandes quantités de données soient déjà échangées,
si vous ne résolvez que les références d'une seule relation.
Selon le contexte, il existe tellement d'approches utiles pour suivre partiellement et de manière ciblée les références des relations,
qu'un [paragraphe distinct](../full_data/osm_types.md#rels_on_rels) lui est consacré.

<a name="areas"/>
## Surfaces

Les surfaces n'ont pas de structure de données indépendante dans OpenStreetMap.
Au lieu de cela, ils sont représentés par des _chemins_ ou _relations_ fermées.
Les attributs sont pertinentes pour distinguer la surface et le chemin fermé pour autre raison,
dans le cas le plus simple par l'attribut _area_=_yes_.

Les chemins fermées sont utilisées,
si la surface est continue et sans trous.
Un chemin est fermé si ses première et dernière entrées pointent vers le même nœud.

Les relations sont utilisées,
quand une seule chemin ne suffit plus.
En plus des trous ou des parties de surface séparées, cela se produit également,
si la bordure doit être formée de plusieurs chemins.
Ceci n'est en fait courant que pour les frontières de grandes structures (villes, régions, pays).

Comme pour les chemins, la surface est décrite par le contour.
Les chemins référencées dans la relation doivent s'emboîter et former des boucles fermés.
Plus d'informations sur les [Conventions](https://github.com/osmlab/fixing-polygons-in-osm/blob/master/doc/background.md).

<a name="metas"/>
## Métadonnées

OpenStreetMap est un système complet de gestion de versions.
Par conséquent, les anciens états d'objet restont enregistrés
et les données nécessaires pour affecter les modifications aux utilisateurs.

Il y a un _numéro de version_ et un _horodatage_ pour chaque objet et état.
Les anciens états avec d'anciens numéros de version sont sauvegardés.
Par conséquent, il existe des [méthodes spéciales](.../analysis/index.md) dans l'API Overpass pour accéder aux anciens états de données.
Sans configuration spéciale, les données actuelles sont toujours utilisées.

Les modifications sont également combinées à _groupes de modifications_.
Celles-ci sont affectées à l'utilisateur de téléchargement.
Le logiciel d'édition fait automatiquement le résumé,
et il y a généralement un groupe de modifications par téléchargement.

Les _groupes de modifications_ ont des attributs
et il peut y avoir des discussions sur les groupes de modifications.
Toutefois, ces textes ne sont pas traités dans l'API Overpass.

Ainsi, les objets sont également affectés à un utilisateur dans leur intégralité.
C'est le dernier utilisateur.
Les objets dont le numéro de version est supérieur à 1 conservent donc généralement les propriétés des versions antérieures,
qui ne sont pas attribuables à l'utilisateur actuel.

<a name="declined"/>
## Calques, Catégories, Identités

Cependant, il n'y a pas de calques thématiques dans OpenStreetMap,
et pour une bonne raison.
Pour certains, les supermarchés, les bureaux de poste, les banques et les distributeurs automatiques de billets ne sont que quelques-uns des endroits,
où vous pouvez obtenir de billets.
Pour le prochain, les supermarchés forment un groupe avec les boulangeries et les boucheries,
parce qu'y on peut acheter des aliments.

Par conséquent, la classification ne joue qu'un rôle subordonné dans OpenStreetMap.
Au lieu de cela, les propriétés objectives sont cartographiées.
Les litiges sur la classification ont ainsi été largement évités,
et la plupart des cartographes peuvent montrer leur vision du monde sans grandes contorsions.

Une structure qui est aussi souvent attendue sont les catégories,
que ce soit très généralement ou mondialement toutes les branches d'une chaîne de restauration rapide
ou surtout comme toutes les boîtes aux lettres de Languedoc.
OpenStreetMap est une base de données spatiales.
Les listes de tous les objets ayant une propriété spécifique dans une zone restreinte peuvent être calculées.
D'ailleurs, l'API Overpass est l'un des outils appropriés à cette fin,
et [Trouver des objets](../criteria/index.md) le chapitre approprié.

Les listes de tous les objets ayant une propriété dans le monde entier, par contre, ont au mieux une faible pertinence spatiale.
Chaque succursale a un emplacement,
mais la chaîne de restauration rapide elle-même reçoit ses informations spatiales exclusivement par l'intermédiaire des cettes succursales.

Enfin, le concept de l'identité d'un objet doit aussi reculer derrière sa référence spatiale.
Comme c'est déjà le cas pour la couche, les différents utilisateurs ont des vues différentes sur celle-ci,
qui fait partie d'une installation aussi complexe qu'une grande gare ferroviaire.
Que des rails et des quais?
Le bâtiment d'accueil, ou seulement s'il est ouvert aux voyageurs ou s'il appartient à la compagnie ferroviaire?
Le parvis de la gare, l'arrêt de transfert du nom de la gare?
Les points autour de la gare?

Lorsqu'il est fait référence à la représentation d'un objet du monde matériel,
il est préférable d'utiliser une coordonnée.
Par définition, les installations fixes ne bougent pas,
et la précision de position dans OpenStreetMap est si bonne
que la position est déjà la meilleure identification.

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
