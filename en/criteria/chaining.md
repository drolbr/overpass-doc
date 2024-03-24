Pipeline Building
=================

How to build pipelines of search criteria
to search for objects relative to other objects.

<a name="lateral"/>
## Indirect Filters

We have seen examples of indirect filters in the section about [Areas](../full_data/area.md) and the section about [Around](../full_data/polygon.md).
The filter arrangement profits from the [step-by-step paradigm](../preface/design.md#sequential)
to refer to objects that are not necessarily contained in the visible result.

We demonstrate this with the example
to show [all cafés in Cologne](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    area[name="Köln"];
    nwr[amenity=cafe](area);
    out center;

At the heart of the request is the filter `(area)` in line 2.
The filter decided what it accepts by the area or areas
that are selected in the set `_` at that moment.
It is applied in combination with the filter `[amenity=cafe]`,
i.e. we select in line 2 all objects
that are a _node_, _way_, or _relation_ and that bear the tag _amenity_ with value _cafe_
and that are situated within at least one of the in `_` selected areas.

To make the implicit set `_` more visible,
we can use any of the following equivalent rephrasings:
<!-- NO_QL_LINK -->

    area[name="Köln"];
    nwr[amenity=cafe](area._);
    out center;

and
<!-- NO_QL_LINK -->

    area[name="Köln"]->._;
    nwr[amenity=cafe](area);
    out center;

and
<!-- NO_QL_LINK -->

    area[name="Köln"]->._;
    nwr[amenity=cafe](area._);
    out center;

In all cases the area is conveyed from line 1 to line 2 by the set `_`.
Sets are introduced in [a section of the introduction](../preface/design.md#sets).

We also can use a set [with an arbitrarily long name](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    area[name="Köln"]->.extralongname;
    nwr[amenity=cafe](area.extralongname);
    out center;

But of course it does not work
if the names of the sets in the two lines are not equal:
<!-- NO_QL_LINK -->

    area[name="Köln"]->.extralongname;
    nwr[amenity=cafe](area.extralnogname);
    out center;

Set names are in many situations necessary
to supply multiple filters with their respective input.
We can search for cafés in Münster
but the Overpass API then does not know which Münster is meant.
There are small towns called Münster beside the large one,
and [these have cafés](https://overpass-turbo.eu/?lat=50.0&lon=10.0&zoom=4&Q=CGI_STUB), too:

    area[name="Münster"];
    nwr[amenity=cafe](area);
    out center;

We can overcome the problem by requesting
that the café [must be situated both](https://overpass-turbo.eu/?lat=52.0&lon=7.5&zoom=6&Q=CGI_STUB) in Münster and in North Rhine-Westphalia:

    area[name="Nordrhein-Westfalen"]->.a;
    area[name="Münster"]->.b;
    nwr[amenity=cafe](area.a)(area.b);
    out center;

The cafés are selected in line 3:
We filter for objects of the type _node_, _way_, or _relation_
that carry the tag `amenity=cafe`
and that are situated in an area stored in `a` (in fact one area, i.e. the federal state of North Rhine-Westphalia)
and that are situated in an area stored in `b` (all the cities, suburbs, and towns with name _Münster_).
Thus, only the cafés in Münster in North Rhine-Westphalia are left.

The interaction between multiple filters and pipelining will be elaborated on further [in the next section](union.md#full).

For the sake of completeness, we demontrate
that the principle of indirect filters works for all types.
We want to get all bridges over the river _Alster_.

We can select the river by two different approaches:
first, [as ways](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB):

    way[name="Alster"][waterway=river];
    out geom;

We select all objects of type _way_
that bear the tag `name` with value `Alster` and the tag `waterway` with value `river`.
These are delivered in set `_` from line 1 to line 2.
Subsequently, the content of `_` is printed in line 2.

We can select the bridges over the river instead of the river [as follows](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB):

    way[name="Alster"][waterway=river];
    way(around:0)[bridge=yes];
    out geom;

The filter `(around:0)` in line 2 is here the indirect filter.
We select in line 2 all _ways_
that have the tag _bridge_ with value _yes_
and that have a distance of 0 to the objects of the set `_`.
For that purpose, we have collected in line 1 into the set `_` all ways
in whose surroundings we want to find results,
i.e. the ways that have a tag `name` with value `Alster` and a tag `waterway` with value `river`.

The whole thing works as well [with relations](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB) ...

    relation[name="Alster"][waterway=river];
    out geom;

... now [the bridges](https://overpass-turbo.eu/?lat=53.65&lon=10.1&zoom=10&Q=CGI_STUB):

    relation[name="Alster"][waterway=river];
    way(around:0)[bridge=yes];
    out geom;

<a name="topdown"/>
## Referenced Objects

We have met a completely different application of pipelining in the subsections [Relations](../full_data/osm_types.md#rels) and [Relations on Top of Relations](../full_data/osm_types.md#rels_on_rels) of section [Geometries](../full_data/osm_types.md):
The traditional OpenStreetMap data model accepts coordinates only on nodes,
but geometry is a crucial feature of other objects as well.
Thus in the traditional model, ways and relations must be accompanied by their auxiliary nodes.

We explain the aspects of pipelining with an example:
The tube line _Waterloo & City_ in London can be obtained [as follows](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    rel[ref="Waterloo & City"];
    out geom;

Then we employ an [extended data model](../targets/formats.md#extras)
that is not supported by all downstream tools.
If we instead use the traditional degree of detail _out_ [for printing](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB),
then we do not see any result on the map:

    rel[ref="Waterloo & City"];
    out;

The relation is after the output statement in line 2 still in the set `_`.
Thus, we can collect the _ways_ and _nodes_
by [combining](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB) an _union_ statement with pipelining.
The _union_ statement is introduced in the [following section](union.md#union).

    rel[ref="Waterloo & City"];
    out;
    (
      way(r);
      node(w);
    );
    out skel;

Set `_` contains the relations before line 3 like mentioned above.
Lines 3 to 6 constitute the [union](union.md#union) statement.
Line 4 thus is executed next after line 2 and gets the relations as input.
The statement selects _ways_ that match the filter `(r)`,
i.e. ways that are referenced by one or more relations from the input set.
It replaces the content of the set `_` with its result.
According to its semantics, _union_ keeps a copy of this result for its own result.

The statement `node(w)` in line 5 thus sees in set `_` the ways from line 4.
It selects _nodes_ that match the filter `(w)`,
i.e. are referenced by one or more ways from its input, the ways found in line 4.
It again replaces the set `_` with its own result,
but _union_ subsequently anyway replaces that set again.

The _union_ statement writes as result of line 6 the union of the results it has seen.
Thus we get all _ways_ that are referenced by the relations from line 2
and all _nodes_ that are referenced by these _ways_.

Relations can have _nodes_ as immediate members
and these relations do have such members.
One can see this in the [Data](../targets/turbo.md#basics) tab or [per request](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    rel[ref="Waterloo & City"];
    node(r);
    out;

This way we replace in the set `_` in line 2 the _relations_ by the referenced _nodes_.
Then we have in line 3 these _nodes_ available to print them,
but we need the _relations_ again to get the referenced _ways_.
Can we avoid the double query?

Yes, [with named sets](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    rel[ref="Waterloo & City"];
    out;
    (
      node(r)->.directly_referenced_by_the_relations;
      way(r);
      node(w);
    );
    out skel;

In detail:

* After executing line 1, the set `_` contains all _relations_
  that have a tag `ref` with value `Waterloo & City`.
* In line 2 these are printed.
  The set `_` still contains the relations.
* The block statement _union_, from line 3 to 7, executes the block of statements in its interior.
* Hence in line 4, the filter `(r)` operates on the content of set `_`, i.e. the _relations_ from line 1.
  The statement thus puts into the set `directly_referenced_by_the_relations` the _nodes_
  that have been referenced by one or more relations.
  The statement _union_ keeps a copy of the result.
  Otherwise, we are not interested in this result.
  We rather want to keep the statement from overwriting the set `_`.
* In line 5, the filter `(r)` operates on the content of set `_`,
  and these are still the relations from line 1, because line 4 has not overwritten them.
  Now the set `_` is overwritten with the ways that are referenced by the _relations_.
  The statement _union_ keeps a copy of this result, too.
* In line 6, the filter`(w)` uses again the set `_` as input.
  These are now the in line 5 written ways.
  Thus set `_` now consists of the _nodes_ referenced by the ways from the previous content of set `_`.
  The statement _union_ keeps a copy of this result.
* The statement _union_ now makes its own result from the results of the lines 4, 5, and 6
  and writes that result in the set `_`.
* In line 8 the set `_` is printed.

Because this is a very frequent task,
there is [a shortcut](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB) for it:
<!-- Not yet checked -->

    rel[ref="Waterloo & City"];
    out;
    >;
    out skel;

Lines 1 and 2 work as before,
and line 4 works like line 8 in the example before.
The chevron in line 3 has as semantics
that it selects the _ways_ and _nodes_
that are directly or indirectly referenced by relations from its input set, here the set `_`,
and writes them into the set `_`.

Finally, some downstream tools rely on the fixed order in the file:
they need all _nodes_ first, then all _ways_, and then in the end all _relations_.

One can alter our request here
by [moving](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB) the initial statement into the union block:

    (
      rel[ref="Waterloo & City"];
      node(r)->.direkt_von_den_relations_referenziert;
      way(r);
      node(w);
    );
    out;

Similarly [with the chevron](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=14&Q=CGI_STUB):

    (
      rel[ref="Waterloo & City"];
      >;
    );
    out;

<a name="difference"/>
## Difference

...

<a name="equality"/>
## Tags of Equal Value

...
