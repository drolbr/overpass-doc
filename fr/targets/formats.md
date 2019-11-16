Formats de données
==================

Il y a plusieurs formats de données pour récupérer des objets d'OpenStreetMap.
Nous présenterons tous les formats qui ont une application immédiate.

<a name="scope"/>
## Démarcation

Les types de données ont déjà été présentés dans [la section appropriée de l'introduction](../preface/osm_data_model.md).
Vous devriez donc déjà être familier avec les _nœuds_, les _chemins_ et les _relations_.

Cette section explique les formats de sortie.
D'autre part, les différents degrés de détail possibles sont présentés.
L'outil qui a besoin de quel format de sortie est expliqué dans la section sur l'outil.

Le problème commun de compléter la géométrie des objets OpenStreetMap,
est dédié à [la section sur les géométries](../full_data/osm_types.md) dans le chapitre [Toutes les données dans une région](../full_data/index.md).

<a name="faithful"/>
## Niveaux de verbosité traditionnels

D'abord au niveau de détail:
Alors que les formats de sortie sont contrôlés par un paramètre global pour chaque requête,
les niveaux de détail de chaque instruction de sortie sont contrôlés par ses paramètres.
Il est ainsi possible de mélanger différents niveaux de détail dans une même requête;
cette capacité est nécessaire pour une quantité optimale de données [de certaines variantes géométriques](../full_data/osm_types.md#full).
C'est ce qui est noté pour [chaque application](index.md).

Nous donnons également un exemple autour de Greenwich, la banlieue de Londres.
L'exemple est principalement choisi de telle sorte qu'il fournit seulement une quantité maitrisable des _nœuds_, _chemins_ et _relations_,
pour bien voir les données de l'onglet _Données_ d'Overpass Turbo.

Pour les niveaux de détail originaux d'OpenStreetMap, il existe une hiérarchie pour les activer:

L'instruction _out ids_ [revient](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids;

* les identifiants des objets

L'instruction _out skel_ [fournit](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) en outre les informations nécessaires,
pour construire la géométrie:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out skel;

* aux _nœuds_, leurs coordonnées
* à _chemins_ et _relations_ la liste des membres

L'instruction _out_ (sans ajouts) [retourne](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) les géodonnées complètes,
c'est à dire supplémentaires:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out;

* les attributs de tous les objets

L'instruction _out meta_ [retourne](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) en plus:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out meta;

* la version par objet
* l'horodatage de chaque objet

Enfin, l'instruction _out attribution_ retourne les données suivantes:

* l'identifiant de groupe de modifications
* l'identifiant d'utilisateur
* le nom d'utilisateur pour cet identifiant

Toutefois, ce dernier niveau de détail concerne les données qui, selon l'opinion dominante, relèvent de la protection des données.
Un [effort accru](../analysis/index.md) est donc nécessaire.
Étant donné que ces données ne sont requises pour aucune des applications discutées dans ce chapitre,
nous allons nous passer d'un exemple ici.

<a name="extras"/>
## Variantes

Il est possible d'ajouter trois degrés de détail à la géométrie supplémentaire.
Toutes les combinaisons entre les degrés de détail qui viennent d'être présentés et les degrés de détail géométrique supplémentaires sont possibles.

Le drapeau _center_ active une coordonnée unique pour chaque objet.
Ceci n'a pas de signification mathématique particulière,
mais se trouve simplement au milieu du rectangle englobant d'objet:
[Exemple 1](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids center;

[Exemple 2](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

Le drapeau _bb_ (pour _Bounding-Box_, rectangle englobant en anglais) active le rectangle englobant pour chaque objet:
[Exemple](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids bb;

Le drapeau _geom_ (pour _géométrie_) complète les coordonnées complètes.
Le niveau minimum de détail requis pour cela est _skel_,
donc cela fonctionne jusqu'à et y compris _l'attribution_:
[Exemple](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out skel geom;

Mais maintenant nous avons plus de quelques centaines de mètres dans un parc de Greenwich:
aussi plusieurs centaines de kilomètres de sentiers pédestres dans l'est de l'Angleterre.
Il s'agit d'un problème général de relations.
Comme remède, il y a aussi un rectangle englobant pour la commande de sortie, [voir là](../full_data/bbox.md#crop).

Enfin, il y a le format de sortie _tags_.
Ceci est basé sur _ids_ et affiche en plus des attributs, mais pas de géométries ou de structures.
C'est particulièrement utile si vous [n'avez pas besoin des coordonnées](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) dans le résultat:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out tags;

Cependant, il peut également [être combiné](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) avec les deux niveaux de géométrie _center_ et _bb_:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out tags center;

<a name="json"/>
## JSON et GeoJSON

Passons maintenant aux formats de données:
Même que le niveau de détail peut être sélectionné pour chaque commande de sortie,
le format de sortie n'est spécifié qu'une seule fois globalement pour chaque requête.
De plus, le choix du format de sortie change la forme, mais pas le contenu.

Au sein de JSON, l'enjeu est de combler un fossé.
D'une part, il existe un format commun pour les géodonnées, appelé GeoJSON.
D'autre part, les données OpenStreetMap doivent conserver leur structure,
et ça ne correspond pas aux spécifications de GeoJSON.

Comme solution, il y a la possibilité
de créez des objets compatibles GeoJSON à partir des objets OpenStreetMap.
Cependant, les objets OpenStreetMap originaux sont mappés fidèles à l'original dans JSON et ne sont pas GeoJSON.

OpenStreetMap objets [dans JSON](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:json];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out geom;

Éléments dérivés [dans JSON](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:json];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    convert item ::=::,::geom=geom(),_osm_type=type();
    out geom;

La création d'éléments dérivés est un grand complexe de sujets avec [son propre chapitre](../counting/index.md).

<a name="csv"/>
## CSV

Il est souvent utile de pouvoir organiser les données sous forme de tableaux.
Pour les données OpenStreetMap, cela signifie des colonnes sélectionnées par l'utilisateur.
et une ligne pour chaque objet trouvé.

La sélection des colonnes limite les informations disponibles sur l'objet pour la plupart des objets.
Par exemple, les attributs qui ne sont pas demandées comme colonnes ne sont pas éditées.
Des géométries plus complexes qu'une simple coordonnée ne peuvent pas non plus être affichées dans ce format.
C'est ce qui distingue ce format des formats XML et JSON potentiellement sans perte.

Le cas standard d'une colonne est la clé d'un attribut.
La valeur de cet attribut est ensuite sortie vers l'objet pour chaque objet.
Si l'objet n'a pas cet attribut, une valeur vide est sortie.
Il existe des valeurs spéciales pour les autres propriétés de l'objet;
ceux-ci commencent par `::`.
[exemple](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    [out:csv(::type,::id,name)];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

CSV lui-même signifiait à l'origine _comma separated value_ (anglais: _valeur séparée par des virgules_).
Cependant, les nombreux programmes qui l'utilisent ont développé des attentes différentes à l'égard des séparateurs.
Ainsi, le séparateur peut être configuré et le titre peut [être activé et désactivé](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:csv(::type,::id,name;false;"|")];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

Les [applications respectives](index.md) indiquent quelle variante convient le mieux.
