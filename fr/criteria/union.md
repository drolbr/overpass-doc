Opérations ET et OU
===================

Requêtes sur des objets via des attributs multiples.

<a name="intersection"/>
## Opération ET

Tout d'abord, nous voulons lier deux ou plusieurs conditions de cette façon
que seuls les objets qui remplissent toutes les conditions sont trouvés.
Nous avons déjà vu quelques exemples de liens ET:
[un attribut et un rectangle englobant](per_tag.md#local),
[un attribut et une surface, un attribut et deux surfaces et deux attributs](chaining.md#lateral)

Nous travaillons sur la mission assez typique
de trouver un distributeur de billets.
Il y a l'attribut `amenity` avec la valeur `atm` pour ce but.
En raison du grand nombre, l'[exemple](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB) a un petit rectangle englobant:

    nwr[amenity=atm]({{bbox}});
    out center;

Ainsi, un filtre après un attribut (ici `amenity=atm`) est combiné avec un filtre après un rectangle englobant,
en écrivant simplement les deux filtres l'un après l'autre.

L'ordre [n'a pas d'importance](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr({{bbox}})[amenity=atm];
    out center;

Mais il existe une autre possibilité d'enregistrer les distributeurs automatiques de billets:
Ils font souvent partie d'une succursale bancaire;
ils sont ensuite saisis en tant que [propriété de la succursale](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr[amenity=bank]({{bbox}})[atm=yes];
    out center;

Comme dans tous les autres exemples, les filtres peuvent être disposés [dans n'importe quel ordre](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB) dans l'instruction _query_:

    nwr[atm=yes][amenity=bank]({{bbox}});
    out center;

La façon de combiner les deux types de cartographie est expliquée dans [la section suivante](union.md#union).
Tout d'abord, il sera clarifié,
qu'un nombre quelconque d'attributs ou d'autres critères peuvent être combinés:
Dans l'[exemple suivant](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=9&Q=CGI_STUB), omettez un ou plusieurs filtres pour l'essayer;
le résultat changera toujours, parce que chacun des six filtres d'attributs et du rectangle englobant a une influence:

    way
      [name="Venloer Straße"]
      [ref="B 59"]
      (50.96,6.85,50.98,6.88)
      [maxspeed=50]
      [lanes=2]
      [highway=secondary]
      [oneway=yes];
    out geom;

Étonnamment, cela s'applique également à notre exemple de guichet automatique bancaire:
Il suffit souvent de chercher un attribut subordonné,
parce que sur tous les objets avec l'attribut subordonné il y a aussi l'attribut général:

* Sur plus de 95% de tous les objets avec un attribut `admin_level` il y a l'attribut `boundary=administrative` selon [Taginfo](https://taginfo.openstreetmap.org/tags/boundary=administrative#combinations) (nombre et barre dans les colonnes à droite).
* Plus de 99% de tous les objets avec un attribut `fence_type` ont l'attribut `barrier=fence` selon [Taginfo](https://taginfo.openstreetmap.org/tags/fence_type=wood#combinations).

Une [recherche](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=14&Q=CGI_STUB) de clôtures (`barrier=fence`) avec l'attribut `fence_type=wood` fournit alors pratiquement le même résultat ...

    nwr[barrier=fence][fence_type=wood]({{bbox}});
    out geom;

... comme une [recherche](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=14&Q=CGI_STUB) à seulement `fence_type=wood`:

    nwr[fence_type=wood]({{bbox}});
    out geom;

Au contraire, on a plus de résultats sur les distributeurs de billets,
[si on cherche](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB) juste `atm=yes`:

    nwr[atm=yes]({{bbox}});
    out center;

D'un point de vue sémantique, c'est très convaincant:
Les distributeurs automatiques de billets peuvent également être installés dans les stations-service, les centres commerciaux ou d'autres bâtiments.

<a name="union"/>
## Opération OU

Nous voulons maintenant lier deux ou plusieurs conditions de cette façon,
que tous les objets qui remplissent au moins une des conditions sont trouvés.
Nous en avons déjà vu quelques exemples ici aussi:
[Tous les objets dans des rectangles englobants](../targets/formats.md#faithful),
[compléter les objets avec les objets usagés](chaining.md#topdown),
[comme exemple d'instruction de bloc](../preface/design.md#block_statements)

Pour notre exemple d'en haut, nous devons résoudre le problème,
pour trouver [à la fois](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB) les guichets automatiques autonomes et ceux des banques:

    (
      nwr[amenity=atm]({{bbox}});
      nwr[atm=yes]({{bbox}});
    );
    out center;

L'opération OU reprend l'instruction de bloc _union_ aux lignes 1 à 4.
Elle exécute son bloc intérieur.
L'instruction dans la ligne 2 écrit comme résultat tous les objets dans l'ensemble `_`,
qui ont un attribut `amenity` avec la valeur `atm` et qui sont situés dans le rectangle englobant remplie par Overpass Turbo.
L'instruction _union_ conserve une copie de ce résultat.
La ligne 3 écrit comme résultat tous les objets dans l'ensemble `_`,
qui portent un attribut `atm` avec la valeur `yes` et qui sont situés dans le rectangle englobant à nouveau remplis par Overpass-Turbo.
L'instruction _union_ conserve une copie de ce résultat.
Union écrit alors tous les objets dans l'ensemble `_`,
qui apparaissent dans au moins un des résultats partiels - la liaison OU souhaitée.

C'est un cas courant
de devoir accepter une liste assez longue de valeurs admissibles pour un attribut.
Si vous voulez trouver par exemple toutes les routes adaptées aux voitures,
puis une liste de valeurs pour `highway` se forme comme
`motorway`, `motorway_link`,
`trunk`, `trunk_link`,
`primary`, `secondary`, `tertiary`,
`unclassified`, `residential`.
Avec l'instruction _union_ on [peut interroger](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=15&Q=CGI_STUB) ceci comme:

    (
      way[highway=motorway]({{bbox}});
      way[highway=motorway_link]({{bbox}});
      way[highway=trunk]({{bbox}});
      way[highway=trunk_link]({{bbox}});
      way[highway=primary]({{bbox}});
      way[highway=secondary]({{bbox}});
      way[highway=tertiary]({{bbox}});
      way[highway=unclassified]({{bbox}});
      way[highway=residential]({{bbox}});
    );
    out geom;

Vous pouvez également utiliser les [expressions régulières](per_tag.md#regex) présentées dans la section précédente
et en [a juste besoin](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=15&Q=CGI_STUB):

    way({{bbox}})
      [highway~"^(motorway|motorway_link|trunk|trunk_link|primary|secondary|tertiary|unclassified|residential)$"];
    out geom;

Les lignes 1 et 2 forment une instruction _query_ pour les chemins avec deux filtres;
Le filtre `({{bbox}})` pour les boîtes de délimitation est [déjà connu](../full_data/bbox.md#filter).
De l'autre filtre, le tilde `~` est le caractère le plus important;
il accepte des objets qui ont un _attribut_ avec le _clé_ à gauche du tilde, ici `highway`, et une valeur,
qui est admis par l'expression régulière à droite du tilde.

La syntaxe avec l'accent circonflexe `^` au début et le symbole dollar `$` à la fin,
que la valeur doit correspondre à l'ensemble de la valeur et pas seulement à une chaîne de caractères y compris.
La ligne verticale sépare différentes alternatives les unes des autres,
ici un total de 9 valeurs potentielles pour l'attribut.

La section des [expressions régulières](per_tag.md#regex) contient d'autres exemples.

Cependant, dans notre exemple des distributeurs, nous n'avons pas de clé commun.
Les expressions régulières ne nous aident donc pas ici.

Mais ce qui se répète, c'est la condition sur le rectangle englobant.
Si vous voulez éviter la répétition,
vous pouvez avancher la condition commune et garder le résultat dans un ensemble;
`tous` est un nom descriptif pour lui.
Souvent, ça raccourcit également la durée d'exécution de [la requête](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr({{bbox}})->.tous;
    (
      nwr.tous[amenity=atm];
      nwr.tous[atm=yes];
    );
    out center;

L'instruction de bloc _union_ des lignes 2 à 5 est maintenant précédée d'une instruction _query_ à la ligne 1.
Là, tous les objets du rectangle englobant sont stockés dans l'ensemble `tous`.
Cet ensemble est utilisé deux fois dans le bloc _union_:
la ligne 3 et à la ligne 4, `.tous` est un filtre qui limite le résultat au contenu de `tous`.
Dans la ligne 3, on trouve exactement les objets,
qui sont dans l'ensemble `tous` et ont un attribut `amenity` avec la valeur `atm`.
Dans la ligne 4, on trouve exactement les objets,
qui sont dans l'ensemble `tous` et ont un attribut `atm` avec la valeur `yes`.

Et si on prenait l'ensemble `_`?
Cela serait techniquement possible.
Mais alors nous devrions nous rappeler de rediriger la sortie à chaque ligne du bloc.
Oublier cela est une source populaire d'erreurs.

<a name="full"/>
## Logique d'assemblage

...
