The Data Model of OpenStreetMap
===============================

To understand how Overpass API works
the data model of OpenStreetMap is introduced here ahead of everything else.

In this section we introduce the basic data structures of OpenStreetMap.
OpenStreetMap foremost contains three kinds of data:

* Geometries, more precisely coordinates and references to the coordinates, locate the objects on Earth's surface.
* Short bits of text give each object a semantical meaning.
* Meta data facilitates to attribute the sources to the data.

All selection criteria of the query language deal with properties of these data structures.

In addition, multiple data formats can represent the data.
These data formats are presented in the section [Data Formats](../targets/formats.md).

Handling the different object type such that it results in manageable geometry deserves a tutorial.
This tutorial is the section [Geometries](../full_data/osm_types.md).

<a name="tags"/>
## Tags

The semantical data of OpenStreetMap are encoded in short bits of text, so called _tags_.
_Tags_ always consist of a _key_ and a _value_.
Each object can have for each _key_ at most one _value_.
Beside a length restriction to 255 characters for each key and value no further constraints apply.

The data model does not distinguish any particular tag or key.
Tags can be chosen spontaneously and to best expedience;
this policy is highly likely to have promoted the success of OpenStreetMap.

Latin lowercase letters and rarely the special characters `:` and `\_` virtually exclusively prevail amongst the keys.
The tags fall into the two informal categories:

