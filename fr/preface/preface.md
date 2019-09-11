OpenStreetMap et l'API Overpass
===============================

Comment fonctionne OpenStreetMap?
Comment se positionne l'API Overpass?

<a name="osm"/>
## Qu'est-ce qu'OpenStreetMap?

OpenStreetMap est premièrement une base des données géographiques couvrant le monde entier.
Les routes, rues, chemins de fer et les rivières sont probablement présents complètement;
les boutiques, restaurants ainsi que leurs noms et heures d'ouverture sont aussi très souvent renseignés.

En général, tous ce qu'on peut observer sur place peut être ajouté à OpenStreetMap.
Pour exemple pour le nom, une rue a une plaque, un restaurant a un panneau sur sa porte.
Les noms d'un fleuve ou d'une ligne de chemin de fer sont souvent disponible avec des panneaux explicatifs.

Quelques exceptions existent mais elles sont rares.
Les seules exceptions acceptées par tout le monde sont les contours des pays, régions et villes.

Les données personnelles ne sont jamais enregistrées.
Par exemple, on ne copie pas des noms sur des plaques de sonnette dans OpenStreetMap.

Ceci permet, en commun avec la [licence de données libre](https://wiki.osmfoundation.org/wiki/Licence),
de télécharger et traiter les données OpenStreetMap dans leur intégralité.
En principe, cela peut être utilisé pour répondre à des questions telles que

1. Où se trouve la ville X, la rivière Y, le restaurant Z ?
1. Qu'est-ce qui est près de X ou dans X ?
1. comment se rendre du point X au point Y à pied, en vélo ou en voiture ?

Il peut également être utilisé pour dessiner une carte du monde d'une multitude des différentes manières.
Afin de pouvoir juger de l'adéquation de base des données, vous pouvez voir
un [exemple de carte](https://openstreetmap.org) et un outil d'exemple pour _geocoder_.
Il s'appelle [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim) et répond à la question (1) ci-dessus,
et peut également spécifier des coordonnées pour retourner une adresse, cette opération étant appelée _géocodage inverse_.
Des outils de _routage_ sont également disponibles sur le site web principal [openstreetmap.org](https://openstreetmap.org/).
Ces réponses indiquent comment se rendre d'un point X à un point Y.

Cependant, il y a beaucoup de données,
et chaque minute des changements sont effectués sur les données par des contributeurs.
Le téléchargement et le traitement des données en bloc sont donc inutilisables pour répondre à de nombreuses questions.
En principe pour permettre à chacun de traiter les données indépendamment d'OpenStreetMap,
il y a [l'ensemble de données de la base OpenstreetMap](https://planet.openstreetmap.org/) avec également chaque minute un fichier avec les mises à jour.

<a name="overpass"/>
## Qu'est-ce que l'API Overpass?

L'API Overpass stocke ces données et les met à jour
et met les données à disposition pour effectuer des recherches.
D'une part, il existe des [instances publiques](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances) auxquelles la requête peut être envoyée.
D'autre part, l'API d'Overpass est aussi un [logiciel libre](https://github.com/drolbr/Overpass-API),
pour que chacun puisse gérer sa propre instance.

Le frontend _Overpass Turbo_ est un bon endroit pour apprendre à se familiariser avec pour la première fois.
Les données y sont également affichées sur une carte.
Comme [par exemple](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=2&Q=nwr%5Bname%3D%22Sylt%22%5D%3B%0Aout%20center%3B), nous cherchons tout ce qui porte le nom de Sylt:
Il faut mettre le texte de la requête

    nwr[name="Sylt"];
    out center;

dans la zone de texte à gauche et la requête est envoyée à l'API Overpass en cliquant sur _Exécuter_.
Le langage de requête est expressif, mais pas facile à prendre en main,
et c'est l'objet de l'ensemble de ce manuel d'expliquer le langage de requête.

En fait, l'API Overpass est conçue
pour répondre aux demandes d'autres logiciels via la Toile.
C'est aussi la raison d'être de [l'API](https://fr.wikipedia.org/wiki/Interface_de_programmation).
Pour de nombreux programmes d'exemple populaires, la connexion directe est expliquée dans le chapitre [Utilisation](.../targets/index.md).
