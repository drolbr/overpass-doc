Further Map APIs
================

In addition to requests in the query language,
the Overpass API also offers some ready-made API calls.
The majority of them exists for the purpose of backwards compatibility,
and all of them are emulated by executing the corresponding Overpass QL request.
They thus only need coordinates.

## The Export of the Main Site

In the [export tab](https://openstreetmap.org/export) of the [OSM main site](https://openstreetmap.org),
there is a feature to export all data by Overpass API.
It adheres to the semantics of the OSM main site,
but it can export substantially larger extracts.
This is driven by a simple URL:

[/api/map?bbox=-0.001,51.477,0.001,51.478](https://overpass-api.de/api/map?bbox=-0.001,51.477,0.001,51.478)

Here the order of the coordinates is in the style of legacy interfaces:
western edge, southern edge, eastern edge, northern edge.
Please note that it is different from the standard order in Overpass QL.

This API call executes the [following request](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=17&Q=CGI_STUB):

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

Thus the result contains:

1. all nodes in the given bounding box
1. all ways that have at least one node in this bounding box
1. all nodes used by these ways
1. all relations that contain one or more elements from (1.) to (3.) as members
1. all relations that contain one or more relations from (4.) as members

and it is printed the degree of detail with version and timestamp.

Not contained are ways that cross the bounding box without having any node inside the bounding box.
How to fix that problem is explained in the [preceding subsection](osm_types.md#full),
in particular in the section _Grand Total_.

## Xapi

...
