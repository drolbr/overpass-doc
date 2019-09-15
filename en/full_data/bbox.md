Bounding Boxes
==============

The simplest way to obtain OpenStreetMap data from a small region.

<a name="filter"/>
## Filter a Query

The simplest way to get all data from a bounding box
is to explicitly state so [(Link)](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    nwr(51.477,-0.001,51.478,0.001);
    out;

Here `(51.477,-0.001,51.478,0.001)` represents the bounding box.
The order of the edges is always the same:

* `51.477` is the _latitude_ of the southern edge.
* `-0.001` is the _longitude_ of the western edge.
* `51.478` is the _latitude_ of the norther edge.
* `0.001` is the _longitude_ of the eastern edge.

The Overpass API only uses the decimal fraction notation,
a notation in minutes and seconds is not supported.

The value of the southern edge must be always smaller than the value of the northern edge,
because the values for degree of latitude are growing from the south pole to the north pole,
from -90.0 to +90.0.

In contrast to this, the values for degree of longitude are growing from west to east almost everywhere.
But at the antimeridian the values jumps from +180.0 to -180.0.
The antimeridian crosses on its way from the north pole to the south pole the pacific and not much else.
Thus, in almost all cases the value of the western edge is smaller than the value of the eastern edge,
unless one really wants to span a bounding box across the antimeridian.

It usually is tedious
to manually figure out the bounding box.
For this reason, almost all of the at [Downstream Tools](../targets/index.md) listed tools have convenience features for this.
In [Overpass Turbo](../targets/turbo.md#convenience) and also [JOSM](../targets/index.md),
the substring `{{bbox}}` is replaced by the bounding box of the viewport.
Thus, one can work with a generalized query like [this](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    nwr({{bbox}});
    out;

The query then always is executed in the then current visible bounding box.

Please note that some of the elements are presented as dashed.
This is a telltale sign of a bigger phenomenon,
and we will pursue that further [in the next section](osm_types.md):
The objects in question have been completely delivered with regard to their syntactic structure,
but they have incomplete geometry because we implicitly specified so in this query.

<a name="crop"/>
## Crop Output

There is a second purpose that bounding boxes are used for:
The output of `out geom` can be spatially restricted.
If one wants to visualize a _way_ or _relation_ on a map,
then one must [explicitly instruct](../targets/formats.md#extras) the Overpass API to add coordinates,
deviating from the design of the OSM data model.

In the case of relations this can lead to big amounts of data.
As a quite typical example,
in [this case](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) geometry across half of England is delivered,
although only a couple of hundreds of square meters had been in focus:

    relation(51.477,-0.001,51.478,0.001);
    out geom;

The amount of data can be reduced
by [explicitly stating](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) a bounding box to apply:

    relation(51.477,-0.001,51.478,0.001);
    out geom(51.47,-0.01,51.49,0.01);

The bounding box must be written immediately after `geom`.
It can be equal or different from bounding boxes in our statements of the same request.
In this case we have opted for a very broad spare boundary
by using a larger bounding box for the output than for the query.

For explicitly output _nodes_ the coordinate then is exactly delivered
if the node is inside the bounding box.

For _ways_, not only the coordinates of the _nodes_ within the bounding box are printed,
but always also the next and preceding coordinate
even if the respective coordinate is already outside the bounding box.
To see this in [an example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=18&Q=CGI_STUB),
please click after executing the request in the upper right corner on _data_.
Panning the map around shows where the geometry has been cut:

    way[name="Blackheath Avenue"](51.477,-0.001,51.478,0.001);
    out geom(51.477,-0.002,51.479,0.002);

Only part of the _nodes_ have coordinates in this example.

The parts that have coordinates of each single the way [can be unconnected](https://overpass-turbo.eu/?lat=51.4735&lon=-0.007&zoom=17&Q=CGI_STUB), even within a single way:

    way[name="Hyde Vale"];
    out geom(51.472,-0.009,51.475,-0.005);

The phenomenon already happens
if a way makes a moderate curve out of the bounding box and later again into it
like in this example.

For _relations_ their _members_ of type _way_ are expanded
if at least one of the _nodes_ of the respective way is inside the bounding box.
Other _members_ of type _way_ are not expanded.
Within these _ways_, like for _ways_ themselves,
the referred _nodes_ within the bounding box plus one extra _node_ are amended with coordinates.

Like with the bounding box as a filter,
most programs have a mechanism to automatically insert the bounding box of the viewport.
In [Overpass Turbo](../targets/turbo.md#convenience) again the substring `{{bbox}}` is replaced by the current bounding box, [e.g.](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    relation({{bbox}});
    out geom({{bbox}});

<a name="global"/>
## Filter Globally

...
