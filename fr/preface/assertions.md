Principes
=========

L'API Overpass ne fera ni la promotion ni n'interférera avec les schémas d'attribution.
La rétrocompatibilité est prévue pour des décennies.

<a name="local"/>
## Localement rapide

L'API Overpass est conçue à cette fin,
pour fournir rapidement des données liées à l'espace.
L'API Overpass peut également fournir des données à distance,
mais n'a aucun avantage sur une base de données générique.

De nombreuses sections de ce manuel se réfèrent donc aux outils,
qui sont plus fortement optimisés en fonction de l'application respective.

<a name="faithful"/>
## Fidèle au modèle de données

Le modèle de données OpenStreetMap a contribué de manière significative au succès d'OpenStreetMap par sa simplicité.
Mais il doit être traduit en un modèle de données différent pour presque toutes les applications,
sinon les délais de traitement seront trop longs.
C'est particulièrement vrai pour le rendu d'une carte et encore plus pour le routage et la recherche de points d'intérêt.

Aucune de ces conversions n'est sans perte,
chaque modèle de données subséquent met l'accent sur certains aspects, ignore d'autres aspects et interprète le reste de la meilleure façon possible.
Ainsi, une modélisation du mappeur qui est aussi précise que possible sur la carte,
lors du routage, de la recherche de points d'intérêt ou d'autres cas d'utilisation conduit souvent à des résultats inattendus.

En réponse, les cartographes utilisent souvent une modélisation inexacte des faits,
mais qui donnent de plus beaux résultats dans l'outil préféré.
Que les résultats dans d'autres outils sont pires,
le cartographe ne s'en rend généralement pas compte.
Cette pratique est notoire sous l'idiome [Taguer pour le rendu](https://wiki.openstreetmap.org/wiki/FR:Tagging_for_the_renderer).

Le problème est
que la modélisation non-factuelle est ensuite récompensée par une belle image cartographique
et la modélisation factuelle est punie par une mauvaise image de la carte.
Il est difficile pour l'utlisateur de justifier sa décision à des tiers,
pourquoi il fait de la modélisation factuelle.

Par conséquent, l'API Overpass fonctionne sur le modèle de données d'origine:
C'est exactement la tâche de l'API Overpass d'afficher les données telles qu'elles sont modélisées dans OpenStreetMap.

Cela déplace les poids:
Les modèles factuellement incorrects peuvent alors également être présentés comme tels.
Et pour les modèles qui sont fidèles aux faits, au moins le contexte général peut être montré.

<a name="tags"/>
## Neutre avec les attributs

C'est dans la nature de l'homme que le phénomène inverse apparaît rapidement:
Des prophètes de leurs enseignements supposés purs apparaissent.

Les polygones multiples en sont un exemple:
Les problèmes à résoudre sont,
d'une part pour modéliser des surfaces avec des trous,
d'autre part pour modéliser logiquement et effectivement les surfaces adjacentes.
Par exemple, les États remplissent la totalité de la masse terrestre, c'est-à-dire que les frontières terrestres appartiennent toujours à plusieurs États.
Toutefois, cela n'est possible plus avec des chemins fermées.

La convention est restée du cas d'utilisation _trous_,
pour laisser les attributs pertinentes dans le chemin de clôture.
À l'époque, c'était en grande partie à cause de cela,
que le moteur rendu avait des difficultés avec les relations.
En même temps, certains utilisateurs ont des difficultés avec certaines particularités,
ce qui a été un sujet sous le titre _anneaux intérieurs touchants_.

En résumé, les relations multipolygones ont été un sujet constant;
leur traitement nécessite encore aujourd'hui une bonne connaissance.

Certains cartographes ont mal compris cela,
que les relations sont l'objet le plus digne
et converti de simples chemins fermés en multipolygones.
Mais cela n'a aucun avantage,
mais complique simplement le traitement et gonfle la base de données.

Cependant, il y a encore beaucoup d'opinions controversées:

* Les sentiers pédestres menant le long des routes peuvent être modélisés comme des chemins séparés,
  soit être représenté par un ensemble complexe de règles utilisant des attributs,
  soit on limite les sentiers implicites à des cas d'interprétation évidente.
