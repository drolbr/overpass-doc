Modèle d'exécution
==================

Selon quelles règles l'API Overpass exécute-t-elle une requête?
La présentation des différents éléments constitutifs favorise la compréhension,
comment ils interagissent dans les requêtes.

<a name="sequential"/>
## Séquences

La plupart des cas d'utilisation de requêtes avancées nécessitent des sélections relatives.
Les supermarchés qui sont près d'une gare en sont un bon exemple.
Les supermarchés ne sont reliés aux gares que par cette qualité,
qu'ils sont spatialement proches l'un de l'autre.

D'après le tour de phrase, on cherche d'abord les supermarchés,
puis cherchez dans tous les supermarchés les gares ferroviaires à proximité
et ne garder que les supermarchés où nous avons trouvé une gare.
Cette approche conduit rapidement à des monstruosités relatives en langage naturel;
même en langage formel, cela ne s'améliore pas.

Par conséquent, le langage de requête de l'API Ovepass suit plutôt un paradigme pas a pas,
de la soi-disant _programmation impérative_.
Une seule tâche gérable est résolue à la fois,
et maîtrisé la tâche complexe en les enchaînant.
L'approche est alors la suivante:

* Sélectionner toutes les stations dans la zone cible
* Remplacez la sélection par tous les supermarchés situés à proximité de ces gares.
* Retournez la liste des supermarchés

Il en résulte la requête suivante ligne par ligne.
Vous pouvez maintenant l'[exécuter](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=13&Q=nwr%5Bpublic_transport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%3B%0Anwr%5Bshop%3Dsupermarket%5D%28around%3A100%29%3B%0Aout%20center%3B):

    nwr[public_transport=station]({{bbox}});
    nwr[shop=supermarket](around:100);
    out center;

Les détails de la syntaxe seront expliqués plus loin.

Pour des cas plus simples, vous pourriez vouloir une syntaxe encore plus simple,
mais la solution à deux lignes qui en résulte reflète la répartition claire des tâches:

    nwr[shop=supermarket]({{bbox}});
    out center;

* L'instruction ou les instructions de sélection déterminent _ce qui_ est édité.
* L'instruction _out_ détermine _comment_ les objets sélectionnés sont édités. Détails à propos [les formats de sortie](../targets/formats.md#faithful)

<a name="statements"/>
## Instructions et filtres 

Nous comparons la requête pour les supermarchés uniquement dans la zone de visibilité

    nwr[shop=supermarket]({{bbox}});
    out center;

avec la requête ci-dessus

    nwr[public_transport=station]({{bbox}});
    nwr[shop=supermarket](around:100);
    out center;

pour identifier les composants individuels.

Le caractère le plus important est le point-virgule; il termine une _instruction_ à la fois.
Les sauts de ligne, les espaces (et les tabulations) ne sont pas pertinents pour ceci et pour la syntaxe dans son ensemble.
Ces _statements_ sont exécutés l'un après l'autre dans l'ordre,
où ils sont écrits.
Ainsi, dans les deux requêtes, il y a quatre instructions ensemble:

* ``nwr[shop=supermarket]({{bbox}});``
* ``nwr[public_transport=station]({{bbox}});``
* ``nwr[shop=supermarket](around:100);``
* ``out center;``

L'instruction ``out center`` est une instruction de sortie sans autres sous-structures.
Les possibilités de contrôle du format de sortie sont discutées dans la section [Formats de données](../targets/formats.md).

Les _statements_ restants sont tous des instructions de type _query_,
c'est-à-dire qu'ils sont utilisés pour sélectionner des objets.
Ceci s'applique à tous les énoncés commençant par ``nwr`` et autres mots-clés spéciaux:
les mots-clés ``node``, ``way`` et ``relation`` chacun respectivement restrictent le résultat à des objets de type nœud, chemin et relation,
mais ``nwr`` (acronym de _node_, _way_, _relation_) fournit tous les trois types.
Ils ont plusieurs sous-structures ici:

