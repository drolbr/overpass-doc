Listes de point-vergule
=======================

Aides pour traiter des attributs qui ont dans leurs valeurs plusieurs entrées separées par point-vergule.

<a name="intro"/>
## Plusieurs valeurs

Dans certains cas, c'est nécessaire,
dans OpenStreetMap pour enregistrer plusieurs _valeurs_ pour une _clé_.
Les bâtiments à plusieurs niveaux en sont un exemple:
Même si chaque élément n'est généralement situé que sur un seul étage,
le but des escaliers et des ascenseurs est de relier plusieurs étages
et, par conséquent, occuper l'espace sur les deux étages.

Il en va de même pour les routes ou autres voies de circulation,
si l'opérateur a attribué plusieurs numéros à une section.
Cependant, plusieurs numéros de maison [se retrouvent](https://overpass-turbo.eu/?lat=51.5&lon=0.0&zoom=13&Q=CGI_STUB) également sur une propriété ou un bâtiment:

    nwr["addr:housenumber"~";"]({{bbox}});
    out center;

La norme de facto pour les _valeurs_ multiples pour la même _clé_ est de l'utiliser,
pour enchaîner les valeurs ensemble dans la _valeur_, séparées par des points-virgules.
C'est un problème pour plusieurs raisons:

Premièrement, le point-virgule est un caractère valide dans la _valeur_,
afin qu'une seule _valeur_ puisse être divisée par erreur,
si le logiciel se divise en points-virgules.
Cela ne doit pas nécessairement se produire dans OSM:
Dans les formats populaires comme le CSV, le point-virgule est souvent utilisé comme séparateur.

Ensuite, la séquence des éléments soulève la question de savoir si l'ordre des éléments joue un rôle.
Avec des exemples tels que les valeurs `-2;-1` et `-1;-2` pour l'_attribut_ avec la _clé_ `level`
la réponse est non.
D'autre part, les clés comme celles des marques maritimes ou des panneaux de randonnée suggèrent
que `red;white;blue` est différent de `blue;red;white`.

Mais la stockage de l'ordre prend d'espace:
Même pour 15 choses, l'idéal serait que vous n'ayez besoin que de 2 octets pour stocker la présence,
mais 5 octets pour stocker l'ordre actuelle.

Les autres questions sont:

* Est-ce que -1 et -1.0 sont les mêmes valeurs?
* Qu'en est-il des espaces prealablents ou suivants?
* Qu'est-ce que cela signifie quand deux points-virgules se suivent directement?

J'ai donc établi une convention pour l'API Overpass,
qui s'harmonise le mieux possible avec l'utilisation actuelle:

_Toutes les valeurs des balises sont initialement traitées comme un tout et les points-virgules ne sont pas spéciaux,
à moins que la valeur ne soit transmise à une fonction de traitement de point-virgule.
De telles fonctions peuvent ignorer les espaces avant ou arrière.
Si une liste ne contient que des numéros,
peuvent mettre en équation les mêmes nombres et les trier par valeur numérique._

Dans les sections suivantes, nous présentons les fonctions à l'aide de problèmes typiques:

* Comment trouver tous les objets dans lesquels une _valeur_ Y apparaît dans l'_attribut_ à _clé_ X?
* Comment trouver tous les objets dans lesquels au moins une de plusieurs _valeurs_ se produit dans l'_attribut_ à _clé_ X?
* Comment peut-on énumérer toutes les _valeurs_?

Les fonctions d'analyse des données génèrent parfois des listes séparées par des points-virgules.
Cependant, ceci et la façon de les utiliser seront expliqués là.

<a name="single"/>
## Trouver une seule valeur

Nous essayons de nous rendre à l'une des principales stations de métro de Londres (_Bank_ et _Monument_)
pour trouver tous les escaliers qui touchent le niveau `-2`.
En cherchant _seulement la valeur_, on [ne trouve rien](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way[highway=steps][level=-2]({{bbox}});
    out center;

A ce stade, la recherche par expression régulière serait possible.
Mais cela est au mieux extrêmement lourd et ne sera pas discuté en détail ici.
Il faut le souligner,
qu'une telle expression régulière trouve facilement involontairement les valeurs `-2.3` ou `-2.7` se produisant ici.

La fonction point-virgule `lrs_in` [sélectionne](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB) exactement les objets qui ont la valeur `-2` directement ou dans une liste point-virgule:

    way[highway=steps]({{bbox}})
      (if:lrs_in("-2",t["level"]));
    out center;

Les objets avec des _valeurs_ comme `-2;-1` ou `-3;-2` sont trouvés par la requête ainsi que la _valeur_ `-2` seule.

En détail:
Les lignes 1 et 2 ensemble sont une instruction de requête avec un total de 3 filtres;
nous sommes intéressés par le filtre `(if:lrs_in("-2",t["level"]))`.
Ici, `(if:...)` est d'abord le filtre générique,
qui pour chaque objet en question évalue l'évaluateur à son intérieur;
seuls les objets pour lesquels l'évaluateur évalue à autre chose que `0`, `false` ou la valeur vide sont sélectionnés.
Nous examinons les objets avec l'évaluateur `lrs_in("-2",t["level"])`;
qui à son tour a deux arguments :

* le premier argument, ici la constante `-2`, est la valeur à trouver
* le second argument, ici `t["level"]`, est la liste à rechercher

Tout compte fait, c'est écrit ici comme une instruction:
Recherchez tous les _chemins_ dans le rectangle englobant (`({{bbox}})`) avec la _valeur_ `steps` jusqu'à la clé `highway`,
qui contiennent la valeur `-2` dans la liste séparée par un point-virgule comme _valeur_ pour la _clé_ `level`.

Toutes les fonctions de traitement des points-virgules commencent par le préfixe `lrs_`;
qui signifie _List represented set_ (ensemble représenté par liste).

Le filtre `(if:...)`, cependant, est un filtre dit _faible_.
Il ne peut pas être le seul filtre, car cela nécessiterait l'inspection de tous les objets dans le monde entier.
La tentative suivante de recherche dans le monde entier aboutira donc à [un message d'erreur](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way(if:lrs_in("-2",t["level"]));
    out center;

Pour la plupart des applications, ce n'est pas un problème,
parce qu'un filtre puissant est déjà disponible via le rectangle englobant ou un autre critère spatial.
Dans la plupart des autres cas, le filtre `[level]` comme filtre après seulement la présence de clé est suffisant.
Pour `level` en particulier, la procédure n'est pas utile,
en raison de la nombre élevée, il y a encore beaucoup d'objets à contrôler.
La quantité de données est alors finalement un défi pour le navigateur:
<!-- NO_QL_LINK -->

    way[level](if:lrs_in("-2",t["level"]));
    out center;

Pour d'autres attributs, cependant, cela peut être une solution appropriée.

Le nouveau filtre `[level]` utilisé ici est discuté en détail dans la [section suivante](misc_criteria.md#per_key).

Inversement, si on veut cacher tous les escaliers qui se terminent au niveau -2
alors on [peut le faire](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB) directement chez l'évaluateur par `!` pour la négation logique:

    way[highway=steps]({{bbox}})
      (if:!lrs_in("-2",t["level"]));
    out center;

Cependant, nous devrions y réfléchir à ce moment-là,
si nous voulons sélectionner des escaliers qui n'ont pas d'attribut _level_ définie.
Seulement les escaliers [avec `level`](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB) réglé:

    way[highway=steps]({{bbox}})
      (if:!lrs_in("-2",t["level"]))
      [level];
    out center;

<a name="multiple"/>
## Trouver plusieures valeurs

Nous voulons maintenant trouver un restaurant à Londres avec une cuisine typiquement pour cet endroit.
Il n'est pas si évident de savoir si nous devons chercher `british`, `english` ou `regional`.

En principe, nous pourrions résoudre ce problème avec une instruction _union_ sur [toutes les valeurs possibles](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB):

    (
      nwr[cuisine]({{bbox}})
        (if:lrs_in("english",t["cuisine"]));
      nwr[cuisine]({{bbox}})
        (if:lrs_in("british",t["cuisine"]));
      nwr[cuisine]({{bbox}})
        (if:lrs_in("regional",t["cuisine"]));
    );
    out center;

Ça va vite devenir compliqué,
pour un plus grand nombre de valeurs ainsi que pour d'autres raisons pour un opération OU.

Nous utilisons donc la fonction de traitement des points-virgules `lrs_isect` (d'_intersection_),
qui [trouve](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB) les valeurs communes de deux listes de points-virgules:

    nwr[cuisine]({{bbox}})
       (if:lrs_isect(t["cuisine"],"english;british;regional"));
    out center;

Le filtre  `(if:lrs_isect(t["cuisine"],"english;british;regional")` dans la ligne 2 est le filtre intéressant de la requête:
Là, `(if:...)` évalue chaque élément,
si une valeur différente de `0`, `false` et la valeur vide est déterminée.
L'évaluateur `lrs_isect(t["cuisine"],"english;british;regional")` a, encore une fois, deux arguments,
qu'il considère comme des listes
(une liste sans point-virgule est une liste avec la valeur comme seule entrée).
Il retourne les entrées qui apparaissent dans les deux listes;
c'est-à-dire une valeur non vide exactement à ce moment-là,
si au moins une des valeurs `english`, `british` ou `regional` apparaît dans la valeur à le clé `cuisine`.

Un requête complet est créée en limitant les objets à sélectionner, ainsi que les filtres sur le rectangle englobante et le filtre sur la clé `cuisine`.
Dans la ligne 3, la sélection est sortie.

De plus, `lrs_isect` peut être mis à la négative pour obtenir une logique vraie exactement à ce moment-là,
si `lrs_isect` a livré une liste vide.

A des fins d'illustration, nous présentons sous forme de tableau [toutes les valeurs qui se produisent ici](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB):

    [out:csv(cuisine, isect, negated)];
    nwr[cuisine]({{bbox}});
    for (t["cuisine"])
    {
      make info cuisine=_.val,
        isect="{"+lrs_isect(_.val,"english;british;regional")+"}",
        negated="{"+!lrs_isect(_.val,"english;british;regional")+"}";
      out;
    }

Les détails de la syntaxe sont expliqués dans le chapitre [Analyser des données](../analysis/index.md).
La colonne `cuisine` contient la valeur respective de l'attribut _cuisine_.
La colonne `isect` contient ce que `lrs_isect(_.val,"english;british;regional")` en fait.
Pour les valeurs non vides, il faut faire défiler un peu,
mais au plus tard avec les entrées commençant par `british` il y en a.
La colonne `negated` contient ce que l'opérateur de négation `!` fait avec l'entrée correspondante pour `isect`.
L'entrée vide renvoie `1`, une entrée pleine renvoie `0`.

<a name="all"/>
## Toutes valeurs

...
