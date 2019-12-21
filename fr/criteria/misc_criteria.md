Plus des criterions
===================

Encore plus des criterions comme cherchant par longeur, par version d'objet, par nombre d'changeset ou nombre des members.

<a name="per_key"/>
## Seulement clés

Il peut être utile,
pour rechercher tous les objets où une certaine _clé_ est définie avec une _valeur_ quelconque.
Un [exemple](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB) avec _railway_:

    nwr[railway]({{bbox}});
    out geom;

Le filtre `[railway]` n'autorise que les objets qui portent un attribut `railway` avec n'importe quelle valeur.
Ici, il est combiné avec un filtre `({{bbox}})`,
pour que l'on puisse trouver exactement ces objets,
qui ont à la fois un attribut avec clé `railway`
ainsi que sont situés dans le rectangle englobant transmise par Overpass Turbo.

Toute clé peut être utilisée comme condition de filtrage en utilisant des crochets.
Les clés dont le nom contient un caractère spécial doivent être [mises entre guillemets](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB):

    nwr["addr:housenumber"]({{bbox}});
    out geom;

En principe, les filtres par clés peuvent également être utilisés comme seul filtre dans une instruction _query_.
Cependant, il n'y a guère de cas d'utilisation significative uniquement en termes de quantité de données et de durée de recherche.

Plusieurs de ces filtres peuvent également [être combinés](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB):

    nwr["addr:housenumber"]["addr:street"]({{bbox}});
    out geom;

Ici, nous ne nous intéressons qu'aux objets,
qui ont à la fois un numéro de maison et un nom de rue pour l'adresse.
L'instruction _query_ de la ligne 1 sélectionne exactement ces objets,
qui ont un attribut avec la clé `addr:housenumber` et en plus un attribut avec la clé `addr:street`.

Puisqu'il est également possible d'mettre en négation la condition,
il est également possible de rechercher de cette façon les objets qui doivent être traités.
Nous recherchons des objets qui [portent](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB) un attribut avec la clé `addr:housenumber` mais pas d'attribut à la clé `addr:street`:

    nwr["addr:housenumber"][!"addr:street"]({{bbox}});
    out geom;

La négation se fait par un point d'exclamation entre le crochet d'ouverture et le début de la clé.

<a name="count"/>
## Indicateurs d'un objet

Les filtres qui peuvent être utilisés pour compter les objets,
ne peut être utilisé qu'en combinaison avec d'autres filtres.
La raison en est que les volumes de données à traiter autrement deviennent rapidement incontrôlables.

Pour compter les attributs d'un objet, il faut mentionner ici les deux applications les plus populaires,
pour tous les autres, veuillez vous référer au chapitre [Compter des objets](../counting/index.md).

Il est possible de sélectionner tous les objets qui ont au moins un attribut.
Ici [pour les noeuds](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB), puisque presque tous les chemins et relations portent des attributs de toute façon:

    node(if:count_tags()>0)({{bbox}});
    out geom;

Inversement, il est également possible de sélectionner tous les objets qui ne portent pas des attributs.
Ici [pour chemins](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB):

    way(if:count_tags()==0)({{bbox}});
    out geom;

Cependant, les deux requêtes sont moins utiles qu'elles n'en ont l'air:
D'une part, il y a des attributs non informatives
(`created_by` sur _nœuds_, _chemins_ ou _relations_ est désapprouvé, mais pourrait bien exister encore)
d'autre part, les objets peuvent appartenir à des relations.

Pour les _chemins_ et _relations_, le nombre de membres peut être compté, calculé et comparé.
Vous trouverez également des exemples complets dans le chapitre [Compter des objets](../counting/index.md).

Nous pouvons trouver des _chemins_ [avec un nombre particulièrement important de membres](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB):

    way(if:count_members()>200)({{bbox}});
    out geom;

Ou vérifiez les relations pour voir si tous les membres ont des rôles plausibles.
Pour cela, nous utilisons l'évaluateur `count_by_role` en plus de l'évaluateur `count_members`,
pour l'[indiquer](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=12&Q=CGI_STUB) pour les restrictions de tourner:

    rel[type=restriction]({{bbox}})
      (if:count_members()
        -count_by_role("from")
        -count_by_role("to")
        -count_by_role("via") > 0);
    out center;

Ce ne sont pas de vraies erreurs:
comme mentionné explicitement dans tous les diagnostics et dans le chapitre [Analyser des données](../analysis/index.md),
les objets ayant des propriétés inattendues sont le début d'une recherche, et non sa fin.

<a name="geom"/>
## Chemins par longeur