* ``[shop=supermarket]`` et ``[public_transport=station]``
* ``({{bbox}})``
* ``(around:100)``

Toutes les sous-structures d'une instruction _query_ filtrent les objets à sélectionner
et sont donc appelées _filter_.
Il est possible de combiner n'importe quel nombre de filtres dans une instruction de type _query_;
l'instruction sélectionne exactement ces objets,
qui remplissent tous les filtres.
L'ordre des filtres n'a pas d'importance,
car les filtres d'une instruction sont appliqués simultanément.

Alors que ``[shop=supermarket]`` et ``[public_transport=station]`` permettent tous les objets,
qui ont un qualité précis (supermarchés dans un cas, gares dans l'autre),
``({{bbox}}})`` et ``(around:100)`` sont utilisés pour le filtrage spatial.

Le filtre ``({{bbox}})`` permet exactement de tels objets,
qui se trouvent en tout ou en partie dans le rectangle englobant.

Le filtre ``(around:100)`` marche un peu plus compliqués.
Il a besoin d'un input et accepte exactement tous les objets,
qui ne sont pas à plus de 100 mètres de l'un des objets de input.

C'est là que l'exécution pas à pas prend effet:
Le filtre ``(around:100)`` reçoit ici comme input exactement les stations sélectionnées dans la ligne précédente.

<a name="block_statements"/>
## Instructions de bloc

Comment réaliser une opération _ou_?
[De cette façon](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=%28%0A%20%20nwr%5Bpublic%5Ftransport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20nwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%29%3B%0Aout%20center%3B), vous pouvez trouver tous les objets qui sont un supermarché _ou_ une gare:

    (
      nwr[public_transport=station]({{bbox}});
      nwr[shop=supermarket]({{bbox}});
    );
    out center;

Ici, les deux instructions de requête forment un bloc dans une structure plus grande.
La structure indiquée par les crochets s'appelle donc une _instruction de bloc_.

Cette structure de bloc spéciale s'appelle _union_,
et il est utilisé pour lier plusieurs instructions de cette façon,
qu'il sélectionne tous les objets
trouvées dans l'une ou plusieurs des instructions du bloc.
Il doit y en avoir au moins une et il peut y avoir un nombre illimité d'instructions dans le bloc.

Il y a de nombreuses autres _instructions de bloc_:

* L'instruction _difference_ vous permet de couper une sélection à partir d'une autre.
* _if_ n'exécute son bloc que si la condition de l'en-tête évalue à _vrai_.
  Un deuxième bloc est également possible;
  ceci est exécuté si la condition évalue à _fausse_.
* _foreach_ exécute son bloc une fois par objet dans son input.
* _for_ regroupe d'abord les objets et exécute ensuite son bloc une fois par groupe.
* _complete_ exécute les tâches d'une boucle _while_.
* Des autres instructions de bloc permettent de récupérer des données supprimées ou obsolètes.

<a name="evaluators"/>
##  Évaluations et éléments dérivées

Ce n'est pas encore expliqué,
comment les conditions peuvent être formulées dans l'instructions de bloc _if_ ou _for_.

