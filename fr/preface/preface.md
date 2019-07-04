OpenStreetMap et l'API Overpass
===============================

Comment fonctionne le mouvement OpenStreetMap?
Où là-dedans se trouve l'API Overpass?

<a name="osm"/>
## Qu'est-ce que est OpenStreetMap?

OpenStreetMap est premièrement une base des données géographiques de le monde entier.
Il s'agit de géodonnées de base,
p. ex. les routes, rues, les voies ferrées, les plans d'eau devraient être entièrement disponibles,
ainsi que les magasins et restaurants avec noms et heures d'ouverture sont les bienvenus.

En général, tout est saisi dans OpenStreetMap, qui est observable sur place.
Pour example pour le nom, une rue a une panneau de nom, un restaurant a un panneau au-dessus de la porte.
Dans le cas d'une rivière ou d'une voie ferrée, les désignations peuvent généralement être lues indirectement sur des panneaux d'information.

Il existe des exceptions à l'exigence de visibilité mais ils sont rares.
Les seules exceptions pleinement acceptées sont les frontières des États, des régions et des municipalités.

Les données personelles ne seront jamais enregristrées.
Par example, ce n'est pas permis dans OpenStreetMap,
pour copie des noms de les plaques de sonnette et les entrer dans OpenStreetMap.

Ceci permet, en commun avec la [licence de données libre](https://wiki.osmfoundation.org/wiki/Licence),
télécharger et traiter les données OpenStreetMap dans leur intégralité.
En principe, cela peut être utilisé pour répondre à des questions telles que

1. Où se trouve la ville X, la rivière Y, le restaurant Z ?
1. Qu'est-ce qui est près de X ou dans X ?
1. comment se rendre du point X au point Y à pied, en vélo ou en voiture ?

Il peut également être utilisé pour dessiner une carte du monde d'une multitude des différentes manières.
Afin de pouvoir juger de l'adéquation de base des données,
est un [exemple de carte](https://openstreetmap.org) et un outil d'exemple pour _geocoding_.
Il s'appelle [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim), répond à la question (1) ci-dessus,
et il peut également spécifier une adresse en plus d'une coordonnée, appelée _Reverse Geocoding_.
Des outils de _routage_ sont également disponibles sur le site Web principal [openstreetmap.org](https://openstreetmap.org/).
Ces réponses indiquent comment se rendre d'un point X à un point Y.

Cependant, il y a beaucoup de données,
et chaque minute des changements sont entrés dans les données par des mappers.
Le téléchargement et le traitement des données en bloc sont donc impraticables pour de nombreuses questions.
Au moins en principe pour permettre à chacun de traiter les données indépendamment d'OpenStreetMap,
il y a en plus de [l'ensemble de données total](https://planet.openstreetmap.org/) également chaque minute un fichier avec les mises à jour.

<a name="overpass"/>
## Qu'est-ce que est l'API Overpass?

L'API Overpass stocke ces données, les met à jour
et met les données à disposition pour la recherche.
D'une part, il existe des [instances publiques](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances) auxquelles la requête peut être envoyée.
D'autre part, l'API d'Overpass est aussi un [logiciel libre](https://github.com/drolbr/Overpass-API),
pour que chacun puisse gérer sa propre instance.

Le frontend [Overpass Turbo](https://overpass-turbo.eu) est un bon endroit pour apprendre à le connaître pour la première fois.
Les données y sont également affichées sur une carte.
Comme [exemple](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=2&Q=nwr%5Bname%3D%22Sylt%22%5D%3B%0Aout%20center%3B), nous cherchons tout ce qui porte le nom de Sylt:
Il faut mettre le texte de la requête

    nwr[name="Sylt"];
    out center;

dans la zone de texte à gauche et la requête est envoyée à l'API Overpass en cliquant sur _Exécuter_.
Le langage de requête est expressif, mais pas facile,
et c'est l'objet de tout ce manuel pour expliquer le langage de requête.

En fait, l'API Overpass est conçue
pour répondre aux demandes d'autres logiciels via la Toile.
C'est aussi la raison d'être du composant de nom [API](https://fr.wikipedia.org/wiki/Interface_de_programmation).
Pour de nombreux programmes d'exemple populaires, la connexion directe est expliquée dans le chapitre [Utilisation](../targets/index.md).

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
