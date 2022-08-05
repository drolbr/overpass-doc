Exploiter un Serveur Propre
===========================

Comment puis-je mettre en place ma propre instance,
pour pouvoir exécuter autant de requêtes que convient?

Un guide [bref](https://overpass-api.de/no_frills.html) et un guide [détaillé](https://overpass-api.de/full_installation.html) sont disponibles en anglais.
Trois étapes sont nécessaires:

1. installer le logiciel
2. charger les données OpenStreetMap
3. configurer le service et le serveur web

Les étapes 1 et 2 sont séparées,
car le volume des données est si important,
que la plupart des utilisateurs voudront y adapter leur approche en conséquence.

Il est également possible d'installer l'API Overpass avec des [conteneurs Docker](https://github.com/drolbr/docker-overpass).

## Install les logiciels

Assurez-vous que les autotools GNU, un compilateur C++, l'utilitaire _wget_ et les bibliothèques _expat_ et _zlib_ sont installés.
Les versions de ces programmes n'ont aucune importance;
l'API Overpass n'utilise explicitement que leurs fonctions principales, indépendantes de la version.

Sous Ubuntu, par exemple, vous pouvez vous assurer que tous les programmes nécessaires sont installés:

    sudo apt-get install wget g++ make expat libexpat1-dev zlib1g-dev

Téléchargez [la dernière version](https://dev.overpass-api.de/releases/) de l'API Overpass.
Cela fonctionne également avec les anciennes versions;
mais en raison de la rétrocompatibilité, il n'y aura jamais de raison d'utiliser des versions plus anciennes.

Décompressez le fichier Gzip téléchargé et allez dans le répertoire que ça a créé.

Il est compilé et installé sur la ligne de commande avec

    ./configure
    make
    chmod 755 bin/*.sh cgi-bin/*

Nous utilisons ici une commande pour faire les fichiers exécutables dans le répertoire d'installation,
afin de ne pas avoir besoin des droits root pour accéder au répertoire système.

Normalement, un logiciel Linux serait installé à l'aide de la séquence tripartite `configure` - `make` - `make install`.
Cette dernière étape copie les fichiers exécutables dans le répertoire de programme par défaut
et rend les fichiers du système de fichiers exécutables.
Mais la copie nécessite à juste titre des droits d'accès root.
Nous laissons donc les fichiers exécutables à l'endroit où ils se trouvent,
à l'endroit où ils ont été compilés
et les rendre exécutables avec `chmod`.

Les fichiers exécutables sont en principe libres d'être déplacer dans le système de fichiers.
Certains scripts supposent cependant que les autres fichiers se trouvent dans le même répertoire qu'eux-mêmes ou dans `../bin`.
C'est pourquoi vous devriez déplacer les répertoires `cgi-bin` et `cgi-bin` complètement et ensemble.

## Télécharger les données

Contrairement à la quantité relativement faible de données pour le logiciel, les données OpenStreetMap sont très volumineuses.
Les données mondiales, même avec seulement les données géographiques les plus récentes, remplissent déjà 150 Go (état 2022).
Avec tous les anciens états de données et les métadonnées, 360 Go sont nécessaires.

Les données peuvent être copiées une à une à partir d'une base de données accessible au public et actualisée quotidiennement.
Ce processus est également appelé _clonage_:

    mkdir -p db
    bin/download_clone.sh --db-dir="db/" --meta=no \\
        --source="https://dev.overpass-api.de/api_drolbr/"

Ici `meta` contrôle le niveau de détail et donc la quantité de données:
Avec la valeur `no`, on s'en tient aux données factuelles,
`meta` charge en plus les métadonnées des agents.
Et `attic` charge aussi bien les métadonnées que tous les anciens états de données.

Les données factuelles ne sont pas relévantes du point de vue de la protection des données.
En revanche, vous pouvez charger les métadonnées et/ou les anciens états de données uniquement,
si vous avez un intérêt légitime.

Après un clonage réussi, vous pouvez déjà effectuer des requêtes via

    bin/osm3s_query --db-dir="db/"

en passant la requête sur l'entrée standard.

## Creer une Base des Donées Particulier

Si vous ne souhaitez travailler qu'avec un extrait local des données OpenStreetMap,
vous pouvez également créer vous-même une base de données à partir d'un extrait au format XML OSM.

Ces extraits sont généralement compressés.
Vous pouvez toutefois les décompresser et importer les données en une seule étape.
Dans la commande suivante, remplacez `$OSM_XML_FILE` par le nom du fichier téléchargé,
`$EXEC_DIR` par le répertoire dans lequel vous avez compilé,
et `$DB_DIR` par le répertoire dans lequel les données doivent être déposées.

En général, vous pouvez omettre `$META`.
Si vous avez un intérêt légitime qui l'emporte sur la protection des données des utilisateurs d'OSM,
vous pouvez charger les métadonnées avec `--meta` ou en plus les anciens états de données avec `--keep-attic`.

Pour un fichier compressé BZ2 :

    bunzip2 <$OSM_XML_FILE \\
        | $EXEC_DIR/bin/update_database --db-dir="$DB_DIR/" $META

Pour un fichier compressé Gzip :

    gunzip <$OSM_XML_FILE \\
        | $EXEC_DIR/bin/update_database --db-dir="$DB_DIR/" $META

L'exécution de cette commande peut prendre beaucoup de temps.
Selon la taille du fichier, le temps d'exécution peut varier entre quelques minutes et tout à fait 24 heures.

Après un import réussi, vous pouvez déjà effectuer des requêtes via

    bin/osm3s_query --db-dir="db/"

en passant la requête sur l'entrée standard.

## Configurer le Service

Pour appliquer les mises à jour, vous avez besoin de trois processus fonctionnant en permanence.

Le script `fetch_osc.sh` télécharge les mises à jour toutes les minutes,
dès qu'elles sont disponibles;
elles sont enregistrées dans un répertoire désigné.
Le script `apply_osc_to_db.sh` applique les fichiers trouvés dans ce répertoire à la base de données.

Le démon `dispatcher` s'occupe de,
que les processus d'écriture et de lecture n'interfèrent pas entre eux -
sinon un processus pourrait vouloir lire des données,
qui ont déjà été modifiées par une mise à jour à un état ultérieur.
Les processus de lecture et d'écriture communiquent avec le `dispatcher` via deux fichiers spéciaux;
une mémoire partagée avec un nom fixe aide les processus à trouver le `dispatcher`,
le socket dans le répertoire de données est exploité pour la communication.

Les commandes suivantes permettent de lancer les processus nécessaires de manière permanente;
ainsi, `$DB_DIR` doit être remplacé par le nom du répertoire de données,
et `$ID` doit être remplacé par le contenu de `$DB_DIR/replicate_id`.

    nohup bin/dispatcher --osm-base --meta --db-dir="$DB_DIR/" &
    chmod 666 "$DB_DIR"/osm3s_v*_osm_base
    nohup bin/fetch_osc.sh $ID \\
        "https://planet.openstreetmap.org/replication/minute/" \\
        "diffs/" &
    nohup bin/apply_osc_to_db.sh "diffs/" auto --meta=yes &

Vous devriez maintenant être en mesure d'exécuter des requêtes avec

    bin/osm3s_query

en passant la requête sur l'entrée standard.

## Configurer le Serveur Web

La base de données peut être consultée via le web,
en y accédant depuis un serveur web via la _Common Gateway Interface_ [(CGI)](https://de.wikipedia.org/wiki/Common_Gateway_Interface).

Il existe de nombreux serveurs web différents;
Les instances publiques sont actuellement exploitées avec Apache,
mais des versions avec Nginx ont également été exploitées avec succès pendant des années.
Nous expliquons ici à titre d'exemple une configuration avec Apache.

L'CGI doit d'abord être activée dans Apache,
en reliant le module `cgi.load` dans le sous-répertoire `mods-enabled` à son homologue dans le sous-répertoire `mods-available`.

Ensuite, dans le `VirtualHost` correspondant,
généralement dans le répertoire `sites-enabled`,
le répertoire CGI doit être déclaré.
Pour les instances publiques avec Apache 2.4, le bloc suivant s'en charge;
`$ABSPATH_TO_EXEC_DIR` doit être remplacé par le chemin absolu vers le répertoire cible:

    ScriptAlias /api/ "$ABSPATH_TO_EXEC_DIR"
    <Directory "$ABSPATH_TO_EXEC_DIR">
        AllowOverride None
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Require all granted
    </Directory>
