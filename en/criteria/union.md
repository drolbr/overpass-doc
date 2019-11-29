Combining by And and Or
=======================

Query for objects by multiple tags or other criteria.


<a name="intersection"/>
## Intersection

We start with combining two or more filters
such that only objects are found that fulfill all of the conditions.
Several such examples for intersections have already been introduced:
[tag and bounding box](per_tag.md#local),
[tag and area, tag and two areas as well as two tags](chaining.md#lateral)

We fix as a default example for the moment
to find an automatic teller machine.
The tag `amenity` with value `atm` indicates such devices.
Due to their large number
the [example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB) has a small bounding box:

    nwr[amenity=atm]({{bbox}});
    out center;

We have realized the combination of the filter for the tag `[amenity=atm]` with then filter for the bounding box `({{bbox}})` here
by just writing one filter after the other.

The order [does not matter](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr({{bbox}})[amenity=atm];
    out center;

But there is another way to tag automatic teller machines:
Often they are part of a branch bank.
Then they are tagged as [a property of that bank](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr[amenity=bank]({{bbox}})[atm=yes];
    out center;

Like in all other examples,
the filters can be ordered in [any order you want](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr[atm=yes][amenity=bank]({{bbox}});
    out center;

It is explained in the [next section](union.md#union) how to combine both search criteria.
Before that, it shall be emphasized
that any number of tags or other criteria can be combined:
please leave out [in the following example](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=9&Q=CGI_STUB) on or more filters;
the result will always change because any of the six filters as well as the bounding box have an impact:

    way
      [name="Venloer Straße"]
      [ref="B 59"]
      (50.96,6.85,50.98,6.88)
      [maxspeed=50]
      [lanes=2]
      [highway=secondary]
      [oneway=yes];
    out geom;

This applies as well to the example of the automatic teller machines:
Often it is enough to search for a more specific tag,
because on objects with the specific tag there is almost always also set the more general tag.

* Over 95% of all objects with a tag `admin_level` also bear [according to Taginfo](https://taginfo.openstreetmap.org/tags/boundary=administrative#combinations) (numbers and bars in the columns to the right) the tag `boundary=administrative`.
* Over 99% of all objects with a tag `fence_type` also bear [according to Taginfo](https://taginfo.openstreetmap.org/tags/fence_type=wood#combinations) the tag `barrier=fence`.

A [request](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=14&Q=CGI_STUB) for fences (`barrier=fence`) with the extra property `fence_type=wood` thus delivers effectively almost the same result ...

    nwr[barrier=fence][fence_type=wood]({{bbox}});
    out geom;

.. like a [request](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=14&Q=CGI_STUB) only for `fence_type=wood`:

    nwr[fence_type=wood]({{bbox}});
    out geom;

The automatic teller machines deliver more results
if we [reduce the criteria](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB) to only `atm=yes`:

    nwr[atm=yes]({{bbox}});
    out center;

The result is compelling on the semantic level:
automatic teller machines may indeed be situated with gas stations, in malls or other buildings and not only in banks.

<a name="union"/>
## Union

Now we want to combine two or more criteria
such that all objects are found
that fulfill just at least one of the criteria.
Also for this, we have seen quite some examples:
[all objects in bounding boxes](../targets/formats.md#faithful),
[amending ways and relations](chaining.md#topdown),
[as an example for a block statement](../preface/design.md#block_statements)

Our example from above leads to the challenge
to request both free standing automatic teller machines and those in banks [with a single request](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    (
      nwr[amenity=atm]({{bbox}});
      nwr[atm=yes]({{bbox}});
    );
    out center;

The statement _union_ caters for combining both criteria;
it spans lines 1 to 4.
It executes its inner block.
Line 2 writes as result into the set `_` all objects
that have a tag `amenity` with value `atm` and in addition are situated in the bounding box [supplied by Overpass Turbo](../targets/turbo.md#convenience).
The statement _union_ keeps a copy of the result.
Line 3 writes as a result into the set `_` all objects
that have a tag `atm` with value `yes` and in addition are situated in the bounding box supplied again by _Overpass Turbo_.
After that, _union_ writes into the set `_` as a result all objects
that it has seen in one of the partial results -
these realizes precisely the desired combination by _or_.

A frequent use case is
to check a quite long number of given possible values for a given tag.
If one wants to collect all roads usable by cars,
then a list like
`motorway`, `motorway_link`,
`trunk`, `trunk_link`,
`primary`, `secondary`, `tertiary`,
`unclassified`, `residential`
has to be handled.
With an _union_ statement, one can [request this as follows](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=15&Q=CGI_STUB):

    (
      way[highway=motorway]({{bbox}});
      way[highway=motorway_link]({{bbox}});
      way[highway=trunk]({{bbox}});
      way[highway=trunk_link]({{bbox}});
      way[highway=primary]({{bbox}});
      way[highway=secondary]({{bbox}});
      way[highway=tertiary]({{bbox}});
      way[highway=unclassified]({{bbox}});
      way[highway=residential]({{bbox}});
    );
    out geom;

But one can also take advantage of the [regular expressions](per_tag.md#regex) presented in the last section.
Then one only needs [as request](https://overpass-turbo.eu/?lat=51.473&lon=0.0&zoom=15&Q=CGI_STUB):

    way({{bbox}})
      [highway~"^(motorway|motorway_link|trunk|trunk_link|primary|secondary|tertiary|unclassified|residential)$"];
    out geom;

Lines 1 and 2 constitute a _query_ statement for _ways_ with two filters.
The filter `({{bbox}})` for bounding boxes [is well-known](../full_data/bbox.md#filter).
The tilde `~` is the most important character of the other filter.
It lets the filter match on objects that have a tag with key as left from the tilde, here `highway`,
and a value that matches the regular expression right of the tilde.

The syntax with caret `^` in the beginning and `$` at the end indicates
that the value must fit in total and not only a substring of the value can satisfy the expression.
The pipe sign `|` divides the multiple matching alternatives from each other,
here in total 9 different values for the tag.

The section about [regular expressions](per_tag.md#regex) presents more examples.

In our example of automatic teller machines we do not have a common key.
Thus, the regular expressions do not help here.

Instead, the bounding box is used multiple times as a filter.
If one wants to avoid the repetition,
then one can pull the filter in the front
and store the result in a named set;
the name `all` speaks for itself.
This trick often saves runtime for the [request](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=CGI_STUB):

    nwr({{bbox}})->.all;
    (
      nwr.all[amenity=atm];
      nwr.all[atm=yes];
    );
    out center;

A _query_ statement in line 1 is prepended to the _union_ statement now in lines 2 to 5.
In this _query_ statement all objects from the bounding box are cached in the set `all`.
This set is used twice in the _union_ block:
A filter for a set `.all` is used both in lines 3 and 4;
this filter restricts the result to the content of the set `all`.
Thus, in line 3 are found exactly the objects
that are in the set `all` and that have a tag with key `amenity` and value `atm`.
In line 4 are found exactly the objects
that are in the set `all` and that have a tag with key `atm` and value `yes`.

Why do we not just take the set `_`?
Although this would be technically possible,
but we then would need to divert the result of each line individually.
This is too easy to overlook and thus a frequent source of mistakes.

<a name="full"/>
## Mixed Logic

...
