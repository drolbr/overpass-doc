Data Formats
============

There are multiple data formats to carry OpenStreetMap data.
We present all that have an immediate application.

<a name="scope"/>
## Scope

The data types have already been introduced in the [corresponding section of the preface](../preface/osm_data_model.md).
Thus, you should already know _nodes_, _ways_, and _relations_ here.

The frequent problem how to complete the geometry of OpenStreetMap objects
is addressed in [the section about geometries](../full_data/osm_types.md) in the chapter [Spatial Data Selection](../full_data/index.md).

<a name="faithful"/>
## Traditional Degrees of Detail

We start with the degrees of detail:
While the general output format is controlled by a per request global setting,
the degrees of detail are controlled per output statement by its respective parameters.
That way it is possible to mix multiple degrees of detail in a single request.
This capability is needed to get an optimal amount of data for [some geometry variants](../full_data/osm_types.md#full).
In addition, the respectively best output mode is told at each [application](index.md).

We present for each degree of detail an example around the suburb Greenwich in London.
All examples are crafted to return rather few nodes, ways, and relations
to facilitate to inspect the data in the tab _Data_ of Overpass Turbo.

For the original degrees of detail of OpenStreetMap there is a hierarchy to turn them on:

The statement _out ids_ [delivers](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids;

* the ids of the objects

The statement _out skel_ [delivers](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) in addition the necessary information
to reconstruct the geometry:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out skel;

* for nodes their coordinates
* for ways and relations their lists of their members

The statement _out_ (without a flag) [delivers](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) the complete geodata, i.e. in addition:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out;

* the tags of all objects

The statement _out meta_ [delivers](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) in addition:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out meta;

* the versions of the objects
* the timestamps of the objects

Finally, the statement _out attribution_ delivers the following data:

* the changeset id
* the user id
* the current username for this user id

This last degree of detail acts on data
that falls, with regard to the dominant societal consensus, into privacy concerns.
For this reason there is [a barrier](../analysis/index.md) to obtain that data.
As none of this data is necessary for the applications discussed in this chapter,
we refrain from an example here.

<a name="extras"/>
## Additional Data

It is possible to amend the output by three different amounts of geometry data.
Any combination between the just presented degrees of detail and the extra geometry is possible.

The flag _center_ triggers the addition of one coordinate per object.
This coordinate does not have a sophisticated mathematical meaning,
but is just in the middle of the bounding box that encloses the object:
[example 1](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids center;

[example 2](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

The flag _bb_ (for _bounding box_) triggers the addition of the bounding box for each way and relation:
[example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out ids bb;

The flag _geom_ (for _geometry_) amends the ways and relations with coordinates.
For this to work, the degree of detail must be at least _skel_,
and it works up to _attribution_:
[example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out skel geom;

Now we received not only some hundred meters from a park nearby Greenwich,
but several hundred kilometers footways in eastern England.
This is a general problem of relations.
As a remedy, a bounding box also for the output command can be set, [see here](../full_data/bbox.md#crop).

Finally, there is the output format _tags_.
This is based on _ids_ and shows in addition all the tags of an object but no geometries or structures.
First and foremost, it is useful if one [does not need](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) the coordinates in the result:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out tags;

It can also be [combined](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) with the two geometry flags _center_ and _bb_:

    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out tags center;

<a name="json"/>
## JSON and GeoJSON

Now we turn to data formats:
While the degree of detail can be selected per output command,
the output format can be declared only globally per request.
In addition, the choice of the output format only changes the form but not the content.

In JSON we arrive that way in the middle of a conflict.
On the one hand, there is a quite popular format for geodata in JSON, called GeoJSON.
On the other hand, the OpenStreetMap shall keep their structure,
and this structure does not fit into the data model of GeoJSON.

As a solution, there is a possibility to create GeoJSON conforming objects from OpenStreetMap objects.
However, the original OpenStreetMap objects are faithfully represented in JSON and are not GeoJSON.

OpenStreetMap objects [in JSON](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:json];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out geom;

Derived objects [in GeoJSON](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:json];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    convert item ::=::,::geom=geom(),_osm_type=type();
    out geom;

The creation of derived objects is a big subject with its [own chapter](../counting/index.md).

<a name="csv"/>
## CSV

Being capable to organize data in a table is often useful.
For OpenStreetMap this means columns selected by the user and one line per found object.

The choice of the columns properly restricts for most of the objects the information
that is available about the object.
E.g. tags not requested as a column get lost in the output.
Geometries that are more complex than a single coordinate also cannot be printed in this format.
This is a difference to the potentially faithful formats XML and JSON.

The standard case of a column is to be the key of a tag.
It is then printed for each object the value of the tag with this key on the object.
If the object does not have that key,
then an empty value is printed.
For the further properties of an object there are special column header declarations;
these start with `::`:
[example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB)

    [out:csv(::type,::id,name)];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

The abbreviation CSV used to mean _comma separated value_.
But the various applications using this format have developed differing expectations
what constitutes a delimiter.
Thus, it is possible to configure the delimiter as well as
it is possible [to turn the headline on or off](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB):

    [out:csv(::type,::id,name;false;"|")];
    ( way(51.477,-0.001,51.478,0.001)[name="Blackheath Avenue"];
      node(w);
      relation(51.477,-0.001,51.478,0.001); );
    out center;

At [each application](index.md) it is indicated which variant fits.
