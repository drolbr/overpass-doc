Mutualisation
=============

Il y a des instances publiques qui mettent à disposition toutes leurs ressources,
mais aussi qui veillent à se protéger de leur surexploitation.
Les gros utilisateurs doivent pouvoir facilement mettre en place leur propre instance.

<a name="magnitudes"/>
## Ordres de grandeur

L'objectif des serveurs publics est de
d'être à la disposition du plus grand nombre d'utilisateurs possible.
La puissance de calcul des serveurs doit être répartie entre les quelque 30 000 utilisateurs par jour.

La durée d'exécution d'une requête typique est inférieure à 1 seconde,
cependant, il y a aussi des demandes en cours d'exécution beaucoup plus longues.
Chaque serveur de l'API Overpass peut répondre à environ 1 million de requêtes par jour,
et deux serveurs sont exploités dans [overpass-api.de](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances).

Il est pratiquement impossible que vous ayez des problèmes avec les requêtes déclenchées manuellement.
Malheureusement, les ressources limitées peuvent encore vous affecter dans des cas isolés.
L'algorithme ne peut pas fonctionner parfaitement.

Voici des exemples de comportements problématiques :

1. exécuter exactement la même requête (à la même adresse) des dizaines de milliers de fois par jour
2. demander des millions pour un seul élément par identifiant
3. d'attacher entre elles des rectangles englobants afin de télécharger l'ensemble des données du monde entier
4. créer une appli pour plus que tous les mappeurs OSM
   et de s'appuyer sur les serveurs publics en tant qu'arrière-guichet

Dans le premier cas, le script de requête doit être réparé,
dans les cas 2 et 3, il convient d'utiliser un [dump planète](https://wiki.openstreetmap.org/wiki/Planet.osm) à la place de l'API Overpass.
Dans le quatrième cas, une instance séparée est le meilleur choix;
pour les instructions d'installation, voir [là](../more_info/setup.md).

En fait, la plupart des utilisateurs ne posent que quelques requêtes à la fois.
La limitation automatique de la charge est donc conçue pour cela,
préfèrent les premières quelques requêtes par utilisateur aux requêtes de masse des utilisateurs intensifs.
Une limitation manuelle de la charge sera donc d'abord orientée vers les utilisateurs les plus intensifs,
et les estimations suivantes de l'utilisation maximale gardent une distance de sécurité par rapport à leur intensité d'utilisation.

Les instances publiques peuvent généralement être utilisées pour traiter un volume de requêtes,
que ni 10000 requêtes par jour ni 1 Go de volume de téléchargement par jour ne dépassent.

