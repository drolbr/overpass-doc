Filter by area
==============

How to get all data within a named area, e.g. a city or a county.

<a name="deprecation"/>
## Deprecation warning

This manual claims
that its content remains valid for many years.
This does not necessarily apply to the current model of _areas_:
The datatype has been created to remain compatible
if a datatype for areas ever had appeared.
I'm nowadays pretty sure that this will never happen.

Thus, I now plan to directly work with the de facto types of _closed way_ and _closed relation_,
essentially equal to a _multipolygon_.
The implementation may take some years,
but in the end some of the syntax variants listed here will become outdated.
For the sake of [backwards compatibility](../preface/assertions.md#infrastructure),
as few syntax variants as possible will be removed.

Currently it is planned
that _area_ is then used as a label for _ways_ or_relations_
for which the evaluator `is\_closed()` returns true.
Conversely, the statement `is\_in` will find these kind of OpenStreetMap objects.
It would make sense to replace that statement by a filter in the transition process.

But please do not understand this notice as an announcement.
There are many more pressing issues in the project,
thus this change may not happen anytime soon.

<a name="per_tag"/>
## per Name or per Tag

The typical use case for areas in the Overpass API is
to download all objects of a certain type or all objects in general in a named area of interest.
We start with objects of a rather sparse type,
all kinds of objects are too many data
to get quick responses to requests for exercising the syntax.
Once the _area_ mechanism is introduced in this section,
the download of all objects follows in the [next subsection](#full).

We first want to display [all supermarkets in London](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB):

    area[name="London"];
    nwr[shop=supermarket](area);
    out center;

The actual work is done in line 2:
the _filter_ `(area)` there restricts the found objects
to those that are partly or completely within one or more of the areas in the set `_`.
Thus we must first bring our areas of interest into the set `_`.

Line 1 selects all objects of the type _area_
that have a tag with key `name` and value `London`.
This object type is explained [later](#background).
By the way, the whole statement is still a [_query_ statement](../preface/design.md#statements).

Unexpectedly, many results pop up across half of the planet.
This is because there are many areas named `London`;
we need to express that we want only the big London in England.
There are five different ways to make our request more precise.

We can draw a huge bounding box around the approximate target region
and can pose [the request](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB):

    area[name="London"];
    nwr[shop=supermarket](area)(50.5,-1,52.5,1);
    out center;

Please note for your convenience
that the bounding box can be [computed automatically](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB) with the [convenience feature](../targets/turbo.md#convenience) of _Overpass Turbo_:

    area[name="London"];
    nwr[shop=supermarket](area)({{bbox}});
    out center;

In both cases, the bounding box acts as a filter in parallel to the `(area)` filter.
For the as temporary intended filter `(area)`, a bounding box has never been implemented.
But that this can be mitigated in the just explained way
also contributed to that it never got priority.

In a similar way we can take advantage of that London is in Great Britain.
A [later subsection](#combining) will present all possibilities for that.

Last but not least we can take further tags into account
to discriminate between multiple _areas_ with the same _name_ tag.
In the case of London the tag with the key _wikipedia_ [helps out](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB):

    area[name="London"]["wikipedia"="en:London"];
    nwr[shop=supermarket](area);
    out center;

Like the first filter by tag `[name="London"]`,
the second filter is applied to the query in the first line.
This way here remains only the one _area_ object
in which we actually wanted to search.

Other often useful tags for filtering are `admin_level` with or without a value or `type=boundary`.
To this end, it helps to first [display](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB) and scrutinize all the found _area_ objects;
please switch after `Run` to the `Data` view by the tab in the upper right corner:

    area[name="London"];
    out;

In line 2 it is printed what has been selected in line 1.
Please check the results for which _tags_ or combinations of _tags_ are unique the area of interest.
By using the _pivot_ filter,
you also can [visualize](https://overpass-turbo.eu/?lat=30.0&lon=0.0&zoom=2&Q=CGI_STUB) them:

    area[name="London"];
    nwr(pivot);
    out geom;

Line 2 constitutes a regular _query_ statement.
The filter `(pivot)` there selected exactly those objects
that are generators of the _areas_ in its input.
This is the set `_`, and it is filled in line 1.

The fifth possibility is a convenience feature of [Overpass Turbo](../targets/turbo.md)
to [let choose](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=10&Q=CGI_STUB) _Nominatim_ the right area:

    {{geocodeArea:London}};
    nwr[shop=supermarket](area);
    out center;

Here the expression `{{geocodeArea:London}}` triggers
that _Overpass Turbo_ asks _Nominatim_ for the most plausible object for the name `London`.
By using the id returned by Nominatim,
Overpass Turbo replaces the expression by an _id_ query for the corresponding area,
e.g. `area(3600065606)`.

<a name="full"/>
## Full Data

Now we want to download really all data in an area.
This works almost with the request that we have used [as a tutorial](#per_tag).
But we need to change the tool:
For an area of the size of London, a threshold of 10 million objects or more is easily surpassed,
while _Overpass Turbo_ already from 2000 objects on substantially slows down the browser.

In addition, for virtually all areas in official boundaries I suggest to rather use regional extracts.
Details for this are in [the subsection about regional extracts](other_sources.md#regional).

You can in both cases download the raw data directly to your local computer:
For this purpose _Overpass Turbo_ offers in the _Export_ menu the link `download as raw OSM data`.
It is normal that nothing happens immediately after the click.
Downloading entire London can take several minutes.

It might be even easier to use download tools like [Wget](https://www.gnu.org/software/wget/) or [Curl](https://curl.haxx.se/).
To exercise this, please store one of the queries from above in a local file, e.g. `london.ql`.

You then can pose requests on the command line with
<!-- NO_QL_LINK -->

    wget -O london.osm.gz --header='Accept-Encoding: gzip, deflate' \\
        --post-file=london.ql 'https://overpass-api.de/api/interpreter'

respectively
<!-- NO_QL_LINK -->

    curl -H'Accept-Encoding: gzip, deflate' -d@- \\
        'https://overpass-api.de/api/interpreter' \\
        <london.ql >london.osm.gz

Both commands can of course be written without the backslash in a single line.
In both cases do you do to me, to you, and to all the other users a big favor
if you set the additional header `Accept-Encoding: gzip, deflate`.
This entitles the server to compress the data,
and this reduces the data about sevenfold and relieves both ends of the connection.

Now we get to the request itself.
Because a source of big amounts of unhelpful data are large-scale relations,
there are several variants [adapted to each downstream use case](osm_types.md).
We restrict here to an often well-adapted variant:
<!-- NO_QL_LINK -->

    area[name="London"]["wikipedia"="en:London"];
    (
      nwr(area);
      node(w);
    );
    out;

As an alternative, a variant
that demonstrates the use of an area as filter multiple times.
To this end you need [to store](../preface/design.md#sets) the selected areas in a named _variable_:
<!-- NO_QL_LINK -->

    area[name="London"]["wikipedia"="en:London"]->.area_of_interest;
    (
      node(area.area_of_interest);
      way(area.area_of_interest);
      node(w);
    );
    out;

Here the query statement in line 3 writes its result into the default set `_`.
Because the area selection is still needed in line 4,
it must be stored in a different location than the default set,
in this case `area_of_interest`.

<a name="combining"/>
## Area inside an Area

We resume the task
to select London as an area in Great Britain.
This is not implemented directly,
but there are again two other solutions.

One can search for objects
that are [in the intersection of two areas](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=8&Q=CGI_STUB):

    area[name="London"]->.small;
    area[name="England"]->.big;
    nwr[shop=supermarket](area.small)(area.big);
    out center;

The actual filtering takes place in the query statement in line 3;
there are only objects admitted that meet all three filter criteria:
The filter `[shop=supermarket]` admits only objects with this very tag.
The filter `(area.small)` restricts this to objects
that are situated within one of the areas from the set `small`.
The filter `(area.big)` restricts this further to objects
that are situated within one of the areas from the set `big`.

Now we need to arrange that in `small` and `big` are selected the intended areas.
This is fulfilled by the queries for _areas_ in lines 1 and 2,
that store their results each in the named variable.

The other approach uses the connection between _area_ and the created object,
but this time in the direction converse to the effect of the _pivot_ filter.
We [select](https://overpass-turbo.eu/?lat=51.5&lon=-0.1&zoom=8&Q=CGI_STUB) the generating object of the small area:

    area[name="England"];
    rel[name="London"](area);
    map_to_area;
    nwr[shop=supermarket](area);
    out center;

In line 4, we want for the filter `(area)` exactly the _area_ for the big London as input.
For this purpose, we select in line 2 all _relations_
that have the name _London_
and are situated without one of the areas supplied as input to `(area)` via the default set `_`.
All areas with the name _England_ have been stored in the default set in line 1.

Now we need in line 4 areas,
although the filter `(area)` cannot filter areas,
and we thus have resorted to select _relations_ instead.
This is done by `map_to_area`:
it selects the areas that have been made from the objects in its input.

<a name="background"/>
## Technical Background
<!-- Not yet checked -->

From the beginning of the Overpass API project on in the year 2009,
the capability to check for A-is-in-B has been a design goal.
But this is quite completely at odds with the requirement
to [faithfully represent](../preface/assertions.md#faithful) the OpenStreetMap data:
Areas are in OpenStreetMap a concept that mingles tags and geometry,
and there have been credible endeavours
to have an explicit data type _area_.
The rules what exactly constitutes an area had not yet been settled that times.
Not least mappers were wary that areas might get damaged quite often.

For this reason, _areas_ are an explicit data type in the Overpass API.
The server generates these in a loop in the background by a [scheme](https://github.com/drolbr/Overpass-API/tree/master/src/rules) that is separated from the software's source code.
This way, operators of independent instances more easily can decide
which areas they actually want to generate.
Each _area_ obtains the tags from its generating object.

This has some effects:

* Areas come into existence many hours later than there generating objects.
  Respectively, changes to the generating object affect the area with a delay.
* If an object does no longer constitute a geometrically valid area
  then the old _area_ object remains unchanged until a new area can be generated from the generating object.
* Areas have their own rules how their ids are disseminated.
* Only a part of the filters that can be used for OpenStreetMap objects can also be used for _areas_.

But the big advantage is that the point-in-area-search works reliably and efficiently.

It turned out to be sometimes a disadvantage that not all generating objects still exist:
nowadays almost any object that has a valid geometry for an area actually semantically is an area.
But if the background loop does not consider the generating object to constitute an area by its tags
then no corresponding area object is generated.

The other way round, for all the 10 years the project exists,
I am not aware of any instance that has adapted the area rule scheme to its particular needs.
There had been rather a tradeoff to accept fewer areas to save CPU time for the background loop.
Thus, the rule scheme is de facto centralized,
and this defeats most of the advantages of the approach.

For this reason, I meanwhile intend to
also perform the area operations directly on the raw OpenStreetMap objects.