Toutefois, le mécanisme utilisé à cette fin est également utile pour d'autres tâches.
Par exemple, vous pouvez créer une [liste de tous les noms de rues](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28name%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Saisie%20name%3D%5F%2Eval%3B%0A%20%20out%3B%0A%7D) dans une zone.

    [out:csv(name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Saisie name=_.val;
      out;
    }

Les lignes 2 et 6 contiennent les phrases simples ``way[highway]({{bbox}})`` et ``out`` respectivement.
Avec ``[out:csv(name)]`` dans la ligne 1, le format de sortie est contrôlé ([voir là](../targets/index.md)).
Les lignes 3, 4 et 7 forment l'instruction de bloc ``for (t["name"])``;
elle doit savoir, selon quel critère elle doit regrouper les objets selectionnés.

L'_évaluation_ ``t["name"]`` répond à cette question.
Une _évaluation_ est une expression,
qui est évalués au cours de l'exécution d'une instruction.

C'est une expression qui est évaluée pour chaque élément,
puisque _for_ nécessite des informations par élément.
L'expression ``t["name"]`` évalue la valeur de l'attribut avec la clé _name_ d'un objet.
Si l'objet n'a pas d'attribut avec la clé _name_,
l'expression évalue à une chaîne des caractère vide.

La ligne 5 contient également une évaluation avec ``_.val``.
Ceci permet de générer la valeur à éditer.
L'instruction _make_ crée toujours un seul objet à partir de plusieurs objets potentiels,
la valeur de ``_.val`` ne doit donc pas dépendre d'objets individuels.
L'évaluation ``_.val`` retourne la valeur de l'expression de la boucle courante dans une boucle,
ici la valeur de l'attribut _name_ de tous les objets pertinents.

Si une valeur indépendante est attendue, mais qu'une valeur dépendante de l'objet est spécifiée,
un message d'erreur s'affiche.
Cela se produit, par exemple, si nous voulions afficher la longueur des routes:
[Essayez-le](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Saisie%20name%3D%5F%2Eval%2Clength%3Dlength%28%29%3B%0A%20%20out%3B%0A%7D), s'il vous plaît:

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Saisie name=_.val,length=length();
      out;
    }

Les différents segments d'une rue portant le même nom peuvent avoir des longueurs différentes.
Nous pouvons résoudre ce problème en spécifiant comment les objets doivent être regroupés.
Souvent, on veut [une liste](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Saisie%20name%3D%5F%2Eval%2Clength%3Dset%28length%28%29%29%3B%0A%20%20out%3B%0A%7D):

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Saisie name=_.val,length=set(length());
      out;
    }

Dans ce cas particulier, cependant, [la sommation](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Saisie%20name%3D%5F%2Eval%2Clength%3Dsum%28length%28%29%29%3B%0A%20%20out%3B%0A%7D) est probablement plus utile:

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Saisie name=_.val,length=sum(length());
      out;
    }

L'instruction _make_ crée toujours exactement un nouvel objet, appelé _dérivée_.
Pourquoi un objet, pourquoi pas juste un objet OpenStreetMap?
Les raisons varient d'un cas d'utilisation à l'autre:
ici, nous avons besoin de quelque chose que nous pouvons retourner.
Dans d'autres cas, on souhaite modifier et supprimer les attributs des objets OpenStreetMap,
ou simplifier la géométrie de l'objet OpenStreetMap,
ou a besoin d'un transporteur pour des informations spéciales.

Les objets OpenStreetMap apparents doivent suivre les règles des objets OpenStreetMap
et ne permettent donc pas beaucoup de libertés utiles.
Surtout, ils pourraient être confondus avec de vrais objets OpenStreetMap
et re-téléchargés à _openstreetmap.org_ par erreur.

Vous pouvez voir les objets générés si vous laissez la requête [à format de sortie XML](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=way%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Saisie%20name%3D%5F%2Eval%2Clength%3Dsum%28length%28%29%29%3B%0A%20%20out%3B%0A%7D):

    way[highway]({{bbox}});
    for (t["name"])
    {
      make Saisie name=_.val,length=sum(length());
      out;
    }

<a name="sets"/>
## Plusieurs sélections en parallèle

Dans de nombreux cas, cependant, une seule sélection ne suffit pas.
Par conséquent, les sélections peuvent également être stockées dans des variables nommées
et ainsi garder plusieurs sélections en même temps.

Nous voulons trouver tous les objets d'un même genre,
qui ne sont pas près d'objets de l'autre genre.
Des exemples plus proches à la quotidienne sont souvent la recherche d'erreurs,
p. ex. quais sans voies ou adresses sans rues.
Mais nous n'aborderons pas les subtilités de les attributs maintenant.