Il est possible de déterminer la longueur d'un chemin ou d'une relation via l'évaluateur.
Outre les [évaluations statistiques](../counting/index.md), cela permet également
de selectionner chemins ou relations par leur longueur.
La longueur est toujours affichée en mètres.

Un exemple utilisé pour l'assurance qualité ont été les cheminées,
parce que l'attribut `building=chimney` associé a été occasionnellement utilisé pour l'ensemble du bâtiment industriel.
C'est pourquoi nous recherchons dans le monde entier toutes les cheminées [d'une circonférence de plus de 62 mètres](https://overpass-turbo.eu/?lat=30.0&lon=-0.0&zoom=1&Q=CGI_STUB):

    way[building=chimney](if:length()>62);
    out geom;

Il serait également évident de vouloir trouver de longues rues.
Mais comme les rues sont généralement composées de plusieurs sections,
nous devons d'abord regrouper les rues à nouveau.
Les requêtes de ce degré de complexité appartiennent plutôt au chapitre [Analyser des données](../analysis/index.md),
mais pour plus de commodité, une approche d'une longueur minimale de 2 km [est esquissée](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=14&Q=CGI_STUB) ici:

    [out:csv(length,name)];
    way[highway][name]({{bbox}});
    for (t["name"])
    {
      make stat length=sum(length()),name=_.val;
      if (u(t["length"]) > 2000)
      {
        out;
      }
    }

Les lignes 3 à 10 sont une boucle,
dans laquelle la sélection de la ligne 2, à savoir toutes les voies avec les clés `highway` und `name`
être regroupées après `name`.
Pour cette raison, on peut utiliser l'expression `sum(length())` à la ligne 5 pour totaliser la longueur de tous les objets d'un même nom.
Dans les lignes 6 à 9, nous n'écrivons alors une sortie que si la longueur atteinte dépasse 2000 mètres.

Une approche qui indique aussi quelque chose est difficile,
puisque chaque nom est représenté par de nombreux objets.
Une solution utilisant les _deriveds_ est également présentée dans le chapitre [Analyser des données](../analysis/index.md).

<a name="meta"/>
## Qualités metas

Il est possible de rechercher un objet directement par type et id,
[ici le nœud 1](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=CGI_STUB):

    node(1);
    out;

A cet effet, le filtre `(...)` avec l'identifiant entre les parenthèses montré ici sont disponibles,
et en plus les évaluateurs `id()` et `type()`.
Les cas d'utilisation directe ne me sont pas connus,
mais certaines fonctions importantes d'[analyse des données](../analysis/index.md) utilisent cette fonctionnalité.

En revanche, seulement un évaluateur est disponible pour la version d'un objet,
parce qu'un filtre seul conduirait à des quantités folles de données de toute façon.

Un cas d'utilisation populaire est d'identifier les imports absurdes ou illégaux.
Pour ce faire, il peut être utile [de sélectionner](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=CGI_STUB) tous les objets de la version 1 dans un rectangle englobant:

    nwr({{bbox}})
      (if:version()==1);
    out center;

Pour ce faire, l'évaluateur `version()` est utilisé ici à la ligne 2.
Comme pour tous les _évaluateurs_ utilisés comme _filtres_, cela se fait,
en comparant la valeur de l'_évaulateur_ avec une autre valeur (ici 1) dans le cadre du filtre `(if:...)`.

Pour les horodatages, il y a aussi essentiellement un évaluateur disponible, à savoir `timestamp()`.
Il existe en effet un filtre `(changed:...)`,
mais celui-ci est destiné à être utilisé [avec des données expirées](../analysis/index.md).

L'évaluateur `timestamp()` retourne toujours une date dans [le format de date international](https://fr.wikipedia.org/wiki/ISO_8601),
p. ex. `2012-09-13` pour le 13 septembre 2012.
Elle doit donc toujours être comparée à une date au format ISO.
Par exemple, nous énumérons tous les objets qui ont été modifiés pour la dernière fois près de Greenwich [avant le 13 septembre 2012](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=16&Q=CGI_STUB):

    nwr({{bbox}})(if:timestamp()<"2012-09-13");
    out geom({{bbox}});

Quelques pièges sont à retenir:

* Les _chemins_ et _relations_ peuvent modifier leur géométrie sans créer une nouvelle version,
  c'est-à-dire si seuls les _nœuds_ référencés ont été déplacés sans modifier le référencement.
* La plupart des propriétés d'un objet proviennent de versions antérieures,
  c'est-à-dire qu'une date de modification apparemment récente ne signifie pas nécessairement un objet actuel.

<a name="attribution"/>
## Attribution

...
