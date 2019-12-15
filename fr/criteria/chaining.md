Enchainer
=========

Comment on peut enchainer plusieures instructions de manière à pouvoir 
requêter par des critères relatifs à d'autres objets.

<a name="lateral"/>
## Filtres indirects

Nous avons déjà vu des exemples de filtres indirects dans [Requêter par surface](../full_data/area.md) et [Polygone et autour](../full_data/polygon.md).
Les objets peuvent également [être référencés en les enchaînant](../preface/design.md#sequential),
qui ne sont même pas inclus dans le résultat final.

Prenons l'exemple,
pour trouver tous les [cafés de Cologne](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    area[name="Köln"];
    nwr[amenity=cafe](area);
    out center;

Le filtre `(area)` de la ligne 2 est ici central.
Le filtre filtre par la surface ou les surfaces,
qu'il trouve dans l'ensemble `_`.
Il fonctionne en commun avec le filtre `[amenity=cafe]`,
c'est-à-dire que nous recherchons tous les objets dans la ligne 2,
qui sont des _nœuds_, des _chemins_ ou des _relations_ (_nwr_)
et qui ont l'attribut `amenity` avec la valeur `cafe`
et se trouvent dans les surfaces déposées en `_`.

Ainsi nous pouvons reformuler la requête ci-dessus et obtenir exactement le même résultat :
<!-- NO_QL_LINK -->

    area[name="Köln"];
    nwr[amenity=cafe](area._);
    out center;

et
<!-- NO_QL_LINK -->

    area[name="Köln"]->._;
    nwr[amenity=cafe](area);
    out center;

et
<!-- NO_QL_LINK -->

    area[name="Köln"]->._;
    nwr[amenity=cafe](area._);
    out center;

Dans tous les cas, la surface de la ligne 1 à la ligne 2 est médiée par l'ensemble `_`.
Les ensembles sont présentés [dans une section de l'introduction](../preface/design.md#sets).

Nous pouvons également utiliser un ensemble [avec n'importe quel nom](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    area[name="Köln"]->.nomextremementlong;
    nwr[amenity=cafe](area.nomextremementlong);
    out center;

Mais ça ne marche pas,
si le nom des ensembles des deux lignes ne correspond pas :
<!-- NO_QL_LINK -->

    area[name="Köln"]->.nomextremementlong;
    nwr[amenity=cafe](area.nomextrementlong);
    out center;

Les noms pour les ensembles alors deviennent utiles,
si vous voulez contrôler plusieurs filtres.
Par exemple, nous pouvons chercher des cafés à _Münster_,
mais l'API Overpass ne le sait pas,
de quelle _Münster_ nous parlons,
parce qu'il y a beaucoup d'endroits plus petits avec le nom en plus de la grande ville
et [il y a là aussi des cafés](https://overpass-turbo.eu/?lat=50.0&lon=10.0&zoom=4&Q=CGI_STUB):

    area[name="Münster"];
    nwr[amenity=cafe](area);
    out center;

Mais nous pouvons exiger
que le café doit [être situé à la fois](https://overpass-turbo.eu/?lat=52.0&lon=7.5&zoom=6&Q=CGI_STUB) à _Münster_ et en _Rhénanie-du-Nord-Westphalie_:

    area[name="Nordrhein-Westfalen"]->.a;
    area[name="Münster"]->.b;
    nwr[amenity=cafe](area.a)(area.b);
    out center;

Les cafés sont sélectionnés à la ligne 3:
Nous sélectionnons les objets de type _node_, _way_ ou _relation_,
qui portent l'attribut `amenity=cafe`
et qui sont situées à la fois dans l'une des surfaces stockées en `a` (1 seule zone, à savoir le Land de Rhénanie-du-Nord-Westphalie `Nordrhein-Westfalen`)
ainsi que dans l'une des zones stockées en `b` (toutes les villes, districts et villages du nom de _Münster_).
Ce ne sont que les cafés de _Münster_ en Westphalie.

L'interaction entre plusieurs filtres et la concaténation est approfondie dans [la section suivante](union.md#full).

Par souci d'exhaustivité, nous le soulignons,
que le principe des filtres indirects existe pour tous les types.
Nous voulons trouver tous les ponts sur la rivière _Alster_.

Nous pouvons trouver la rivière _Alster_ de deux façons différentes,
d'abord [par le chemin](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB):

    way[name="Alster"][waterway=river];
    out geom;

Nous cherchons tous les objets de type _way_,
qui ont l'attribut `name` avec la valeur `Alster` et l'attribut `waterway` avec la valeur `river`.
Celles-ci sont situées après la ligne 1 dans l'ensemble `_` et sont éditées à partir de là dans la ligne 2.

Nous trouvons les ponts au lieu de la rivière [comme suit](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB):

    way[name="Alster"][waterway=river];
    way(around:0)[bridge=yes];
    out geom;

Ici `(around:0)` dans la ligne 2 est le filtre indirect.
Dans la ligne 2, nous cherchons toutes les chemins,
qui ont l'attribut `bridge` avec la valeur `yes`
et qui ont une distance de 0 aux objets de l'ensemble `_`.
Nous avons rempli l'ensemble `_` à la ligne 1 avec les chemins dans le rayon desquelles nous voulons chercher,
toutes les chemins qui ont un attribut `name` avec la valeur `Alster` et un attribut `waterway` avec la valeur `river`.

Le tout fonctionne aussi [avec relations](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB) ...

    relation[name="Alster"][waterway=river];
    out geom;

... donc [avec des ponts](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB):

    relation[name="Alster"][waterway=river];
    way(around:0)[bridge=yes];
    out geom;

<a name="topdown"/>
## Objets empruntés

Nous avons rencontré une application de concaténation complètement différente dans les sections [Relations](../full_data/osm_types.md#rels) et [Relations sur relations](../full_data/osm_types.md#rels_on_rels) dans [Géométries](../full_data/osm_types.md):
Parce que le modèle de données OSM traditionnel ne permet que des coordonnées sur les _nœuds_,
mais aussi la géométrie des autres objets est intéressante,
_chemins_ et _relations_ doivent être complétés par les objets d'aide correspondants dans le modèle de données OSM traditionnel.

Les aspects d'chaînage sont expliqués à l'aide d'un exemple:
Certes la ligne de métro _Waterloo & City_ à Londres peut être obtenue [comme suit](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    rel[ref="Waterloo & City"];
    out geom;

Mais nous avons besoin d'un [modèle de données étendu](../targets/formats.md#extras),
que quelques applications ne supportent pas.
Si, en revanche, nous [utilisons](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB) le niveau de détail traditionnel _out_ pour la sortie,
nous ne voyons rien:

    rel[ref="Waterloo & City"];
    out;

La relation est toujours dans l'ensemble `_` après la sortie de la ligne 2.
Par conséquent, nous pouvons collecter les _chemins_ et les _nœuds_ correspondants,
[en combinant](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB) l'union expliquée [dans la section suivante](union.md#union) avec le chaînage:

    rel[ref="Waterloo & City"];
    out;
    (
      way(r);
      node(w);
    );
    out skel;

Avant la ligne 3 l'ensemble `_` contient les relations trouvées comme indiqué précédemment.
Les lignes 3 à 6 sont l'instruction [union](union.md#union).
La ligne 4 `way(r)` est donc la ligne suivante après la ligne 2 et obtient les relations en entrée.
Il recherche les _chemins_ qui satisfont le filtre `(r)`,
c'est-à-dire sont référencés par une ou plusieurs _relations_ dans l'entrée.
Comme résultat, il écrit maintenant ces _chemins_ dans l'ensemble `_`.
L'instruction _union_ en conserve une copie pour son résultat selon sa sémantique.

La ligne 5 `node(w)` trouve donc les _chemins_ de la ligne 4 comme entrées dans l'ensemble `_`.
Il recherche les _nœuds_ qui satisfont le filtre `(w)`,
c'est-à-dire référencés par une ou plusieurs _chemins_ dans l'entrée.
Comme résultat, il écrit ces _chemins_ dans l'ensemble `_`,
mais _union_ remplace l'ensemble par son propre résultat de toute façon.

Comme résultat de la ligne 6, l'instruction _union_ écrit l'unification des résultats dans l'ensemble `_`.
Nous obtenons donc toutes les _chemins_ qui ont été référencés par les relations
et tous les _nœuds_ référencés par ces _chemins_.

Cependant, les relations peuvent aussi avoir des _nœuds_ directement en tant que membres,
et ces relations ont réellement;
vous pouvez le voir dans [l'onglet de données](../targets/turbo.md#basics) ou [par requête](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    rel[ref="Waterloo & City"];
    node(r);
    out;

On remplace ainsi les _relations_ de la ligne 2 de l'ensemble `_` par les _nœuds_ référencés.
Ensuite, nous avons ces _nœuds_ disponibles pour la sortie de la ligne 3,
mais ils auraient à nouveau besoin de ces _relations_,
pour obtenir les _chemins_ référencés.
Peut-on éviter la double recherche?

Oui, [avec des ensembles nommés](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    rel[ref="Waterloo & City"];
    out;
    (
      node(r)->.directement_references_par_les_relations;
      way(r);
      node(w);
    );
    out skel;

En détail:

* Après la ligne 1, l'ensemble `_` contient toutes les _relations_,
  qui ont un attribut `ref` d'une valeur de `Waterloo & City`.
* Celles-ci sont sorties sur la ligne 2.
  L'ensemble `_` contient toujours les relations.
* L'instruction de bloc _union_ de la ligne 3 à la ligne 7 exécute le bloc qui s'y trouve.
* la ligne 4, `(r)` utilise donc le contenu d'ensemble `_`, à savoir les relations de la ligne 1.
  Ainsi, ces _nœuds_ sont maintenant stockés dans l'ensemble `directement_references_par_les_relations`,
  qui sont référencées par l'une des relations.
  L'instruction _union_ conserve une copie du résultat.
  Sinon, le résultat ne nous intéresse pas,
  mais voulons seulement empêcher l'instruction d'écraser l'ensemble `_`.
* la ligne 5, `(r)` utilise à nouveau le contenu d'ensemble `_`,
  et ce sont toujours les _relations_, parce qu'on ne les a pas écrasées.
  L'ensemble `_` contient maintenant les _chemins_ qui sont référencées par les _relations_.
  L'instruction _union_ conserve une copie du résultat.
* la ligne 6, `(w)` utilise à nouveau le contenu d'ensemble `_`.
  Ce sont maintenant les _chemins_ écrites à la ligne 5.
  Les _nœuds_ référencés par ces _chemins_ sont donc maintenant stockés dans l'ensemble `_`.
  L'instruction _union_ conserve une copie du résultat.
* L'instruction _union_ compose maintenant le résultat global à partir de ses résultats partiels des lignes 4, 5 et 6
  et l'écrire dans l'ensemble `_`.
* L'ensemble `_` est maintenant sorti sur la ligne 8.

Puisqu'il s'agit d'un problème très courant,
il y a [une abréviation pour cette tâche](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    rel[ref="Waterloo & City"];
    out;
    >;
    out skel;

Les lignes 1 et 2 fonctionnent exactement comme avant,
et la ligne 4 fonctionne exactement comme la ligne 8 avant:
Parce que la flèche de la ligne 3 a une sémantique,
qu'il trouve les _chemins_ et _nœuds_ directement et indirectement référencés aux relations dans l'ensemble `_`
et le dépenser sur l'ensemble `_`.

Maintenant, certains programmes sont surtaxés,
si l'ordre dans le fichier n'est pas exactement tous les _nœuds_, alors tous les _chemins_, puis toutes les _relations_.

Pour l'approche détaillée, cet objectif est atteint,
en [déplaçant](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB) la demande initiale vers l'instruction bloc _union_:

    (
      rel[ref="Waterloo & City"];
      node(r)->.direkt_von_den_relations_referenziert;
      way(r);
      node(w);
    );
    out;

La même chose [avec la flèche](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    (
      rel[ref="Waterloo & City"];
      >;
    );
    out;

<a name="difference"/>
## Différence

...
<!--  TODO: Differenz wegen ._-Falle -->

<a name="equality"/>
## Attributs à même valeur

...
<!-- TODO: Wertgleichheit via Evaluator -->