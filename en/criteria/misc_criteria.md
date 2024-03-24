Further Search Criteria
=======================

Further search criteria like only for keys, query by length, version, number of changeset, or number of members.

<a name="per_key"/>
## Purely by Key

It can be useful
to query for all objects that bear a tag with a certain _key_ regardless of the _value_.
An [example](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB) with _railway_:

    nwr[railway]({{bbox}});
    out geom;

The filter `[railway]` only admits objects that carry a tag `railway` with an arbitrary value.
It is combined here with a filter `({{bbox}})` for the bounding box,
such that objects are found
if and only if they bear a tag with key `railway` as well as are situated within the bounding box
supplied by [Overpass Turbo](../targets/turbo.md#convenience).

Here every given key can be used as a filter condition by putting it in brackets.
Keys that contain a special character must be [put in quotation marks](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB) in addition to the brackets:

    nwr["addr:housenumber"]({{bbox}});
    out geom;

In principle the filters for keys can be used as standalone restriction in a _query_ statement.
But there are next to no useful use cases due to the resulting amount of data and the required runtime for the request.

Multiple filters for keys [can be combined](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB):

    nwr["addr:housenumber"]["addr:street"]({{bbox}});
    out geom;

Here, we are only interested in objects
that carry both a house number and a street name of an address.
For that purpose, the _query_ statement in line 1 accepts exactly those objects
that have a tag with a key `addr:housenumber` and in addition a tag with a key `addr:street`.

It is also possible to negate the condition.
Objects that may profit from attention can be found in that manner.
We request objects that [bear](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB) a tag with a key `addr:housenumber` but no tag with a key `addr:street`:

    nwr["addr:housenumber"][!"addr:street"]({{bbox}});
    out geom;

The negation is written by putting an exclamation mark between the opening bracket and the beginning of the key.

<a name="count"/>
## Metering an Object

By contrast, the filters to meter objects can only be used in combination with _strong_ filters.
The reason is that otherwise the amount of data too quickly gets too large.

We have a look at the two most popular use cases for counting tags.
For all others, please look into the chapter [Counting Objects](../counting/index.md).

It is possible to select objects that have at least one tag.
An example [for nodes](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=17&Q=CGI_STUB)
because for ways and relations, anyway almost all carry tags:

    node(if:count_tags()>0)({{bbox}});
    out geom;

Conversely, one can select all objects
that do not carry any tag.
Here [for ways](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB):

    way(if:count_tags()==0)({{bbox}});
    out geom;

Both requests are less useful than they promise to be:
There are uninformative tags
(`created_by` on nodes, ways, or relations is deprecated, but may still exist)
or objects may exist only to belong to relations.

For ways and relations, the number of members can be counted and compared and one can compute with it.
There are numerous examples for this in again the chapter [Counting Objects](../counting/index.md).

We can search for ways [with unusually many members](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=15&Q=CGI_STUB):

    way(if:count_members()>200)({{bbox}});
    out geom;

We can check relations whether all members have plausible roles.
For this purpose, we use the evaluator `count_by_role` in addition to the evaluator `count_members`
to show suspicious turn restrictions [as an example](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=12&Q=CGI_STUB):

    rel[type=restriction]({{bbox}})
      (if:count_members()
        -count_by_role("from")
        -count_by_role("to")
        -count_by_role("via") > 0);
    out center;

These are in no way real errors:
as a typical property of diagnostics, we will demonstrate in the chapter [Analyzing Data](../analysis/index.md)
that objects with unexpected properties are the beginning of an inquiry and not their end.

<a name="geom"/>
## Ways by their Length

It is possible to measure the length of a way or relation by an evaluator.
An obvious application are [statistics](../counting/index.md).
But this also enables us to select ways or relations by their length.
The length is always computed in meters.

An example that has actually been used in the past are chimneys.
The tag `building=chimney` has sometimes been used for the entire industrial building.
We thus search for worldwidely all objects tagged as chimneys [with a circumference of more than 62 meters](https://overpass-turbo.eu/?lat=30.0&lon=-0.0&zoom=1&Q=CGI_STUB):

    way[building=chimney](if:length()>62);
    out geom;

Another straightforward idea is to find long roads.
Because roads are usually composed of many short sections,
we must collate the roads by their names before computing the length.
Requests of this degree of complexity rather belong in the chapter [Analyzing Data](../analysis/index.md),
but for the sake of comfort,
one possible solution for 2 km of minimum length is [sketched here](https://overpass-turbo.eu/?lat=51.482&lon=-0.0&zoom=14&Q=CGI_STUB):

    [out:csv(length,name)];
    way[highway][name]({{bbox}});
    for (t["name"])
    {
      make stat length=sum(length()),name=_.val;
      if (u(t["length"]) > 2000)
      {
        out;
      }
    }

Lines 3 to 10 are a loop
in which the selected objects from line 2, i.e. all ways with keys `highway` and `name`,
are grouped by `name`.
Thus, in line 5, the lengths of all objects of an equal name can be summed by the expression `sum(length())`.
In lines 6 to 9, we only write an output if the found length is bigger than 2000 meters.

An approach that brings something on the map is difficult,
because each name is represented by many objects.
A solution based on _deriveds_ will be presented in the chapter [Analyzing Data](../analysis/index.md).

<a name="meta"/>
## Meta Properties

It is possible to search for an object directly by its type and id,
e.g. [node 1](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=CGI_STUB):

    node(1);
    out;

For this purpose both a filter `(...)` with the desired id between the parentheses
as well as evaluators `id()` and `type()` are available.
I am not aware of any use cases relying directly on this feature,
but some bigger tasks in the chapter [Analyzing Data](../analysis/index.md) rely on the features.

By contrast, the version of an object can only be invoked by an evaluator,
because a filter for only a version number could not stand alone due to the amount of data to expect.

A popular use case is to identify nonsense or unacceptable uploads.
It can be helpful for that purpose
to [request](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=17&Q=CGI_STUB) all objects that are still in version 1 within a given bounding box:

    nwr({{bbox}})
      (if:version()==1);
    out center;

The evaluator `version()` is used here for that purpose.
As with all _evaluators_ used to build a _filter_,
this happens by comparing the value of the evaluator to a fixed value (here `1`) within a generic filter `(if:...)`.

Similarly, essentially only an evaluator is available for timestamps;
it is called `timestamp()`.
A filter `(changed:...)` exists as well,
but it is designed to be used [with museum data](../analysis/index.md) only.

The evaluator `timestamp()` always returns a date in the [international date format](https://de.wikipedia.org/wiki/ISO_8601),
i.e. `2012-09-13` for the 13th September 2012.
For that reason, it should always be compared against a date in ISO format.
We enumerate all objects close to Greenwich
that [have not changed since 13th September 2012](https://overpass-turbo.eu/?lat=51.478&lon=-0.0&zoom=16&Q=CGI_STUB):

    nwr({{bbox}})(if:timestamp()<"2012-09-13");
    out geom({{bbox}});

Please note some pitfalls:

* Ways and relations can change their geometry without obtaining a new version number.
  This happens when the referenced nodes have only been moved without changing the list of references.
* The most properties of objects come from earlier versions,
  i.e. a seemingly recent change date does not necessarily indicate an up-to-date object.

<a name="by_user"/>
## By user

How can one get all edits by a specific user?
The answer to this question is more difficult than one might expect.

Whenever someone edits an element then a new version of that element is created.
The OSM database shows the uploading user of that most recent version in the user field of the element,
i.e. that user may be different from the user that performed the change you are interested in.

There is a good chance that you can find [edits by me](https://overpass-turbo.eu/?lat=51.245&lon=7.25&zoom=14&Q=CGI_STUB) in this part of my home city:

    nw({{bbox}})(user:"drolbr");
    out geom;

The relevant criterion is `(user:"drolbr")` in line 2.
This selects from all elements in the bounding box only those that are last touched by me.

Please note that you cannot verify this in the raw data because these are not showing any meta data.
Attach `meta` to `out` in line 3 of [the request](https://overpass-turbo.eu/?lat=51.245&lon=7.25&zoom=14&Q=CGI_STUB):

    nw({{bbox}})(user:"drolbr");
    out geom meta;

Now you can see the meta data including the user attribute in the raw data, and process it further if necessary.
It is also present in the JSON output variant. In the CSV output variant, the special expression `::user` [can be used](https://overpass-turbo.eu/?lat=51.245&lon=7.25&zoom=14&Q=CGI_STUB) as a column header:

    [out:csv(::type,::id,::user,highway)];
    nw({{bbox}})(user:"drolbr");
    out geom meta;

It is possible that a given user has different user names over time.
For example, I had *Roland Olbricht* as user name until it became impractical to have whitespace in the user name.
Now I use *drolbr*.
So if you search for `drolbr`
then you will find even those of my changes I made when my user name had been *Roland Olbricht*.

Consequently, you cannot find my edits if you search by `(user:"Roland Olbricht")`.
This is in particular an issue with users that vandalized then deleted their accounts.
A second move observed in the wild is that vandals delete their accounts
then create another account with the same user name.
This means that `(user:$VANDAL)` will find the vandalism no longer after the action,
mitigated by the fact that usually vandalism is reverted anyway, thus carrying different user fields in line with the respective new version.

For that reason, there is a second set of operators which is based on the user id.
The user id is a numerical unique identifier for an account.
For example, the user id of my account is 65282.
This number can be found in the raw data of every object version of that respective user
but also by tools like [Who's That](http://whosthat.osmz.ru/).

One can use `uid` in [a request](https://overpass-turbo.eu/?lat=51.245&lon=7.25&zoom=14&Q=CGI_STUB) to search by user id:

    nw({{bbox}})(uid:65282);
    out geom meta;

The respective column identifier for [CSV output](https://overpass-turbo.eu/?lat=51.245&lon=7.25&zoom=14&Q=CGI_STUB) is `::uid`:

    [out:csv(::type,::id,::uid,highway)];
    nw({{bbox}})(uid:65282);
    out geom meta;

Quite often it is desireable to select more elements than just those where a given user has been the last user.
Have for example a look at [this station](https://overpass-turbo.eu/?lat=51.239&lon=6.775&zoom=18&Q=CGI_STUB):

    nw({{bbox}})(user:"drolbr_mdv");
    out geom;

Apparently, I have not been involved in the mapping of this station at all.
The constraint `(user_touched:"drolbr_mdv")` helps [discover more details](https://overpass-turbo.eu/?lat=51.239&lon=6.775&zoom=18&Q=CGI_STUB).
It selects objects of which at least one version has been by me:

    nw({{bbox}})(user_touched:"drolbr_mdv");
    out geom;

Now you see that I have mapped quite a lot at this station.
The corresponding constraint [for the user id](https://overpass-turbo.eu/?lat=51.239&lon=6.775&zoom=18&Q=CGI_STUB) is `(uid_touched:2448982)`:

    nw({{bbox}})(uid_touched:2448982);
    out geom;

There are still some issues left.
When a way is split then only one half will be associated with the users that have touched the way.
This is a general problem with element history.
Sometimes mappers delete and redraw things.
This again does remove the association with the users that have touched the way.

And of course, if the elements the user touched simply no longer exist then they are not found.
This is a selector on recent elements (or those of the selected date) and not a discovery tool for museum data.
