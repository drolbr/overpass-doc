Autres APIs disponibles
=======================

En plus des requêtes configurables précédentes,
il y a aussi quelques requêtes d'API
qui marchent déjà avec seulement des cordonnées
et qui retournent des données dans une configuration particulière.

## L'export du site openstreetmap.org

Il y a une fonctionnalité dans le [onglet Exportation](https://openstreetmap.org/export) du [site principal de l'OSM](https://openstreetmap.org),
pour exporter toutes les données à l'aide de l'API Overpass.
Cette API réplique le comportement de l'export directement depuis la base de données d'origine,
peut, cependant, exporter beaucoup plus d'éléments quantitativement.
Derrière cela se cache une simple URL:

[/api/map?bbox=-0.001,51.477,0.001,51.478](https://overpass-api.de/api/map?bbox=-0.001,51.477,0.001,51.478)

L'ordre des coordonnées ici est basé sur des interfaces plus anciennes.
Il s'écarte donc de le rectangle englobant.
Les frontières ouest, sud, est et nord se suivent.

Comme requête est exécutée [(Lien)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=17&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(bn);
      node(w);
    );
    ( ._;
      ( rel(bn)->.a;
        rel(bw)->.a;
      );
      rel(br);
    );
    out meta;

C'est-à-dire qu'ils sont inclus :

1. tous les nœuds dans le rectangle englobant donné
1. toutes les chemins qui ont au moins un nœud dans la zone de délimitation
1. tous les nœuds utilisés par ces chemins
1. toutes les relations qui contiennent un ou plusieurs éléments visés aux points 1 à 3 comme membres
1. toutes les relations qui contiennent une ou plusieurs relations de 4 comme membres

et le niveau de détail avec la version et l'horodatage est affiché.

Ne sont pas inclus les chemins qui ne passent que par le rectangle englobant sans avoir un nœud là.
Comment résoudre ce problème,
est expliqué dans le [sous-chapitre précédent](osm_types.md#full), surtout dans la section _Tous les objets ensemble_.

## Xapi

...
