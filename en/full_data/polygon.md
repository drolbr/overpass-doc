Polygon and Around
==================

Where to filter can be shaped more versatile than with a bounding box.

Coordinates in degrees of latitude and longitude are easy to understand as a concept,
but few people can recall latitude and longitude of their locations of interest.
For this reason we first present spatial selection by known objects.

Although the selection of all objects within a known area is outstandingly frequent,
it is presented in [its own section](area.md),
because a couple of caveats apply.

This section starts with a subsection how to
filter for the objects in proximity to known and selected objects.
The subsequent section is about filtering for objects in proximity of given coordinates.
The section concludes by presenting
how to filter by a polygon or multipolygon as an outline.

<a name="around"/>
## Filter Relative to Selected Objects

It is a sophisticated task
to conclude from a couple of words to a specific location.
For this reason this job ought be done a proper geocoder, e.g. [Nominatim](../criteria/nominatim.md#nominatim);
thus we do not pursue that here.
The power of Nominatim can be combined with Overpass API by the search by coordinate,
and this is the topic of the next section.

Nonetheless, in many cases a name alone already [identifies](https://overpass-turbo.eu/?lat=51.0&lon=10.0&zoom=6&Q=CGI_STUB) the desired object:

    nwr[name="Kölner Dom"];
    out geom;

In line 1 we select all objects
that have a tag `name` with value `Kölner Dom`.
These are stored in the set `_`.
In line 2 the statement `out geom` prints all the objects that are in the set `_`.

Please recall that [the magnifying glass](../targets/turbo.md#basics) zooms to the results.
In particular for indirect filters, it makes sense to
run the leading object search first,
because there may exist objects of the same name [in unexpected places](https://overpass-turbo.eu/?lat=51.0&lon=10.0&zoom=6&Q=CGI_STUB):

    nwr[name="Viktualienmarkt"];
    out geom;

A [bounding box](bbox.md#filter) or using an enclosing area [can help](https://overpass-turbo.eu/?lat=48.0&lon=11.5&zoom=10&Q=CGI_STUB):

    area[name="München"];
    nwr(area)[name="Viktualienmarkt"];
    out geom;

The desired object or objects are selected as set `_` after line 2.

We can now find all objects within 100 meters distance [around the](https://overpass-turbo.eu/?lat=50.94&lon=6.96&zoom=14&Q=CGI_STUB) Kölner Dom:

    nwr[name="Kölner Dom"];
    nwr(around:100);
    out geom;

Against our expectations, but for good reason,
Overpass Turbo warns that the size of the result is big.
It is not immediately clear
why railway tracks between Paris and Brussels, hundreds of kilometers away,
should be considered to be close to the Kölner Dom.
The problems are relations of substantial spatial extent,
in this case railway services.
Given that this is [hardly better](https://overpass-turbo.eu/?lat=48.135&lon=11.575&zoom=14&Q=CGI_STUB) close to the Viktualienmarkt
due to hiking and cycling routes ...

    area[name="München"];
    nwr(area)[name="Viktualienmarkt"];
    nwr(around:100);
    out geom;

... it ought be conjectured that the problem occurs frequently.
This tightly limits the use of the _around_ filter as a filter without further criteria.

On the technical level,
we again have our object to be used as reference before line 3 in the set `_`.
The statement `around` now selects from all the objects those
that have to at least one of the objects in the set `_` a distance from at most the provided value `100` in meters.

An entire [subsection](../criteria/chaining.md#lateral) is devoted to piping statements,
and sets have been explained in [the preface](../preface/design.md#sets).
The example [there in the beginning](../preface/design.md#sequential) shows an application of the _around_ filter
that is helpful
because it [combines](../criteria/union.md#intersection) the filter with a filter for a tag.
Tools to cope with overly large amounts of data have been discussed in the section [Geometries](osm_types.md#full).

Another possible solution to at least display a meaningful subset of data,
is to filter for _ways_ instead of all objects
and to select the _relations_ that refer to this ways without asking for their geometry.
For the [Kölner Dom](https://overpass-turbo.eu/?lat=50.94&lon=6.96&zoom=14&Q=CGI_STUB):

    nwr[name="Kölner Dom"];
    way(around:100);
    out geom;
    rel(bw);
    out;

Line 1 puts the named objects into the set `_`.
Line 2 selects all _ways_
that have to at least one of the objects in the set `_` a distance of at most 100 meters;
the result replaces the content of the set `_`.
Line 3 prints the result of set `_`, i.e. the in line 2 selected ways.
Line 4 selects all _relations_
that have at least one of the ways in `_` as a member
and replaces the content of `_` with that selection.
In line 5 the content of `_` is printed, i.e. the found relations,
but in contrast to line 3 no coordinates are amended -
this shrinks the _relations_ to a size
that is easier to handle.

<a name="absolute_around"/>
## Filter Around Absolute Coordinates

It can be searched not only around the given objects, but also around the given coordinates.
An example close to Greenwich [on the prime meridian](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB):

    nwr(around:100,51.477,0.0);
    out geom;

Line 1 employs the filter in question:
This query selects all objects into the set `_`
that have to the given coordinate a distance of at most 100 meters.
Line 2 prints the content of the set `_`.

The same warnings as for all other full data searches with _relations_ do apply:
very quickly you are flooded with very much data.
Fortunately, the reduction tricks of [bounding boxes](osm_types.md#full) and [from the last section](#around) do apply here, too.

Nobody is obliged to search for _relations_.
You can as well search only for _nodes_, [only for _ways_](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB) ...

    way(around:100,51.477,0.0);
    out geom;

... or only for [_nodes_ and _ways_](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB):

    (
      node(around:100,51.477,0.0);
      way(around:100,51.477,0.0);
    );
    out geom;

Here we use an _union_ statement (will be introduced [later](../criteria/union.md#union))
to add the results of the quest for _nodes_ to the results of the quest for _ways_.
The statements in lines 2 and 3 each filter for an object type by an _around_ filter.
And the _union_ statement combines both into the final selection into the set `_`.

This approach can handle a radius of 1000 and more meters
and still delivers not too much data.

Relations can be [amended](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=15&Q=CGI_STUB) like above without geometry:

    (
      node(around:1000,51.477,0.0);
      way(around:1000,51.477,0.0);
    );
    out geom;
    rel(<);
    out;

The set `_` still contains before line 5 the result of the _union_ statement.
The filter `(<)` only admits objects
that have at least one object from its input as a member.
These are amongst the relations exactly those that have components within the search radius.

We conclude with yet another tool for searches that do not fit well into a bounding box:
One can search in the proximity of a polyline.
For this purpose one defines a path over two or more coordinates,
and then all objects are found
that have a [lower distance to that path](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=13&Q=CGI_STUB) than the given value:

    (
      node(around:100,51.477,0.0,51.46,-0.03);
      way(around:100,51.477,0.0,51.46,-0.03);
    );
    out geom;
    rel(<);
    out;

In comparison to the preceding query, only lines 2 and 3 have changed;
the coordinates are written one after another separated by commas.

<a name="polygon"/>
## Polygons as Filters

Another method to handle free-form areas of interest is to search by a self-defined polygon.
Again, this helps if the area of interest does not well fit into a bounding box.

[Areas](area.md) already cover many use cases
by enabling the search exactly within a named area.
But when it comes to slightly extend such areas
or to cut out arbitrary free forms
then it is inevitable to use an explicit polygon as the boundary.

For illustrative purposes, a search only for nodes [with a triangle as boundary](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB) is presented
such that the form of the polygon can be spotted on the map:

    node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
    out geom;

In line 1 we search for _nodes_
and the filter `(poly:...)` only admits objects
that are situated within the inside the quotation marks noted polygon.
This polygon is a list of coordinates of the form latitude-longitude
where between the numbers is only whitespace allowed.
After the final coordinate, the Overpass API always adds the edge to close the polygon.

Very much data is produced by [the search for all three types of objects](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
    out geom;


Like [before](#around) this can be mitigated by the two steps _nodes_ plus _ways_ and then reverse resolution of the _relations_.
The data reduction is effected by [avoiding the geometry](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB) of the _relations_:

    (
      node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
      way(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
    );
    out geom;
    rel(<);
    out;

Can the search area contain holes or have multiple components?

Multiple components can be realized by an _union_ statement.
Because _union_ statements can contain any number of statements,
we can just write the _query_ statements for the components one after another.
The [_nodes_ and _ways_ variant](https://overpass-turbo.eu/?lat=51.487&lon=0.0&zoom=13&Q=CGI_STUB):

    (
      node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
      way(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01");
      node(poly:"51.491 -0.01 51.498 -0.03 51.505 -0.01");
      way(poly:"51.491 -0.01 51.498 -0.03 51.505 -0.01");
    );
    out geom;
    rel(<);
    out;

The outline is stated here twice,
once for the _node_ query and once for the _way_ query.
Unfortunately, there is currently no way around this.

For holes, it might be tentative to use the block statement [difference](../criteria/chaining.md#difference).
That statement prunes as well the objects that lie partly in the desired polygon and partly in the hole,
because both arguments of the difference match those objects.

Instead, one can duplicate the vertex on the outer line
that is closest to the hole.
Then one can insert the vertex sequence describing the hole between these two vertices.

If we, for example, want to cut out from the triangle `51.47 -0.01 51.477 0.01 51.484 -0.01`
the triangle `51.483 -0.0093 51.471 -0.0093 51.477 0.008` then

* We first duplicate the closest vertex `51.484 -0.01`,
  thus have the sequence `51.47 -0.01 51.477 0.01 51.484 -0.01 51.484 -0.01`.
* Repeat the first vertex of the hole at its end,
  thus get for the hole the sequence `51.483 -0.0093 51.471 -0.0093 51.477 0.008 51.483 -0.0093`.
* Insert the hole description between the two copies of the duplicated vertex:
  `51.47 -0.01 51.477 0.01 51.484 -0.01 51.483 -0.0093 51.471 -0.0093 51.477 0.008 51.483 -0.0093 51.484 -0.01`

For the sake of Illustration the [final request](https://overpass-turbo.eu/?lat=51.477&lon=0.0&zoom=14&Q=CGI_STUB).
This request works as well for all the other object types
and multiple query statements can be combined by an _union_ statement.
But then one sees worse the actually selected area:

    node(poly:"51.47 -0.01 51.477 0.01 51.484 -0.01
      51.483 -0.0093 51.471 -0.0093 51.477 0.008
      51.483 -0.0093 51.484 -0.01");
    out geom;
