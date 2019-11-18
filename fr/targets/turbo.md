Overpass Turbo
==============

L'outil standard pour développer des requêtes.

<a name="overview"/>
## Bref aperçu

Overpass Turbo est un site Toile,
d'exécuter des requêtes API Overpass
et voir le résultat sur une carte.

De nombreux exemples de ce manuel créent des liens vers Overpass Turbo avec une requête prédéfinie appropriée.

Une instance publique est disponible à l'adresse [https://overpass-turbo.eu](https://overpass-turbo.eu).
Le code source se trouve sur [Github](https://github.com/tyrasd/overpass-turbo) ainsi que sur l'API Overpass.
Martin Raifer a développé Overpass Turbo;
je voudrais lui exprimer mes remerciements.

Presque tous les formats de sortie,
qui sont disponibles à l'API Overpass, 
peut également être compris par Overpass Turbo. 
Il y a des difficultés avec les requêtes avec de très grands ensembles de résultats;
aujourd'hui encore, les moteurs JavaScript des navigateurs utilisés atteignent les limites de leur gestion mémoire. 
C'est pourquoi Overpass Turbo demande, 
s'il a reçu un ensemble de résultats énorme, 
si l'utilisateur final veut prendre le risque de geler le navigateur.

Il y a beaucoup de caractéristiques populaires et utiles,
mais qui dépassent le cadre de ce manuel.
Veuillez consulter la [documentation](https://wiki.openstreetmap.org/wiki/FR:Overpass_turbo) sur Overpass Turbo.
Ceci est particulièrement vrai pour _Styles_ et le générateur de requêtes _Wizard_. 
Ce manuel se limite à l'interaction directe avec le langage de requête. 

<a name="basics"/>
## Assises

La vue du site Toile est divisée en plusieurs parties;
ils se distinguent par leur disposition entre la version de bureau et la version mobile.
[Ouvrez le](https://overpass-turbo.eu) maintenant dans un onglet séparé.

Dans la version de bureau, il y a une grande zone de texte à gauche;
ici, vous devez entrer votre requête.
Sur la droite se trouve une section de carte.
Via les deux onglets _Carte_ et _Données_, vous pouvez choisir entre la carte
et un champ texte pour les données reçues.

Dans la version mobile, le champ de texte représente la requête au-dessus de la section de carte.
Le deuxième champ de texte pour les données reçues se trouve sous la section de carte.
Au lieu des onglets, vous pouvez faire défiler les deux parties en faisant défiler courageusement.

Nous pratiquons le cas d'utilisation standard:
Tapez

    nwr[name="Canary Wharf"];
    out geom;


dans la zone de texte (ou utilisez [ce lien](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=18&Q=CGI_STUB))!

Cliquez maintenant sur _Exécuter_.
Un message d'avancement apparaîtra sous peu,
vous verrez presque la même image qu'avant.

Cliquez maintenant sur la loupe.
Il s'agit du troisième symbole à partir du haut à gauche de la section de carte, sous les boutons plus/moins.
L'affichage de la carte passe maintenant à la résolution la plus fine,
qui montre toujours tous les résultats.

Les objets sélectionnés dans la section de carte sont maintenant exactement les objets,
qui a trouvé la requête.

C'est souvent utile,
d'examiner directement les données effectivement fournies.
Ceci peut être fait avec l'onglet _Données_ dans le coin supérieur droit au-dessus de la vue de la carte.
ou avec défilement vers le bas dans la version mobile.

Indépendamment de cela, tous les objets surlignés sur la carte peuvent être cliqués et ensuite affichés,
en fonction de l'étendue de leurs données,
leur identifiant, leurs attributs ou leurs métadonnées.

A un moment donné, vous rencontrerez le message,
que tous les objets n'étaient pas fournis avec la géométrie.
Vous pouvez ensuite tester la modification de la requête pour la compléter automatiquement.
Ou vous pouvez remplacer toutes les occurrences de `out` par leurs contreparties avec la géométrie `out geom`.

Si vous attendez un résultat énorme
ou que vous souhaitez traiter les données avec un autre programme de toute façon,
vous pouvez également exporter les données directement pour les télécharger sans les afficher:
Tapez à _Exporter_,
restent dans la fenêtre qui apparaît dans l'onglet _Données_.
et sélectionnez `Données brutes depuis l'API Overpass`.
Ceci est normal pour les requêtes de longue durée,
qu'après le clic, rien ne semble se passer.

Deux extras utiles méritent d'être mentionnés :

* En bas à droite de la carte se trouvent les compteurs,
  combien d'objets de quel type ont été retournés dans la dernière requête.
* Il y a un champ de recherche en haut à gauche de la section de carte.
  Ceci a une performance inférieure à [Nominatim sur openstreetmap.org](../criteria/nominatim.md),
  mais la recherche disponible pour les noms de lieux est généralement suffisante,
  pour placer rapidement la section de carte au endroit pertinent.

<a name="symbols"/>
## Légende

La [documentation](https://wiki.openstreetmap.org/wiki/DE:Overpass_turbo) explique déjà les couleurs.
C'est pourquoi nous nous concentrons davantage sur l'interaction:
Vous avez une idée d'un objet concret ou d'un type d'objet,
qu'il s'agisse d'un nœud, d'un chemin, d'une surface, d'une composition, de quelque chose d'abstrait ou de quelque chose aux frontières floues.
Dans les structures de données OpenStreetMap, il est modélisé d'une certaine manière;
il peut, mais ne correspond pas nécessairement à vos attentes.

L'API Overpass fournit [outils](formats.md#extras),
pour passer de la modélisation OpenStreetMap à une seule,
qui s'adapte mieux à la représentation;
soit en obtenant les coordonnées ou la simplification géométrique ou [restriction d'affichage](../full_data/bbox.md#crop).
Overpass Turbo doit maintenant fournir la meilleure représentation possible dans tous les cas,
peu importe si la modélisation dans OpenStreetMap est encore évidente,
et que le format de sortie sélectionné dans la requête corresponde ou non aux données.

Cette section a pour but d'expliquer
qui finit par apparaître sur l'affichage de la carte
et comment cela se rattache à la requête et aux données.

Les objets ponctuels peuvent avoir un intérieur jaune ou rouge.
Avec un intérieur jaune, ce sont de vrais _nœuds_,
avec un intérieur rouge, ce sont de _chemins_.

Les chemins peuvent devenir des points soit à cause de leur petite longueur,
sinon ils seraient trop discrets:
Veuillez effectuer un zoom arrière [dans cet exemple](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=CGI_STUB)
et regarder les bâtiments et les rues devenir des points!

    ( way({{bbox}})[building];
      way({{bbox}})[highway=steps]; );
    out geom;

Si cela interfère avec une requête spécifique,
vous ne pouvez pas le désactiver sous _Paramètres_, _Carte_, _N'affiche pas les petits objets comme points d'intérêts_.
La modification ne prend effet qu'après l'exécution de la requête suivante.

Ou ils peuvent être affichés sous forme de points,
car [la requête](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=19&Q=CGI_STUB) sort via `out center`:

    way({{bbox}})[building];
    out center;

Les objets ponctuels peuvent avoir une bordure bleue ou violette;
Ceci s'applique également aux objets dessinés sous forme de polyligne ou de surface.
Dans tous ces cas, _relations_ [sont impliqués](https://overpass-turbo.eu/?lat=51.5045&lon=-0.0195&zoom=16&Q=CGI_STUB):

    rel[name="Canary Wharf"];
    out geom;

Contrairement à _nœuds_ ou _chemins_, les détails de la _relation_ ne sont pas disponibles en cliquant sur l'objet,
mais dans la bulle il n'y a qu'un lien vers la _relation_ sur le serveur _openstreetmap.org_.
Dans des circonstances normales, ce n'est pas un problème.

Mais si vous avez spécifiquement demandé une ancienne version,
alors les données de la page principale sont différentes de celles obtenues via l'API Overpass.
Alors il n'y a pas d'autre solution,
pour examiner les données retournées elles-mêmes via l'onglet _Données_.

Si, par contre, la ligne ou la bordure de la zone est en pointillés,
la géométrie de l'objet est incomplète.
C'est généralement un effet désiré de la [restriction d'affichage](../full_data/bbox.md#crop) ([exemple](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=16&Q=CGI_STUB)):

    (
      way(51.475,-0.002,51.478,0.003)[highway=unclassified];
      rel(bw);
    );
    out geom(51.475,-0.002,51.478,0.003);

Cependant, il peut aussi être le résultat d'une requête,
qui a chargé certains _chemins_, mais pas tous _nœuds_ à _chemins_.
Ici nous avons chargé _chemins_ basé sur _nœudes_,
mais [oublié](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB) pour demander les nœuds manquants directement ou indirectement:

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out;

La requête peut être [corrigée](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB) par `out geom`;
plus de possibilités sont expliquées dans la section [Géométries](../full_data/osm_types.md#nodes_ways):

    (
      node(51.475,-0.003,51.478,0.003);
      way(bn);
    );
    out geom;

<a name="convenience"/>
## Commodités

Overpass Turbo offre quelques fonctions de confort.

Il peut insérer automatiquement la rectangle englobant de la fenêtre courante dans une requête.
Overpass Turbo remplace chaque occurrence de la chaîne `{{bbox}}` par les quatre marges,
pour qu'un rectangle englobant valide soit créée.

Vous pouvez même voir la boîte de délimitation transférée,
si vous l'insérez [à un endroit autre](https://overpass-turbo.eu/?lat=51.4765&lon=0.0&zoom=17&Q=CGI_STUB) que l'endroit habituel (et cliquez sur _Données_ après exécution):

    make Exemple info="Le rectangle englobant courant est {{bbox}}";
    out;

Une deuxième fonction utile se trouve derrière le bouton _Partager_ dans le coin supérieur gauche.
Cela crée un lien,
où la requête saisie à ce moment-là peut être récupérée de façon permanente.
Même si quelqu'un d'autre emprunte le lien et édite la requête,
alors la requête originale sous le lien sera toujours conservée.

La vue actuelle de la carte peut également être ajoutée à lien via la case à cocher.
Cela signifie le centre de la vue et le niveau de zoom,
c'est-à-dire que différentes sections de carte sont visibles sur des écrans de tailles différentes.

<a name="limitations"/>
## Limitations

Overpass Turbo peut gérer presque tous les types de sortie de l'API Overpass.
Mais il y a encore quelques limites:

Overpass Turbo n'affiche qu'un seul objet par identifiant et type d'objet.
Par conséquent, [diffs](index.md) ne peut pas judicieusement être affiché avec Overpass Turbo.

Overpass Turbo n'affiche pas [GeoJSON](formats.md#json) directement depuis l'API Overpass.
Overpass Turbo est livré avec son propre module de conversion pour GeoJSON,
et Martin pense que la confusion des utilisateurs est trop grande,
si les deux mécanismes sont utilisés en parallèle.
Pour l'instant, l'[instance expérimentale](https://olbricht.nrw/ovt/) doit être invoquée dans ce cas.

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
