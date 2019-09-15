Geometries
==========

To explain the different variants of getting full OpenStreetMap data within a region
the fine print of the OpenStreetMap data model is explained here.

<a name="scope"/>
## Scope of this Section

The OpenStreetMap data types already have been introduced in [a subsection](../preface/osm_data_model.md) of the preface.
Thus, you already are familiar with nodes, ways, and relations.

OpenStreetMap data can be represented in different ways.
Output formats like JSON or XML are explained in the subsection [Data Formats](../targets/formats.md).
The range of possible levels of detail with regard to structure, geometry, tags, version information and attribution also are introduced there.

The issue at stake here is
how completing ways and relations equips them with a useful geometry
while keeping the total size manageable.

<a name="nodes_ways"/>
## Ways and Nodes

A usable geometry for nodes is easy to obtain:
All output modes except `out ids` and `out tags` include the coordinates of the nodes,
because they are anyway part of the nodes by the definition in the OpenStreetMap data model.

By contrast, ways already can be equipped with geometry in multiple ways:
In the best of all cases, your program can process coordinates on ways.
You can observe the difference e.g. in Overpass Turbo,
by comparing the results of the two following requests in the tab _Data_ (upper right corner):
[without coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out;


and [with coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out geom;

The original data model of OpenStreetMap does not admit coordinates on ways,
because the ways already have references to nodes.
Therefore, there still exist programs that cannot process coordinates on ways.
For those there exist two levels of faithfulness to deliver the geometry in the traditional way.

The least extra effort is due if one requests only coordinates of the nodes.
After the output statement of the ways, a statement `node(w)` selects the in the ways referred nodes;
the mode `out skel` reduces the amount of data to pure coordinates,
and the supplement `qt` eliminates the effort to sort the output:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    out qt;
    node(w);
    out skel qt;

I suggest to inspect the output in the tab _Data_ (upper right corner).
The nodes appear after scrolling sufficiently far down.

This is already closer to the original data model,
but there are programs that still do not work with this form of data.
There is a practice to place all nodes before any ways and to sort the elements of the same type by their ids.
To achieve this we must load the nodes in parallel to the ways before we can output anything.
The idiom `(._; node(w););` accomplishes this by its three statements `._`, `node(w)`, and `(...)`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    way(51.477,-0.001,51.478,0.001);
    (._; node(w););
    out;

Nodes and ways each with all their details together are explained in the final section.

<a name="rels"/>
## Relations

As with ways, the simpler case is
that the downstream tool can handle integrated geometry directly.
For this purpose the direct comparison:
[without coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out;

and [with coordinates](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom;

In contrast to the ways the data grows by an order of magnitude:
This is because in the variant without coordinates, we see the ids of the member ways only,
but in fact each way consists of multiple nodes and accordingly has multiple coordinates.

Relations with most of the members being of type way are much more frequent than anything else.
For this reason there is the mechanism to restrict the output geometry to a bounding box,
which is described in the subsection [Crop the Bounding Box](bbox.md#crop):
an [example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out geom({{bbox}});

The original data model of OpenStreetMap does not admit coordinates for relations, too.
For software that needs the strictly original data model, there again are two levels of faithfulness.
One gets a result the most possible way reduced to only the extra coordinates
by outputting the relations first and then resolving their dependencies.
This needs two pathes of data flow,
because relations can have nodes directly as members,
but also indirectly as the members of the ways that are members of the relation.
We would have to use four statements.
Because this is such a frequent case there is an extra short shortcut statement `>`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    out qt;
    >;
    out skel qt;

In comparison to the preceding output the volume of data has already doubled,
because we always need to include both the reference target and the reference itself.

The completely compatible variant claims even more data volume.
It employs the idiom `(._; >;);` built from the statements `._`, `>`, and `(...)`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.477,-0.001,51.478,0.001);
    (._; >;);
    out;

Is there a solution possible also here to restrict the set of retrieved coordinates to the bounding box?
Because a relation is contained in a bounding box
if and only if at least one of its members is contained in the bounding box,
we can achieve this by asking for the referred objects first and then resolve backwards.
The statement `<` facilitates this:
It is a shortcut to find all ways and relations
that refer to the given nodes or ways as members.
Thus we search for all nodes and ways in the bounding box.
Then we keep them with the statement `._` and search all relations
that refer to these as members: [(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    (._; <;);
    out;

The relations can be spotted by the traces they leave on their members:
These have a different colour than ordinary search results in Overpass Turbo.
The relations are even easier to find in the tab _Data_;
just scroll down to the end.

Hence, most members of the relations are not loaded at all;
only the members within the bounding box are loaded.
This request is not ready for production use because we do not load all used nodes for the ways.
A completed request can be found below in the section _Grand Total_.

<a name="rels_on_rels"/>
## Relations on Top of Relations

To demonstrate the problem with relations on relations,
we hardly need to enlarge the bounding box.
We start with the request from above without relations on relations:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    (._; >;);
    out;

Now we replace the resolution from the relations downwards by

* a backwards resolution from relations on relations
* the complete forward resolution of the found relations down to the coordinates

These are performed by the statements `rel(br)` and `>>`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    relation(51.47,-0.01,51.48,0.01);
    ( rel(br); >>;);
    out;

Depending on the system you send the request from
this will paralyze your browser or trigger a warning message.
We intended to get a corner of the suburb Greenwich,
but actually we got data from almost all of London,
because there is a collection of relations called _Quietways_.
This has multiplied the anyway already huge amount of data.

Even if there will be no more collecting relations in the future
like this is currently the case for our test region with about hundred meters edge length:
Do you really want to make your application vulnerable to fail
just because an inexperienced mapper in the region of interest creates one or more collecting relations?

For this reason I strongly discourage you to work with relations on relations.
This data structure creates the risk
to inadvertently lump up huge amounts of data.

If you really want to work with relations on relations,
then it is a much more feasible solution
to only load those relations,
but to refrain from the forward resolution.
For this purpose, we amend our last request from the subsection _Relations_ with the backwards resolution `rel(br)`:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    (._; <; rel(br); );
    out;

<a name="full"/>
## Grand Total

We line up here the most likely helpful variants.

If your software of choice can handle coordinates on the object,
then you can get all nodes, ways, and relations inside the bounding box complete as follows:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.477,-0.001,51.478,0.001);
      way(51.477,-0.001,51.478,0.001); );
    out geom qt;
    <;
    out qt;

This collects

* all nodes in the bounding box (selection in line 1, output in line 3)
* all ways in the bounding box including those that only cross the bounding box without a node inside (selection in line 2, output in line 3)
* all relations that have at least one node or way as a member that is inside the bounding box (selection line 4, output line 5); the relations get no geometry beside the geometry that its included members have anyway.

You get the same data just without relations if you use only the lines 1 to 3 as a request.

You get relations on relations if you amend line 4 by the statements to collect relations and relations on relations:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    out geom qt;
    ( <; rel(br); );
    out qt;

You also can output the data in the strictly traditional format sorted by element type and only with indirect geometry.
This requires in particular the forward resolution of the ways to get all nodes for the ways' geometries.
For this purpose, we must replace the statement `<` by a more precise idiom,
because otherwise the statement `<` picks up ways on the just added nodes.
The first variant then becomes:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    ( ._;
      (
        rel(bn)->.a;
        rel(bw)->.a;
      ); );
    ( ._;
      node(w); );
    out;

Here, the lines 3 to 7 are responsible for the relations.
Without the lines 4 to 8 but with the lines 9 to 11 for the completion of the ways and the output
one only gets nodes and ways.

Conversely, relations on relations can be collected
by adding an extra line 8 to the existing line 7:
[(link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( node(51.47,-0.01,51.48,0.01);
      way(51.47,-0.01,51.48,0.01); );
    ( ._;
      (
        rel(bn)->.a;
        rel(bw)->.a;
      );
      rel(br); );
    ( ._;
      node(w); );
    out;

Further approaches exist,
but have mainly importance for historical reasons.
We present two of them in the [next subsection](map_apis.md).
