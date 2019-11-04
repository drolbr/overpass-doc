Requêter par surface
====================

Toutes donées dans un region nommé comme un ville ou un département.

<a name="deprecation"/>
## Avertissement au futur

Le contenu de ce manuel est revendiqué comme suit,
qu'elles s'appliqueront encore dans de nombreuses années à venir.
Cela ne s'applique pas nécessairement au concept actuel de _surfaces_:
Le type de données a été créé pour rester compatible,
si un type de données pour les surfaces est ajouté au modèle de données OpenStreetMap.
En attendant, je suis sûr que ça n'arrivera plus.

C'est pourquoi je planifie maintenant,
d'offrir des surfaces directement à partir des types établis _chemin fermé_ et _relation_.
La planification et la mise en œuvre concrètes prendront certainement des années.
Cependant, à la fin de ce processus, certaines des variantes syntaxiques énumérées ici seront probablement dépassées.
Dans le cadre de la [rétrocompatibilité](../preface/assertions.md#infrastructure), aussi peu de requêtes que possible seront déclarées obsolètes.

Actuellement, c'est l'intention,
que _area_ est alors utilisé comme synonyme de _chemin_ plus _relation_ plus un évaluateur `is\_closed()`.
Inversement, `is\_in` trouvera probablement ces types de données;
il sera logique de remplacer cette _instruction_ par un filtre.

Inversement, je vous demande de ne pas vous méprendre sur le fait qu'il s'agit d'une annonce concrète.
Il y a d'autres préoccupations dans le projet avec une plus grande pression de souffrance.

<a name="per_tag"/>
## Par nom ou par attribut

L'application typique pour les surfaces dans l'API Overpass est,
télécharger tous les objets d'un même type ou tous les objets en général dans une même zone.
Nous commençons avec tous les objets d'un type modérément commun;
tous les objets en général sont trop de données,
pour s'entraîner avec des temps de réaction courts.
Lorsque le mécanisme des surfaces est introduit dans cette section,
le téléchargement de tous les objets de la [section suivante](#full) suit.

Tout d'abord, nous voulons afficher [tous les supermarchés de Londres](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB):

    area[name="London"];
    nwr[shop=supermarket](area);
    out center;

Le travail proprement dit est effectué à la ligne 2:
là le _filtre_ `(area)` restreint les objets à sélectionner
à un tel seulement dans les surfaces de l'ensemble `_`;
donc on a déjà dû apporter la surface à Londres.

La ligne 1 sélectionne tous les objets du type _area_,
qui ont un attribut avec la clé `name` et la valeur `London`.
Ce type d'objet est expliqué [ci-dessous](#background).
C'est aussi une [instruction query](../preface/design.md#statements) spéciale.

Étonnamment, les sites sont répartis sur la moitié de la planète.
Il y a de nombreux quartiers appelés `London`;
nous devons dire que nous sommes intéressés par le grand Londres en Angleterre.
Nous disposons de cinq solutions différentes,
pour clarifier notre demande.

Nous pouvons [placer et utiliser](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB) un grand rectangle englobant autour de la région cible approximative:

    area[name="London"];
    nwr[shop=supermarket](area)(50.5,-1,52.5,1);
    out center;

Pour votre commodité, veuillez noter que cela [fonctionne](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB) également avec [la fonction de confort](../targets/turbo.md#convenience) de _Overpass Turbo_:

    area[name="London"];
    nwr[shop=supermarket](area)({{bbox}});
    out center;

Dans les deux cas, le rectangle englobant est un filtre parallèle à `(area)`.
Un rectangle englobant n'a jamais été implémentée pour la solution temporaire _area_,
et c'est aussi parce que c'est suffisant,
appliquer le filtre une instruction plus tard.

De même, nous pouvons profiter du fait que Londres est située au Royaume-Uni.
Une [section ultérieure](#combining) montre toutes les possibilités.

Enfin, vous pouvez utiliser d'autres attributs pour distinguer des surfaces avec le même attribut _name_.
Dans le cas de Londres [l'attribut](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB) avec la clé _wikipedia_ aide:

    area[name="London"]["wikipedia"="en:London"];
    nwr[shop=supermarket](area);
    out center;

Comme déjà le premier filtre par attribut `[name="London"]`
le second filtre `["wikipedia"="en:London"]` est également appliqué à l'instruction _area_ de la ligne 1.
Il ne reste donc cette fois qu'un seul objet _area_,
où nous voulons vraiment chercher.

D'autres filtres fréquemment utilisés peuvent être `admin_level` avec ou sans valeur ou `type=boundary`.
Il aide à [afficher](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB) d'abord tous les objets _area_ trouvés;
veuillez passer à la vue des données dans le coin supérieur droit après avoir exécuté _Données_ :

    area[name="London"];
    out;

La ligne 2 affiche ce que la ligne 1 trouve.
Veuillez regarder les résultats pour voir quels _attributs_ sélectionner la bonne zone.
En utilisant les filtres _pivot_ dans une requête, vous pouvez aussi les [visualiser](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB):

    area[name="London"];
    nwr(pivot);
    out geom;

La ligne 2 contient une instruction _query_ régulière.
Le _filtre_ `(pivot)` dans lui permet exactement ces objets,
qui sont les créateurs des surfaces dans son entrée.
C'est l'ensemble `_`;
il a été rempli à la ligne 1.

La cinquième possibilité est une caractéristique de confort de [Overpass Turbo](../targets/turbo.md),
pour laisser Nominatim [sélectionner](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB):

    {{geocodeArea:London}};
    nwr[shop=supermarket](area);
    out center;

Ainsi, l'expression `{{geocodeArea:London}}` déclenche,
que _Overpass Turbo_ demande à _Nominatim_ quel est l'objet le plus plausible pour `London`.
Utilisant l'identifiant retourné par Nominatim,
Overpass Turbo remplace l'expression par une instruction cherchant par identifiant après la zone correspondante,
ici par exemple `area(3600065606)`.

<a name="full"/>
## Véritablement tous

Nous voulons maintenant télécharger vraiment toutes les données dans un lieu.
Cela fonctionne presque avec la requête que nous avons utilisée [pour nous entraîner](#per_tag).
Mais nous devons changer l'outil:
pour une zone de la taille de Londres, 10 millions d'objets ou plus se rassemblent rapidement,
tandis que _Overpass Turbo_ ralentit déjà le navigateur à partir d'environ 2000 objets à l'inutilité.

De plus, vous êtes mieux servi avec des extraits régionaux dans presque toutes les régions à l'intérieur des frontières officielles, des états aux villes.
Détails [dans la section correspondante](other_sources.md#regional).

Vous pouvez télécharger les données brutes directement sur votre ordinateur local pour traitement ultérieur :
Ceci est fait dans _Overpass Turbo_ sous _Export_ dans le coin supérieur gauche du lien `données brutes depuis l'API Overpass`.
Il est normal que rien ne se passe après le clic.
Le téléchargement de Londres peut prendre plusieurs minutes.

Vous pouvez également utiliser des outils de téléchargement comme [Wget](https://www.gnu.org/software/wget/) ou [Curl](https://curl.haxx.se/).
Pour cela, enregistrez l'une des requêtes ci-dessus dans un fichier local, par exemple `london.ql`.

Vous pouvez ensuite effectuer des requêtes à partir de la ligne de commande en utilisant
<!-- NO_QL_LINK -->

    wget -O london.osm.gz --header='Accept-Encoding: gzip, deflate' \\
        --post-file=london.ql 'https://overpass-api.de/api/interpreter'

resp.
<!-- NO_QL_LINK -->

    curl -H'Accept-Encoding: gzip, deflate' -d@- \\
        'https://overpass-api.de/api/interpreter' \\
        <london.ql >london.osm.gz

Bien entendu, les deux commandes peuvent également être écrites en une seule ligne sans barre oblique inversée.
Dans les deux cas, vous me rendez un grand service, ainsi qu'à vous-même et à tous les autres utilisateurs,
si vous définissez l'en-tête supplémentaire `Accept-Encoding : gzip, deflate`.
Cela permet au serveur de compresser les données,
qui réduit la quantité de données d'un facteur 7
et soulage les deux extrémités de la connexion.

Nous en arrivons maintenant à la requête proprement dite.
Puisqu'une source de grandes quantités de données avec des données complètes sont des relations spatialement étendues,
est disponible pour l'application finale [variantes adaptées](osm_types.md).
Nous nous limitons d'abord ici à une variante souvent adaptée:
<!-- NO_QL_LINK -->

    area[name="London"]["wikipedia"="en:London"];
    (
      nwr(area);
      node(w);
    );
    out;

Alternativement, il existe une variante avec utilisation multiple du filtre _area_.
Ensuite, les zones sélectionnées en entrée doivent être [mises en cache](../preface/design.md#sets) dans une _variable d'ensemble nommée_:
<!-- NO_QL_LINK -->

    area[name="London"]["wikipedia"="en:London"]->.surface_de_recherche;
    (
      node(area.surface_de_recherche);
      way(area.surface_de_recherche);
      node(w);
    );
    out;

Dans la ligne 3, l'instruction de requête écrit son résultat dans la sélection standard.
Puisque la sélection _area_ est encore nécessaire comme entrée à la ligne 4,
il doit être situé à un endroit autre que la sélection par défaut.

<a name="combining"/>
## Surface dans surface

Nous reviendrons sur le problème
de sélectionner Londres comme surface en Grande-Bretagne.
Ceci n'est pas mis en œuvre,
mais il y a deux autres possibilités ici aussi.

Vous pouvez rechercher des objets qui se trouvent [à l'intersection de deux surfaces](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=8&Q=CGI_STUB):

    area[name="London"]->.petit;
    area[name="England"]->.grand;
    nwr[shop=supermarket](area.petit)(area.grand);
    out center;

Le filtrage proprement dit a lieu dans l'instruction _query_ de la ligne 3;
Seuls les objets qui remplissent les trois filtres sont autorisés:
Le filtre `[shop=supermarket]` n'autorise que les objets avec le tag correspondant.
Le filtre `(area.petit)` restreint cela aux objets,
qui se trouvent à l'intérieur d'une des surfaces de l'ensemble nommé `petit`.
Le filtre `(area.grand)` réduit encore ce résultat aux objets,
qui se trouvent dans l'une des surfaces de l'ensemble nommé `grand`.

Maintenant, nous devons juste nous en assurer,
qu'en `petit` et en `grand` les surfaces prévues y sont.
Ils font des instructions après le mot clé _area_ dans les lignes 1 et 2,
qui stockent leur résultat chaque dans une variable nommée.

L'autre procédure utilise la connexion entre _area_ et l'objet générateur,
mais cette fois dans la direction opposée au filtre _pivot_.
Nous [sélectionnons](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=8&Q=CGI_STUB) l'objet créé de la petite zone:

    area[name="England"];
    rel[name="London"](area);
    map_to_area;
    nwr[shop=supermarket](area);
    out center;

Dans la ligne 4, nous voulons avoir exactement la _surface_ de Londres comme entrée pour le filtre `(area)`.
Dans la ligne 2, nous sélectionnons tous les _relations_ avec le nom _London_
et situées dans une des surfaces,
qui trouve `(area)` dans l'ensemble défaut `_`.
Pour cela, nous avions sélectionné toutes les zones portant le nom `England` à la ligne 1.

Mais nous avons besoin de surfaces dans la ligne 4,
alors que le filtre `(area)` ne peut pas filtrer que les surfaces et nous avons sélectionné _relations_.
Ceci est fait par `map_to_area`:
il sélectionne les surfaces créées par les objets aux objets à partir de son entrée.

<a name="background"/>
## Contexte technique

...
<!--
Bereits am Anfang des Overpass-Projekts im Jahr 2009 sollte es die Möglichkeit geben,
ein geometrisches A-liegt-in-B nutzen zu können.
Das hat sich nur denkbar schlecht mit der Anforderung vertragen,
[OpenStreetMap-Daten treu abzubilden](../preface/assertions.md#faithful):
Flächen sind in OpenStreetMap ein gemischtes Konzept aus Geometrie und Tags,
es gab glaubwürdige Bestrebungen, einen eigenen Datentyp _Area_ zu entwickeln,
und die Regeln dafür, wann genau ein OpenStreetMap-Objekt eine Fläche ist, sind damals noch im Fluss gewesen.
Zuletzt gab es den Eindruck, dass Flächen leicht beschädigt werden könnten und dies häufiger zu erwarten ist.

Daher sind _Areas_ in Overpass API ein eigener Datentyp.
Der Server erzeugt diese in einem zyklischen Hintergrundprozess nach einem vom Code getrennten [Regelsatz](https://github.com/drolbr/Overpass-API/tree/master/src/rules).
Damit haben es potentielle Betreiber eigener Instanzen einfacher,
selbst zu entscheiden, welche Flächen sie erzeugen wollen.
Jede _Area_ übernimmt dabei bei ihrer Erzeugung die Tags des Objektes, aus dem sie erzeugt worden ist.

Dies zieht Folgen nach sich:

* Flächen stehen erst viele Stunden später zu Verfügung als ihre erzeugenden Objekte.
  Entsprechend wirken sich auch Änderungen an den erzeugenden Objekten verzögert aus.
* Ergibt ein erzeugendes Objekt keine gültige Fläche mehr,
  so bleibt das alte _Area_-Objekt bestehen, bis wieder eine neue gültige Fläche erzeugt werden kann.
* Areas haben eigene Regeln, nach denen ihre Ids vergeben werden.
* Nur ein Teil der Filter für OpenStreetMap-Objekte steht auch für _Areas_ zur Verfügung.

Der große Vorteil ist aber, dass die Suche Punkt-in-Fläche effizient und zuverlässig funktioniert.

Als Nachteil hat sich herausgestellt, dass nicht alle nachgefragten _Area_-Objekte existieren:
mittlerweile wird fast jedes Objekt in OpenStreetMap, das von seiner Geometrie her eine Fläche ergibt,
auch als Fläche genutzt.
Wenn aber gemäßg den Tagging-Regeln der Hintergrundprozess das Objekt nicht für eine Fläche hält,
gibt es kein korrespondierendes _Area_-Objekt.

Umgekehrt ist mir in den letzten 10 Jahren keine Instanz begegnet,
die ihre Flächen-Regelwerk an ihre speziellen Bedürfnisse angepasst hat.
Es gab wohl eher einen Tradeoff, weniger Flächen zu akzeptieren,
um Rechenzeit beim Hintergrundprozess zu sparen.
Damit ist der Regelsatz doch de facto zentral festgelegt,
und dies beraubt ihn der meisten seiner Vorteile.

Daher beabsichtige ich mittlerweile,
auch die Flächenoperationen direkt auf den OpenStreetMap-Objekten auszuführen.
-->
