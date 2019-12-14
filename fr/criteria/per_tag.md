Par Tag
=======

Requêter pour tous les objets qui possèdent un attribut particulier.

<a name="global"/>
## Globalement

Nous voulons trouver tous les objets dans le monde entier,
où un [attribut](../preface/osm_data_model.md#tags) donné est présent.

Ceci n'est utile que via l'API Overpass pour les attributs ayant moins de 10 000 occurrences;
vous pouvez trouver le numéro correspondant sur [Taginfo](nominatim.md#taginfo).
Avec des nombres plus importants, cela peut prendre trop de temps,
pour obtenir les données,
ou le navigateur plante pendant l'affichage
ou les deux.

Les requêtes [avec restrictions spatiales](#local) fonctionnent également bien sur les attributs fréquents.

Un exemple typique pour les attributs rares sont les noms de choses, [ici](https://overpass-turbo.eu/?lat=51.47&lon=0.0&zoom=12&Q=CGI_STUB) Cologne (_Köln_ en Allemand):

    nwr[name="Köln"];
    out center;

Comme vous pouvez le voir, vous ne voyez rien après avoir cliqué sur _Exécuter_.
Seule [la loupe](../targets/turbo.md#basics) permet de voir les données.
Nous utilisons une vue globale de la carte glissante pour toutes les requêtes suivantes,
pour que tu n'aies pas à te recentrer.

Cependant, même dans des cas évidents, de telles recherches peuvent échouer.
Il y a [des résultats](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) pour Francfort (_Frankfurt_ en Allemand) à travers le monde,
et l'objet pour la ville sur la Main n'est même pas là:

    nwr[name="Frankfurt"];
    out center;

La raison en est que l'ajout _am Main_ est dans le nom.
L'API Overpass négligerait [sa tâche principale](../preface/assertions.md#faithful),
si elle trouve quand même l'objet.
Une recherche interprétative est la tâche d'un géocodeur, par exemple [Nominatim](nominatim.md).

Cependant, il y a des requêtes pour cela, par exemple par des _expressions régulières_.
Nous pouvons [rechercher](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) tous les objets dont le nom commence par _Frankfurt_;
à cause des nombreux résultats, la recherche prend beaucoup de temps,
mais la taille de résultat reste inoffensive dans ce cas malgré le message d'avertissement:

    nwr[name~"^Frankfurt"];
    out center;

Beaucoup d'autres utilisations typiques des _expressions régulières_ sont expliquées [ci-dessous](#regex).

Ce sont maintenant beaucoup de résultats,
surtout les rues dont le nom commence par _Frankfurt_.
En règle générale, toutefois, vous recherchez un type d'objet spécifique.
Dans le cas d'une limite de ville, c'est toujours une _relation_.
Nous pouvons le rechercher spécifiquement,
[en écrivant](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB) _relation_ au lieu de _nwr_ (pour Nodes-Ways-Relations):

    relation[name="Köln"];
    out geom;

Ici, aussi le [type de sortie](../targets/formats.md#extras) passe de _center_ à _geom_,
pour que vous puissiez voir la géométrie complète de l'objet.

En conséquence, il y a aussi les types _node_ et _way_ au lieu de _nwr_.
Ils ne renvoient que des nœuds ou que des voies.

Enfin, les attributs avec des caractères spéciaux (tout sauf les lettres, les chiffres et le trait de soulignement) dans la _clé_ ou la _valeur_ doivent être mentionnées.
L'observateur attentif ne s'est pas échappé,
que la valeur dans les requêtes est toujours entre guillemets en haut.
Cela serait également nécessaire pour les clés;
la requête ci-dessus est écrit entièrement formellement:
<!-- NO_QL_LINK -->

    relation["name"="Köln"];
    out geom;

Cependant, l'API Overpass ajoute les guillemets tacitement,
quand il est clair qu'il s'agit d'une intention.
Ceci ne peut pas fonctionner avec les caractères spéciaux,
parce que les caractères spéciaux pourraient aussi avoir une autre signification
et l'utilisateur peut s'être trompé ailleurs lors de la rédaction de la requête.

Les guillemets sont utilisés dans les valeurs,
en antéposant un backslash.

<a name="local"/>
## Localement

Si vous voulez rechercher tous les objets avec un attribut dans une zone,
il s'agit en fait d'une combinaison de plusieurs opérateurs;
ceci est systématiquement décrit aux points [Opérations ET et OU](union.md) et [Enchainer](chaining.md).
Voici seulement quelques cas standard.

Tous les objets dans un lieu unique sont par exemple [tous les cafés de Cologne](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    area[name="Köln"];
    nwr[amenity=cafe](area);
    out center;

La fonction exacte de la première ligne est expliquée sous [Surfaces](../full_data/area.md#per_tag).
Nous sommes particulièrement intéressés par la deuxième ligne:
Il s'agit d'une _requête_ de type cible _nwr_ (c'est-à-dire que nous recherchons des _nœuds_, des chemins (_ways_) et des _relations_);
premièrement le filtre `[amenity=cafe]` est mis,
c'est-à-dire que nous n'autorisons que les objets pour lesquels l'attribut avec la clé _amenity_ existe et est définie sur la valeur _cafe_.
Deuxièmement, le filtre `(area)` limitant la zone est mis.

Le filtre `(area)` fonctionne [par enchaînement](../preface/design.md#sequential).

De cette façon, nous recherchons les objets pour lesquels la condition d'attribut et la condition spatiale s'appliquent.
Celles-ci sont, encore une fois [d'affilée](../preface/design.md#sequential),
prêt à être édité dans la ligne suivante.

Si c'est trop compliqué pour vous,
mais il y a aussi un moyen plus simple:
Vous pouvez utiliser [un rectangle englobant](../full_data/bbox.md#filter) pour limiter l'espace et le combiner avec le filtre pour un attribut ([exemple](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB)):

    nwr[amenity=cafe]({{bbox}});
    out center;

L'élément central ici est aussi la ligne commençant par _nwr_:
Le filtre `[amenity=cafe]` fonctionne comme dans l'exemple précédent;
Le filtre `({{bbox}})` est remplit par [Overpass Turbo](../targets/turbo.md#convenience) pour nous avec le rectangle englobant de délimitation actuellement visible,
et l'API Overpass applique ensuite cette rectangle englobant comme deuxième filtre.

Comme pour tous les filtres, l'ordre des deux filtres [n'a pas d'importance](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    nwr({{bbox}})[amenity=cafe];
    out center;

a le même résultat que la requête précédente.

Encore une fois, le type d'instruction de requête entre _node_ (le nœud), _way_ (le chemin) et la _relation_ peut et doit être choisi de manière appropriée,
par exemple, [seulement les chemins](https://overpass-turbo.eu/?lat=50.94&lon=6.95&zoom=14&Q=CGI_STUB) pour les chemins de fér:

    way[railway=rail]({{bbox}});
    out geom;

<a name="regex"/>
## Particulièrement

Dans le cas de Francfort, nous avons déjà rencontré le problème,
que nous voulons chercher une valeur sans être précis.
Un outil très puissant sont les [expressions régulières](https://www.gnu.org/software/grep/manual/grep.html#Regular-Expressions).
Une introduction systématique aux expressions régulières dépasse le cadre de ce manuel,
mais il y a au moins quelques exemples de cas courants.

Dans de nombreux cas, nous connaissons le début d'un nom.
Par exemple, nous cherchons ici les rues dont le nom [commence](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) par _Emmy_:

    way[name~"^Emmy"];
    out geom;

Le caractère le plus important dans toute la requête est le tilde `~`.
Il s'affiche sur la première ligne du filtre,
que les valeurs doivent être évaluées par une expression régulière.
Maintenant, toutes les valeurs existantes pour la clé `name` dans la base de données sont comparées avec l'expression régulière après le tilde.

Le deuxième caractère le plus important est l'accent circonflexe dans l'expression `^Emmy`;
ceci fait partie de l'expression régulière
et assurez-vous que seules les valeurs qui commencent avec `Emmy` correspondent.
Tout compte fait, c'est écrit:

Trouver tous les objets de type `way` (chemin),
qui ont un attribut avec une clé `name` et une valeur,
en commençant par `Emmy`.

La deuxième ligne contient alors une [instruction de sortie](../targets/formats.md#extras) correspondante.

Vous pouvez également rechercher des valeurs,
[se terminant](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) à une certaine valeur, par exemple _Noether_:

    way[name~"Noether$"];
    out geom;

Le tilde `~` affiche à nouveau le filtre après une expression régulière.
Le signe du dollar `$` défini dans l'expression régulière,
que la valeur devrait se terminer par `Noether`.

La [loupe comme](../targets/turbo.md#basics) fonction confort de l'_Overpass Turbo_ permet de zoomer sur le seul résultat à Paris.

Il est également possible de rechercher une sous-chaîne,
quelque part [au milieu](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB):

    way[name~"Noether"];
    out geom;

Il suffit d'écrire la chaîne de caractères sans caractères supplémentaires.

Ça devient un peu plus difficile,
si vous voulez trouver deux (ou plusieurs) chaînes de caractères,
p. ex. nom et prénom,
mais on ne sais pas ce qu'il y a entre les deux.
Dans _Emmy Noether_, le trait d'union et l'espace sont tous deux présents.
Vous pouvez [mettre entre crochets](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) tous les caractères possibles (deux ou plus):

    way[name~"Emmy[ -]Noether"];
    out geom;

Vous pouvez également autoriser [tous les caractères](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) en même temps:

    way[name~"Emmy.Noether"];
    out geom;

Le charactère décisif ici est le point `.`.
Il représente un seul caractère arbitraire.

Parfois, c'est nécessaire,
pour autoriser [un nombre quelconque de caractères intermédiaires](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB).
Vous recherchez donc deux chaînes de caractères distinctes.
Le compositeur _Bach_ en est un exemple;
il a encore plus de prénoms d'après _Johann_:

    way[name~"Johann.*Bach"];
    out geom;

Ici, les deux caractères spéciaux point `.` et étoile `*` travaillent ensemble.
Le point correspond à n'importe quel caractère,
et l'étoile signifie,
que le caractère précédent peut être répété aussi souvent que souhaité (pas du tout, une ou plusieurs fois).

Le point d'interrogation vient s'y ajouter:
Le caractère précedent peut apparaître [zéro ou une seule fois](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB).
Cela nous aide avec _Gerhard_ ou _Gerard_ ou _Gerardo Mercator_:

    way[name~"Gerh?ardo?.Mercator"];
    out geom;

Enfin, il convient de mentionner le cas,
qui [revient](union.md) à ET et OU:
Trouvez [une valeur dans une liste](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) telle que les valeurs par défaut _trunk_, _primary_, _secondary_, _tertiary_ pour les routes principales!

    way[highway~"^(trunk|primary|secondary|tertiary)$"]({{bbox}});
    out geom;

Nous sommes intéressés par le filtre `[highway~"^(trunk|primary|secondary|tertiary)$"]`;
le tilde `~` montre l'expression régulière.
Dans l'expression régulière, l'accent circonflexe au début et le signe du dollar à la fin signifient,
que la _valeur_ totale, et pas seulement une sous-chaîne, doit correspondre à la valeur intermédiaire.
La ligne verticale `|` signifie OU,
et les pinces font en sorte que ça arrive,
que l'accent circonflexe et de dollar n'affectent pas qu'une seule valeur.

<a name="numbers"/>
## Par nombre

...