_Classifying tags_ have one of a few keys,
and for each key only few values exist.
Deviating values are perceived as erroneous.
For example, the public road grid for motorized vehicles is identified by the key [highway](https://taginfo.openstreetmap.org/keys/highway) and one of fewer than 20 customary values.

In such tags, a value occasionally accommodates multiple customary values concatenated by semicolon.
This is a generally at least tolerated practice to set multiple values for a single key on the same object.

_Describing tags_ have only fixed keys
while anything is accepted in the value
including lowercase and uppercase letters as well as numbers, special characters, and punctuation marks.
Names are the most prominent use case.
But descriptions, identifiers, or even sizes as well are commonplace.

The most generally acclaimed sources for key's and value's semantics are:

* the [OSM wiki](https://wiki.openstreetmap.org/wiki/Map_Features).
  It offers longer textual descriptions.
  But it can happen that the texts rather reflect the respective author's vision than the actual use.
* [Taginfo](https://taginfo.openstreetmap.org/).
  Counts tags by their actual appearance.
  Collects links to most other resources of information about the respective tags.

The complete chapter [Find Objects](../criteria/index.md) is devoted to search of objects by tags.

<a name="nwr"/>
## Nodes, Ways, Relations

OpenStreetMap has three types of objects.
Every object can carry an arbitrary number of tags.
Also, every object has an id.
The combination of type and id is unique, but the id alone is not.

_Nodes_ are defined as a coordinate in addition to the id and tags.
A node can represent a point of interest, or an object of minuscule extent.
Because nodes are the only type of object that has a coordinate,
most of the nodes serve only as a coordinate for an intermediate point within a way
and carry no tags.

_Ways_ consists of a sequence of references to nodes in addition to the id and tags.
This way ways get a geometry by using the coordinates of the referenced nodes.
But they also get a topology:
two ways are connected if both point at a position to the same node.

Ways can refer to the same node multiple times.
The common case for this is a closed way where the first and last entry point to the same node.
All other cases are syntactically correct but semantically deprecated.

_Relations_ have a sequence of members in addition to the id and tags.
Each member is a pair of a reference to a node, a way or a relation and a so-called role.
The role is a text string.
Relations have been invented to represent turn restrictions
thus having few members.
Nowadays, they also serve as boundaries of countries, counties, multipolygons, and routes.
Therefore, their formal structure wildly varies,
and in particular boundary and route relations can extend over hundreds or thousands of kilometers.

The geometry of relations only manifests by the interpretation of the data user.
The multipolygon interpretation has found general acclaim:
like for ways, such relations are understood as an area if the members form closed rings.
Interpretations start at the question whether the presence of the tag _area_=_yes_ is required for this.
Other relations like routes or turn restrictions obtain their geometry as the sum of the geometries of their members of type node and way.

Relations on top of relations are technically possible,
but have little practical relevance.
With relations on relations the risk is further elevated
to end up with large amounts of data already if just the members of a single relation are resolved.
For that reason there are so many different approaches depending on context to resolve references of relations partially
that a [whole section](../full_data/osm_types.md#rels_on_rels) is dedicated to that.

<a name="areas"/>
## Areas

Areas do not have an explicit data structure in OpenStreetMap.
They are instead modeled by closed _ways_ or _relations_.
Tags do matter to distinguish areas from ways closed for other reasons,
in the simplest case by the tag _area_=_yes_.

Closed ways are used if the area is contiguous and does not have holes.
A way is closed if its first and last reference point to the same node.

Relations are used if a way does no longer suffice for the area.
Beside holes and disjoint parts this also happens
when the boundary of the area is supposed to be assembled of multiple ways.
This is applicable virtually only to boundaries of large areas (cities, counties, countries).

Like with ways the area is defined by its boundary.
The in the relation referenced ways therefore must fit and sum up to closed rings.
More information on the [conventions](https://github.com/osmlab/fixing-polygons-in-osm/blob/master/doc/background.md).

<a name="metas"/>
## Meta Data

OpenStreetMap is a full-fledged version control system.
Old versions are retained as well as all the data necessary to assign changes to users.

There always is per object and state a _version number_ and _timestamp_.
Old states with old version numbers are retained.
Therefore the Overpass API is capable by [special methods](../analysis/index.md) to access old states.
Unless on special request, it always operates on current data.

In addition, changed are grouped to _changesets_.
These are associated to the uploading mapper.
The grouping is done automatically by the editing software
and in general one changeset per upload event is created.

_Changesets_ again carry tags and it is possible to discuss changesets with multiple mappers.
These texts are not processed by the Overpass API.

This way each object as a whole is at any moment assigned to a single mapper.
That mapper is always the mapper who has uploaded the most recent version.
Objects with higher version number than 1 therefore usually keep properties from earlier versions,
although those properties are not attributable to the current mapper.

<a name="declined"/>
## Layers, Categories, Identities

By contrast, thematic layers do not exist in OpenStreetMap,
and they are absent for a reason.
For some people supermarkets are together with post offices, banks and ATMs are locations
where one can obtain cash.
For other mappers, supermarkets constitute a group rather together with bakeries and butchers
because one can buy food there.

Therefore, classification plays only a marginal role in OpenStreetMap.
It is rather preferable to record objective properties.
Disputes at large have been prevented,
and most mappers can record their point of view without substantial distortions.

Another often expected structures are categories,
no matter whether very general like all branches of a fast food chain
or all post boxes in Scotland.
OpenStreetMap is a spatial database.
Lists of all objects with a special property in a limited area can be computed.
By the way, Overpass API is one of the tools intended to deliver that,
the chapter [Find Objects](../criteria/index.md) explains how to do that.

Lists of worldwidely all objects with a property have at best a weak spatial relevance.
Although each branch has a location,
the fast food chain as a whole obtains its spatial information solely through its branches.

Finally, the concept of identity leaves precedence to its spatial manifestation.
Similar to the issue with layers, different mappers have different ideas
what belongs to a thing as complex as a large railway station.
Only tracks and platforms?
The reception building as well, or only if it caters passengers needs,
or only if the railway company owns the building?
The place before the station, the bus stop that is named after the railway station?
The points that by railway operating rules are associated with the station even if substantially far away?

If one needs an anchor to point at a certain object on the ground,
then it is best to use a coordinate.
Stationary objects do not move by their very definition
and the positional accuracy in OpenStreetMap is good enough
such that a coordinate is the best anchor for linking.