L'un des objectifs est toutefois de rendre le fonctionnement de votre propre instance aussi simple que possible.
Ceux qui estiment que leurs besoins sont supérieurs aux limites d'utilisation ci-dessus,
alors veuillez lire les [instructions d'installation](../more_info/setup.md).

Pour en savoir plus sur la limitation automatique de la charge,
veuillez lire le paragraphe suivant.

<a name="quotas"/>
## Règles

La limitation automatique de la charge assigne des requêtes aux utilisateurs (anonymes)
et assure l'accessibilité pour des utilisateurs rationnants,
si le volume de requêtes de tous les utilisateurs dépasse la capacité du serveur.

Il existe actuellement deux instances publiques indépendantes,
[z.overpass-api.de](https://z.overpass-api.de/api/status) et [lz4.overpass-api.de](https://lz4.overpass-api.de/api/status).
Nous commençons par l'explication de ces questions d'état.

### Nombre de requêtes

L'attribution aux utilisateurs se fait généralement par adresse IP.
Si une clé utilisateur est définie, elle est utilisée en priorité.
Pour les adresses IPv4, l'adresse IP complète est évaluée ;
pour les adresses IPv6, les 64 bits supérieurs de l'adresse IP.
Pour les adresses IPv6, ce n'est pas encore clair,
quelles sont les habitudes qui prévalent,
de sorte qu'une réduction à moins de bits est réservée.
Le numéro d'utilisateur déterminé par le serveur se trouve sur la première ligne de la [requête d'état](https://overpass-api.de/api/status) après ``Connected as:``.

Chaque exécution d'une requête occupe un emplacement du utilisateur,
pour le temps d'exécution de la requête plus un temps de sérénité.
Le but du temps de sérénité est,
donner aux autres utilisateurs la possibilité de poser leur requêtes.
Le temps de sérénité augmente avec la charge du serveur et proportionnel au temps d'exécution.
À faible charge, le temps de sérénité n'est qu'une fraction du temps d'exécution,
mais à une charge de travail élevée, même plusieurs fois.

Une carte glissante enverrait maintenant de nombreuses requêtes à court terme en peu de temps.
Pour qu'un utilisateur puisse obtenir une réponse à toutes ces requêtes,
il existe deux mécanismes de bonne volonté:

* Il y a généralement plusieurs emplacements.
  Le nombre de slots se trouve à la troisième ligne après ``Rate limit:``.
* Les requêtes restent ouvertes sur le serveur jusqu'à 15 secondes,
  s'ils n'ont pas encore d'emplacement.

Si une telle carte glissante nécessite par exemple 20 requêtes pour 1 seconde d'exécution,
le nombre d'emplacements est égal à 2
et le rapport entre la durée de la requête et le temps de décompte est de 1:1,
alors

* les deux premières requêtes sont traitées immédiatement
* les deux requêtes suivantes sont reçues
  et exécuté après 2 secondes (1 seconde de temps d'exécution plus 1 seconde de temps de stabilisation)
* les autres requêtes sont exécutées ultérieurement en conséquence
* les requêtes 15 et 16 sont exécutées après 14 secondes chacune
* les requêtes 17 à 20 sont renvoyées après 15 secondes,
  parce qu'ils n'ont pas d'emplacement d'ici là.

Si l'utilisateur a encore besoin du contenu des requêtes 17 à 20,
(et n'a pas déjà défilé)
alors le framework client doit réinitialiser les requêtes 17 à 20 après que les 15 secondes se soient écoulées.
Il y a une implémentation de référence dans la section [OpenLayers et Leaflet](../targets/index.md).

La raison de ce mécanisme sont les scripts en boucle sans fin:
beaucoup exécutent une requête en parallèle et sont ensuite retardées de manière sensée,
au fur et à mesure que leurs requêtes reçoivent des réponses retardées en conséquence.

Si des interrogations de longue durée, de l'ordre de quelques minutes, ont occupé l'emplacement,
la requête d'état de la ligne 6 fournit des informations à ce sujet,
quand quel slot est à nouveau disponible.

Les demandes rejetées en raison de la limite de débit reçoivent une réponse avec le [code d'état HTTP 429](https://tools.ietf.org/html/rfc6585#section-4).

### Durée et taille maximales

Indépendamment de cette limite de taux, il existe un deuxième mécanisme;
il préfère les petites requêtes aux grandes requêtes,
afin que de nombreux utilisateurs puissent encore être servis avec de petites requêtes,
lorsque la capacité des utilisateurs ayant les requêtes les plus grandes n'est plus suffisante.

Il y a deux critères pour cela, par durée d'exécution et par exigence de mémoire.
Chaque requête contient une déclaration de sa durée d'exécution maximale prévue et de ses besoins en mémoire maximale prévus.
La déclaration de la durée d'exécution maximale peut se faire explicitement par un ``[timeout :...]`` précédent la requête;
la déclaration du besoin maximal en mémoire par un préfixe ``[maxsize :...]``.
Les deux peuvent être combinés.

Si aucun temps d'exécution maximum n'est déclaré pour une requête,
un temps d'exécution maximale de 180 secondes est réglée.
La valeur par défaut de la mémoire maximale requise est 536870912;
ce qui correspond à 512 Mo.

Si une requête dépasse sa durée d'exécution maximale déclarée ou son besoin de mémoire maximale déclarée,
il sera annulé par le serveur.
Cet [exemple](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=10&Q=%5Btimeout%3A3%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) s'interrompt au bout de 3 secondes:

    [timeout:3];
    nwr[shop=supermarket]({{bbox}});
    out center;

Le même exemple fonctionne bien [avec plus de temps](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=10&Q=%5Btimeout%3A3%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B):

    [timeout:90];
    nwr[shop=supermarket]({{bbox}});
    out center;

Le serveur permet maintenant une requête exactement,
si, selon les deux critères, elle n'occupe pas plus de la moitié des ressources encore disponibles.
Pour la mémoire maximale requise, la valeur est, par exemple, de 12 Go.
Donc si 8 requêtes déjà tournent à 512 Mo,
4 GiB sont occupés.
Une autre requête serait autorisée exactement,
si elle demande moins de 4 Go.
Avec cette neuvième requête ensemble, 4 Go seraient encore libres,
de sorte qu'une seule requête de moins de 2 Go soit acceptée.

Il se comporte similairement avec le temps de fonctionnement.
La valeur totale habituelle pour les unités de temps autorisées est 262144 secondes.
Ainsi, une requête d'une durée maximale de 1 jour est tout à fait commodément autorisée,
mais toute autre requête parallèle avec une durée d'exécution maximale aussi longue est alors rejetée.
Le mécanisme de la limite de débit assure ensuite ceci avec un temps de décompte subséquent dans l'ordre des jours,
que ce n'est pas toujours le même utilisateur qui bénéficie d'une durée d'exécution maximale aussi longue.

La charge du point de vue du serveur est affichée par Munin,
[ici](https://z.overpass-api.de/munin/localdomain/localhost.localdomain/index.html#other) et [ici](https://lz4.overpass-api.de/munin/localdomain/localhost.localdomain/index.html#other).

Comme pour la limite de débit, le serveur ne rejette pas immédiatement les requêtes trop volumineuses,
mais attend 15 secondes,
si un nombre suffisant d'autres requêtes n'ont pas été traitées entre-temps.

Les requêtes rejetées en raison d'un manque de ressources reçoivent une réponse avec le [code d'état HTTP 504](https://tools.ietf.org/html/rfc7231#section-6.6.5).

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
