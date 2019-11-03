Polygone et autour
==================

En plus de le rectangle englobant, il existe d'autres cadres de délimitation qui sont plus adaptables à la zone cible.

Les coordonnées en latitude et en longitude sont bien compréhensibles en tant que concept,
mais très peu de gens connaissent les coordonnées des lieux qui les intéressent par cœur.

C'est pourquoi la recherche indirecte au moyen d'objets nommés est introduite en premier lieu.
D'une part, la recherche dans les surfaces est extrêmement fréquente,
mais d'un autre côté, il a plusieurs particularités.
Il est donc traité dans un [autre sous-chapitre](area.md).

Le premier sous-chapitre traite de la recherche à proximité des objets nommés.
La recherche au voisinage des coordonnées suit.
Enfin, les polygones sont introduits comme filtres de recherche spatiale.

<a name="around"/>
## Autour des objets

C'est une tâche exigeante,
pour déterminer de manière fiable un lieu concret à partir d'un texte.
C'est donc également vraiment pour un géocodeur, par exemple [Nominatim](../criteria/nominatim.md#nominatim),
et n'est pas approfondi ici.
Avec les résultats de Nominatim, la recherche de coordonnées décrite dans la section suivante peut déjà être utilisée.

Cependant, il y a suffisamment d'exemples où le nom [fournit](https://overpass-turbo.eu/?lat=51.0&lon=10.0&zoom=6&Q=CGI_STUB) déjà l'objet juste:

    nwr[name="Kölner Dom"];
    out geom;

Dans la ligne 1, nous recherchons tous les objets,
qui ont un tag `nom` avec la valeur `Kölner Dom`.
Ceci est stocké dans l'ensemble `_`,
et à la ligne 2 `out geom` affiche ce qu'il trouve dans l'ensemble `_`.

