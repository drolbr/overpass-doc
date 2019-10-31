Rectangle englobant
===================

Obtenir des données d'OpenStreetMap dans un extrait de la façon la plus simple.

<a name="filter"/>
## Le filtre

La façon la plus simple d'obtenir toutes les données dans un rectangle englobant est,
de ça [formuler explicitement](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    nwr(51.477,-0.001,51.478,0.001);
    out;

Où `(51.477,-0.001,51.478,0.001)` représente le rectangle englobant.
L'ordre des bords dans l'expression est toujours le même:

* `51.477` est la latitude de la frontière sud
* `-0.001` est la longitude de la frontière ouest
* `51.478` est la latitude de la frontière sud
* `0.001` est la longitude de la frontière est

L'API Overpass utilise uniquement des fractions décimales,
la notation minute-seconde ou la notation de fraction minute-décimale n'est pas supportée.

La valeur de la frontière sud doit toujours être inférieure à celle de la frontière nord,
comme dans le système de coordonnées latitude-longitude, les degrés augmentent du pôle Sud au pôle Nord, de -90,0 à +90,0.

Les longitudes augmentent d'ouest en est aussi presque partout.
Mais il y a l'antiméridien -
là la valeur de longitude passe de +180,0 à -180,0.
Conclusion: Dans presque tous les cas, la valeur ouest est inférieure à la valeur est,
à moins que vous ne vouliez étirer un rectangle englobant à travers l'Antiméridien.

C'est généralement assez fastidieux,
pour trouver le bon rectangle englobant vous-même.
C'est pourquoi presque tous les programmes décrits sous [Usage](../targets/index.md) ont des fonctions de confort pour cela.
Pour [Overpass Turbo](../targets/turbo.md#convenience) et aussi [JOSM](../targets/index.md)
toutes les occurrences de la chaîne de caractères `{{bbox}}` sont remplacées par le rectangle englobant visible avant que la requête ne soit envoyée. Avec ceci vous pouvez écrire une requête comme ci-dessus plus générale que [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    nwr({{bbox}});
    out;

La requête prend alors effet dans le rectangle englobant visible correspondante.

Notez que certains éléments sont en pointillés sur l'affichage.
C'est un indice d'un plus gros problème que nous allons explorer [dans la prochaine section](osm_types.md):
Des objets formellement complets seront livrés,
mais ces objets ont des géométries incomplètes,
parce que nous l'avons spécifié dans la requête.

<a name="crop"/>
## Restriction d'affichage

Une deuxième situation dans laquelle il y a des rectangles englobants,
est `out geom` pour la limite de sortie.
Si vous voulez visualiser une _chemin_ ou une _relation_ sur la carte,
vous devez [indiquer explicitement](../targets/formats.md#extras) l'API Overpass
d'équiper l'objet de coordonnées contraires aux conventions de l'OSM.

Dans le cas des relations, cela peut conduire à de grandes quantités de données.
Ainsi, dans [cet exemple](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB), la géométrie est livrée sans demande dans toute l'Angleterre,
bien que seulement quelques centaines de mètres carrés aient été mis au point:

    relation(51.477,-0.001,51.478,0.001);
    out geom;

La quantité de données peut être limitée,
en ne demandant [explicitement](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) que les coordonnées de le rectangle englobant donné dans l'instruction de sortie:

    relation(51.477,-0.001,51.478,0.001);
    out geom(51.47,-0.01,51.49,0.01);

Le rectangle englobant est notée directement derrière `geom`.
Il peut être identique ou différente de celle des rectangles englobants des instructions précédentes.
Dans ce cas, nous avons décidé d'utiliser une réserve très large en utilisant différents rectangles englobants.

Pour les _nœuds_ se produisant explicitement,
les coordonnées sont fournies exactement à ce moment-là,
si elles sont à l'intérieur du rectangle englobant.

Avec _chemins_, ce ne sont pas seulement les coordonnées de tous les _nœuds_ du rectangle englobant qui sont fournies,
mais aussi la coordonnée suivante et précédente,
même s'il est déjà en dehors du rectangle englobant.
Pour voir ceci [dans l'exemple](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=18&Q=CGI_STUB), veuillez cliquer sur _Données_ dans le coin supérieur droit après exécution;
le déplacement de la carte indique également l'endroit où elle a été coupée:

    way[name="Blackheath Avenue"](51.477,-0.001,51.478,0.001);
    out geom(51.477,-0.002,51.479,0.002);

Seule une partie des _nœuds_ dans le _chemin_ a des coordonnées ici.

Les sections du chemin avec les coordonnées [peuvent être déconnectées](https://overpass-turbo.eu/?lat=51.4735&lon=-0.007&zoom=17&Q=CGI_STUB),
même dans un seul chemin:

    way[name="Hyde Vale"];
    out geom(51.472,-0.009,51.475,-0.005);

Une courbe modérée à partir du rectangle englobant et retour est suffisante pour cela, comme dans cet exemple.

Avec _relations_, un _membre_ du type _chemin_ est allongé,
si au moins l'un des _nœuds_ de cet chemin se trouve à l'intérieur du rectangle englobant.
Les autres _membres_ de type _chemin_ ne sont pas allongés.
Dans ces _chemins_, les _nœuds_ du rectangle englobant plus un _nœud_ extra sont fournis avec des coordonnées, comme pour les _chemins_ individuels.

Comme avec le rectangle englobant comme filtre, la plupart des programmes ont un mécanisme,
pour insérer automatiquement la boîte de délimitation.
Avec [Overpass Turbo](../targets/turbo.md#convenience) cela fait comme ci-dessus `{{bbox}}`, [(exemple)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    relation({{bbox}});
    out geom({{bbox}});

<a name="global"/>
## Rectangle globale de délimitation

...