Nous enquêtons donc sur tous les supermarchés,
qui [ne sont pas près](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Bpublic%5Ftransport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%2D%3E%2Eall%5Fstations%3B%0A%28%0A%20%20nwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20%2D%20nwr%2E%5F%28around%2Eall%5Fstations%3A300%29%3B%0A%29%3B%0Aout%20center%3B) des gares:

    nwr[public_transport=station]({{bbox}})->.all_stations;
    (
      nwr[shop=supermarket]({{bbox}});
      - nwr._(around.all_stations:300);
    );
    out center;

Par la ligne 3, la mention ``nwr[shop=supermarket]({{bbox}})`` sélectionne tous les supermarchés dans le rectangle englobant.
Nous voulons supprimer un sous-ensemble et donc utiliser une instruction de bloc de type _difference_;
Les trois éléments ``(`` à la ligne 2, ``-`` à la ligne 4 et ``)`` à la ligne 5 permettent de le reconnaître.

Nous devons choisir des supermarchés près des gares.
Pour ce faire, nous devons choisir les stations comme ci-dessus;
mais nous avons aussi besoin de tous les supermarchés comme sélection.
C'est pourquoi nous guidons la sélection des stations par la _variable d'ensemble_ ``all_stations``.
Dans la ligne 1, la sélection passe d'une instruction ordinaire ``nwr[public_transport=station]({{bbox}})`` à cette variable en utilisant la syntaxe ``->.all_stations``.
L'ajout ``.all_stations`` dans ``(around.all_stations:300)`` le fera,
que cette variable est utilisée comme source au lieu de la dernière sélection.

Cela ferait ``nwr[shop=supermarket]({{bbox}})(around.all_stations:300)`` la bonne instruction,
pour appeler les supermarchés exacts à retirer.
Pour raccourcir la durée d'exécution, nous préférons utiliser la sélection de l'instruction précédente à la ligne 3 - c'est exactement là où se trouvent les supermarchés dans la zone de délimitation.
Ceci se fait au moyen de la _filtre_ ``._``.
Il limite la sélection à de tels résultats,
qui sont dans l'entrée au début de l'instruction.
Depuis que nous avons utilisé l'entrée standard ici,
nous les appelons par leur nom ``._`` (trait de soulignement simple).

Le déroulement du processus avec le flux de données en détail:

* Avant le début de l'exécution, toutes les sélections sont vides.
* La ligne 1 est exécutée en premier.
  En raison de ``->.all_stations``, toutes les stations sont alors sélectionnées dans ``.all_stations``;
  la sélection standard, en revanche, reste vide.
* Les lignes 2 à 5 sont une instruction de type _difference_,
  et cette première exécute son bloc d'instruction.
  Par conséquent, la ligne 3 suivante est ``nwr[shop=supermarket]({{bbox}})``.
  La ligne 3 n'a pas de redirection,
  pour que tous les supermarchés soient ensuite sélectionnés dans la sélection standard.
  La sélection ``all_stations`` n'est pas mentionnée et est donc conservée.
* L'instruction de bloc _difference_ stocke le résultat de son premier opérande,
  de la ligne 3.
* Ligne 4 utilise la sélection standard via ``._`` comme restriction pour son résultat,
  et en plus la sélection ``all_stations`` est utilisée comme source pour la recherche _around_ via ``(around.all_stations:300)``.
  Le résultat est la nouvelle sélection standard et remplace donc la sélection standard précédente.
  La sélection ``all_stations`` reste inchangée.
* L'instruction de bloc _difference_ stocke le résultat de son deuxième opérande,
  de la ligne 4.
* L'instruction de bloc _difference_ forme maintenant la différence entre les deux résultats tapés.
  Comme rien d'autre n'est nécessaire, le résultat devient la nouvelle sélection par défaut.
  La sélection ``all_stations`` reste inchangée.
* Enfin, la ligne 5 est exécutée.
  Sans spécification spéciale, ``out`` utilise la sélection par défaut comme source.

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