Pour rappel: [La loupe](../targets/turbo.md#basics) zoome sur les lieux.
En particulier avec les filtres indirects, il est souvent judicieux d'exécuter la recherche d'objet d'origine,
pour exclure qu'il existe d'autres objets du même nom [dans d'autres lieux](https://overpass-turbo.eu/?lat=51.0&lon=10.0&zoom=6&Q=CGI_STUB):

    nwr[name="Viktualienmarkt"];
    out geom;

Un [rectangle englobant](bbox.md#filter) ou la spécification d'une surface enfermemente [peut aider](https://overpass-turbo.eu/?lat=48.0&lon=11.5&zoom=10&Q=CGI_STUB):

    area[name="München"];
    nwr(area)[name="Viktualienmarkt"];
    out geom;

Les objets désirés sont listés ici après la ligne 2 dans l'ensemble `_`.

Nous pouvions maintenant [trouver](https://overpass-turbo.eu/?lat=50.94&lon=6.96&zoom=14&Q=CGI_STUB) tous les objets dans un rayon de 100 mètres autour de la cathédrale de Cologne:

    nwr[name="Kölner Dom"];
    nwr(around:100);
    out geom;

Cependant, Overpass Turbo prévient à juste titre de la grandeur de la quantité de données qui reviennent.
Il ne s'ouvre pas tout de suite non plus,
pourquoi les voies entre Paris et Bruxelles doivent être considérées comme proches de la cathédrale de Cologne.
Le problème est donc encore une fois les _relations_ spatialement gigantesques.
Comme ce [n'est guère mieux](https://overpass-turbo.eu/?lat=48.135&lon=11.575&zoom=14&Q=CGI_STUB) au Viktualienmarkt à cause des sentiers de randonnée et de vélo de longue distance ...

    area[name="München"];
    nwr(area)[name="Viktualienmarkt"];
    nwr(around:100);
    out geom;

... on peut supposer qu'il s'agit d'un problème courant.
Ceci fixe des limites étroites à l'utilisation du filtre _around_ sans filtres supplémentaires.

Sur la couche technique, nous avons de nouveau nos objets nommés avant la ligne 3 dans l'ensemble `_`.
L'instruction _around_ filtre maintenant uniquement les objets de tous les objets,
qui ont une distance d'au moins un objet dans l'ensemble `_` d'au plus la valeur spécifiée `100` en mètres.

Le mécanisme de chaînage a [son propre sous-chapitre](../criteria/chaining.md#lateral),
et des ensembles ont été introduits dans [la préface](../preface/design.md#sets).
L'exemple là [depuis le début](../preface/design.md#sequential) montre une application des filtres _around_
qui est pertinente,
parce qu'il [combine](../criteria/union.md#intersection) le filtre avec un filtre après un attribut.
Les outils contre les ensembles de données surdimensionnés ont été discutés dans le sous-chapitre [Géométries](osm_types.md#full).

Une autre solution possible pour au moins afficher le cas ci-dessus d'une manière significative,
serait de filtrer pour _chemins_ au lieu de tous les objets et de ne déterminer que les _relations_,
qui font référence aux _chemins_ trouvés;
pour [la cathédrale de Cologne](https://overpass-turbo.eu/?lat=50.94&lon=6.96&zoom=14&Q=CGI_STUB):

    nwr[name="Kölner Dom"];
    way(around:100);
    out geom;
    rel(bw);
    out;

La ligne 1 met les objets nommés dans l'ensemble `_`.
La ligne 2 trouve tous les _chemins_,
qui ont une distance maximale de 100 mètres d'au moins un des objets de l'ensemble `_`;
le résultat remplace le contenu de l'ensemble `_`.
La ligne 3 affiche le contenu de l'ensemble `_`, c'est-à-dire les _chemins_ de la ligne 2.
La ligne 4 trouve toutes les _relations_ qui font référence à au moins une des _chemins_ stockées dans l'ensemble `_`
et remplace le contenu de `_` par ce résultat.
La ligne 5 affiche le contenu de l'ensemble `_`, c'est-à-dire les _relations_ trouvées,
mais contrairement à la ligne 3, aucune coordonnée n'est fournie.
cela réduit les _relations_ à une taille gérable.

<a name="absolute_around"/>
## Autour des coordonnées

Vous pouvez également effectuer une recherche dans un rayon en utilisant des coordonnées au lieu d'objets existants.
Un exemple près de Greenwich [sur le méridien origine](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB):

    nwr(around:100,51.477,0.0);
    out geom;

Un filtre est utilisé dans la ligne 1:
tous les objets de l'ensemble `_` sont stockés,
qui ont une distance maximale de 100 mètres par rapport à la coordonnée donnée.
La ligne 2 affiche l'ensemble `_`.

Les mêmes précautions s'appliquent que pour toutes les autres recherches de données complètes avec _relations_:
très vite, vous avez beaucoup de données.
Les techniques de réduction de [rectangle englobant](osm_types.md#full) et [de la dernière section](#around) s'appliquent également ici.

Mais il n'y a aucune obligation de chercher _relations_.
Vous pouvez également rechercher uniquement _nodes_, [uniquement pour _chemins_](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB) ...

    way(around:100,51.477,0.0);
    out geom;

...ou chercher [des _nœuds_ et des _chemins_](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB):

    (
      node(around:100,51.477,0.0);
      way(around:100,51.477,0.0);
    );
    out geom;

Ici, nous utilisons une instruction _union_ (qui sera introduite [plus tard](../criteria/union.md#union)),
pour fusionner les résultats de la recherche de rayon pour _nœuds_ et de la recherche de rayon pour _chemins_.
La ligne 2 et la ligne 3 filtrent chacune un type d'objet à l'aide d'un filtre _around_,
et _union_ fusionne les résultats des deux instructions dans l'ensemble `_`.

Cela permet de réaliser des cercles d'un rayon de 1000 mètres et plus.

Les relations peuvent maintenant être [ajoutées](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB) sans géométrie comme ci-dessus:

    (
      node(around:1000,51.477,0.0);
      way(around:1000,51.477,0.0);
    );
    out geom;
    rel(<);
    out;

Dans la ligne 5, le résultat de l'instruction _union_ est disponible comme entrée dans l'ensemble `_`.
Le filtre `(<)` n'autorise que les objets,
qui font référence à au moins un objet dans l'entrée -
ce sont exactement les relations qui ont un rapport avec la zone de recherche.

Pour s'occuper des recherches,
qui ne rentrent pas bien dans les rectangles englobants,
nous introduirons la recherche périmétrique autour d'une ligne polygonale.
Pour cela, vous définissez un chemin avec deux coordonnées ou plus,
et tous les objets sont trouvés,
dont [la distance moins est inférieure](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=13&Q=CGI_STUB) à la valeur spécifiée en mètres:

    (
      node(around:100,51.477,0.0,51.46,-0.03);
      way(around:100,51.477,0.0,51.46,-0.03);
    );
    out geom;
    rel(<);
    out;

Par rapport à la requête précédente, seules les lignes 2 et 3 ont changé;
les coordonnées sont séparées par des virgules.

<a name="polygon"/>
## Par polygone saisi

Une autre méthode,
pour s'occuper des zones de recherche,
qui ne rentrent pas bien dans les rectangles englobants,
est de chercher par polygone.

Il est vrai que [surfaces](area.md) couvre déjà de nombreuses applications,
en permettant la recherche dans exactement une zone nommée.
Mais quand il s'agit d'étendre ces zones ou de réduire les formes libres arbitraires,
la limite de la zone doit être passée comme un polygone explicite.

Pour l'illustration d'abord une recherche seulement pour les nœuds [avec un triangle comme limite](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB),
pour bien voir la forme du polygone sur la carte:

    node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
    out geom;

Dans la ligne 1, nous recherchons _nœudes_,
et le filtre `(poly :....)` n'autorise que de tels objets,
qui sont à l'intérieur du polygone noté entre guillemets.
Le polygone est une liste de coordonnées latitude-longitude,
où seuls les blancs sont autorisés entre les valeurs numériques.
Après la dernière coordonnée, l'API Overpass ajoute le segment de fermeture.

La [recherche de les trois types d'objets](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB) fournit une fois de plus une très grande quantité de données:

    nwr(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
    out geom;

Comme [avant](#around) ceci peut être contenu par les deux étapes _nœudes_ plus _chemins_ et résolution arrière des _relations_;
la réduction des données ne résulte que du fait
qu'aux _relations_ [la géométrie est omise](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB):

    (
      node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
      way(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
    );
    out geom;
    rel(<);
    out;

Peut-on également réaliser des trous et plusieurs composants ?

Plusieurs composantes peuvent être réalisées par instruction _union_.
Car les instructions _union_ peuvent avoir un nombre ad libitum de sous-instructions,
nous pouvons simplement écrire les instructions _query_ pour les composants l'un après l'autre,
ici pour [la variante avec _nœudes_ et _chemins_](https://overpass-turbo.eu/?lat=51.487&lon=0.0&zoom=13&Q=CGI_STUB):

    (
      node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
      way(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
      node(poly:"51.491 -0.01 51.498 -0.03 51.505 -0.01");
      way(poly:"51.491 -0.01 51.498 -0.03 51.505 -0.01");
    );
    out geom;
    rel(<);
    out;

Le contour est spécifié deux fois ici;
cela ne peut être évité pour l'instant.

En conséquence, il pourrait être évident pour les trous,
pour utiliser l'instruction de bloc [différence](../criteria/chaining.md#difference).
Mais ensuite, vous coupez aussi des objets,
en partie dans le trou et en partie dans le polygone environnant,
parce que l'instruction _différence_ trouverait ces objets pertiellement dans le trou.

Au lieu de ça, ça marche,
doubler le point le plus proche du premier point du trou sur la ligne extérieure
et insérez la ligne polygonale avec les points de début et de fin doubles entre eux.

Si, par exemple, nous voulons du triangle `51.47 -0.01 51.477 0.01 51.484 -0.01`
couper le triangle `51.483 -0.0093 51.471 -0.0093 51.477 0.008`, alors

* nous dupliquons d'abord le point le plus proche `51.484 -0.01`,
  a reçu `51,47 -0,01 51,477 0,01 51,484 -0,01 51,484 -0,01 -0,01`
* répéter le premier point du trou `51.483 -0.0093` à la fin,
  reçu pour le trou `51.483 -0.0093 51.471 -0.0093 51.477 0.008 51.483 -0.0093`
* insérer le trou entre les deux copies du point dupliqué:
  `51.47 -0.01 51.477 0.01 51.484 -0.01 51.483 -0.0093 51.471 -0.0093 51.477 0.008 51.483 -0.0093 51.484 -0.01`

A titre d'illustration, la [requête terminée pour les nœuds](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB).
Il fonctionne également pour tous les autres types d'objets et peut être combiné avec _union_,
mais alors vous ne pouvez pas voir la zone réellement sélectionnée par le polygone:

    node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01
      51.483 -0.0093 51.471 -0.0093 51.477 0.008
      51.483 -0.0093 51.484 -0.01");
    out geom;

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
