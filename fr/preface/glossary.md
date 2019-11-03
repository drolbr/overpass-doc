Glossaire
=========

Il explique de nombreux mots-clés pour OpenStreetMap et pour l'API Overpass.

### Attribut

Un _attribut_ est une structure de données dans OpenStreetMap et Overpass API pour stocker des données factuelles.
Chaque _attribut_ se compose d'une _clé_ et d'une _valeur_
et fait partie d'un objet, c'est-à-dire nœud, chemin, relation ou élément dérivé.

### Chemin

Un _chemin_ est un type spécifique d'objet dans le modèle de données d'OpenStreetMap.
Il représente une ligne polygonale.
Si c'est une ligne polygonale fermée,
il peut aussi s'agir d'une surface.

### Clé

Un _clé_ est partie d'un _tag_,
il est la chaîne de caractères à laquelle une _valeur_ est affectée.

### Élément dérivé

Un type spécifique d'objet dans les données de l'API Overpass.
Contrairement aux _nœuds_, _chemins_ et _relations_, les dérivés ne proviennent pas des données OpenStreetMap,
mais sont générés au moment de l'exécution.
Ils permettent de réécrire des attributs ou de simplifier des géométries.

### Ensemble

Voir variable

### Évaluation

Il s'agit d'un des blocs possibles d'une requête.
Un _évaluation_ est evalué dans le contexte d'une instruction, d'une instruction de bloc ou du filtre spécial _if_.
Selon son type, il agit soit sur tous les objets sélectionnés par une _variable d'ensemble_, soit sur chaque objet individuellement.
Selon son type, il retourne un nombre, une chaîne de caractères ou une géométrie.

### Filtre

Il s'agit d'un des blocs possibles d'une requête.
Les _filtres_ sont toujours des composants d'une instruction _query_ et filtrent les objets qui doivent y être sélectionnés.
Ils agissent toujours ensemble par AND.
Cela signifie que le système trouve toujours exactement les objets qui remplissent tous les _filtres_ de l'instruction _query_ correspondante.

### Instruction

Il s'agit d'un des blocs possibles d'une requête.
Les _instructions_ sont les parties qui peuvent être exécutées indépendamment.
Une autre distinction est faite entre des _instructions de bloc_ (voir ci-dessus) et les _instructions simples_.
Les deux instructions les plus importantes sont _query_ pour sélectionner les objets d'OpenStreetMap
et _print_ pour ajouter les objets OpenStreetMap sélectionnés à la réponse.

### Nœud

Un type d'objet spécifique dans le modèle de données d'OpenStreetMap.
Représente une coordonnée unique.
Ayant des attributs, c'est un objet délimitable,
sans attributs n'est normalement qu'une partie d'un _chemin_,
pour lui fournir des coordonnées.

### Rectangle englobant

Une _rectangle englobant_ est décrite par deux spécifications de longitude et deux spécifications de latitude.
Il se compose de toutes les coordonnées,
dont la latitude se situe entre les deux valeurs de latitude
et dont la longitude se situe entre les deux spécifications de longitude.

### Relation

Un type d'objet spécifique dans le modèle de données d'OpenStreetMap.
Modélise des choses,
qui ne peut pas être modélisé avec des noeuds et des moyens seuls.

### Requête

Le texte formalisé,
qui est envoyé du client (par exemple de _Overpass Turbo_) au serveur.
Seul le contenu de la requête décide,
qui est récupéré à partir de l'OpenStreetMap.

### Surface

Un type spécial _objet_ dans les données de l'API Overpass.
Contrairement aux _nœuds_, _chemins_ et _relations_, les surfaces ne proviennent pas directement des données OpenStreetMap,
mais sont générés par l'API Overpass.
C'est une solution de contournement parce que les _surfaces_ sont utilisées comme un concept dans OpenStreetMap,
mais il n'y a pas de type de données spécial pour cela.

### Valeur

Partie d'un _tag_,
est la chaîne de caractères affectée à la _clé_.

### Variable

Une variable dans l'API Overpass est toujours une _variable d'ensemble_.
Les _variable d'ensemble_ sont utilisées,
pour pouvoir passer des sélections d'objets d'une instruction à l'autre pendant l'exécution.

<!-- Traduit avec www.DeepL.com/Translator, partiellement redigé -->