* Dans les rues, toutes les parties de la rue peuvent avoir un nom.
  Vous pouvez également limiter le nom à une voie du moyen de transport le plus rapide par direction.
* Dans les bâtiments avec magasins, le magasin peut être le même objet que le bâtiment
  ou un seul _nœud_ dans le bâtiment.
  L'adresse peut alors être mappée à l'un des deux objets ou aux deux.

Créer un outil pleinement accepté,
je reste en dehors de tels désaccords.

L'API Overpass est donc strictement neutre en ce qui concerne l'attribution,
c'est-à-dire qu'aucun attribut ne bénéficie d'un traitement spécial.

<a name="antiwar"/>
## Invulnérabilité

Un autre problème dans ce contexte est l'effort
de modifier les données automatiquement.
Aussi évidente que soit l'idée, elle entraîne de [nombreux problèmes](https://2016.stateofthemap.org/2016/staying-on-the-right-side-best-practices-in-editing/).

Par conséquent, l'API Overpass ne permit pas,
réécrire les objets OpenStreetMap au moment de l'exécution.
Pour le besoin indubitablement et aussi tout à fait justifié existant,
pour obtenir des objets réécrits,
la classe des _éléments dérivées_ a été introduite.
Ceux-ci sont suffisamment différents des objets OpenStreetMap,
qu'on ne peut pas leur re-télécharger directement.

L'API Overpass peut toujours être utile pour les éditions avec différents niveaux d'automatisation.
Des exemples peuvent être trouvés dans la section [JOSM](../targets/index.md).

<a name="ql"/>
## Langage multifonctionnel

Les géodonnées apportent avec elles leur propre critère d'ordre avec le concept de _proximité spatiale_.
Ils n'entrent donc dans aucune des catégories,
qui sont déjà couverts par les langages de requête standard.
Par conséquent, il existe un langage de requête qui lui est propre.

Le langage de requête n'est donc pas seulement orienté vers la proximité spatiale,
mais peut également tenir pleinement compte des particularités du modèle de données OpenStreetMap.
En outre, il y a l'exigence,
que les requêtes sur un serveur partagé public doivent se comporter raisonnablement,
c'est-à-dire que ni aucun surfaces d'attaque significantes pour les failles de sécurité ni les problèmes de performance ne doivent offrir.

Il s'est avéré
que la communauté OpenStreetMap a également besoin de recherches complexes.
Celles-ci devraient être servies,
en rendant le langage aussi logiquement rigide et orthogonal que possible,
de sorte que presque tout peut être combiné avec tout.

<a name="infrastructure"/>
## Infrastructure

L'API Overpass est conçue comme une infrastructure.
En particulier, il ne s'agit pas d'un logiciel d'utilisateur final ou d'un prototype.

Décisions concernant les interfaces,
en particulier le langage de requête,
et sur les dépendances utilisées dureront probablement des décennies.
Il y a donc des innovations assez prudemment et seulement,
si une forme de soutien à long terme a été trouvée.

Etre une infrastructure accessible via Toile, c'est aussi
de maintenir un comportement de charge raisonnable, même avec des échantillons d'requête déraisonnables.
Plus d'informations à ce sujet dans la [prochaine section](commons.md#magnitudes).

<a name="libre"/>
## Libre

L'API Overpass peut être mesurée par rapport aux [quatre libertés essentielles](https://www.gnu.org/philosophy/free-sw.fr.html) de l'Open Source.

### Fonctionner, redistribuer

Ce n'est pas suffisant,
à offrir aux instances publiques,
car ils ont inévitablement une capacité finie.

Seulement avec la publication du [code source](https://github.com/drolbr/Overpass-API) sous une forme,
ce qui facilite [l'installation de vos propres instances](https://dev.overpass-api.de/no_frills.html),
les libertés sont préservées.
Cela inclut,
de mesurer ainsi les besoins en ressources du logiciel,
que le matériel approprié est facile à trouver.

### Étudier, modifier

Le [code source](https://github.com/drolbr/Overpass-API) est ici essentiel.
La [licence](https://github.com/drolbr/Overpass-API/blob/master/COPYING) le garantit également légalement.

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
