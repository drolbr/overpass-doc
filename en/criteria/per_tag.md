Per Tag or Key
==============

Request all objects that bear a chosen tag.

<a name="global"/>
## Global

We would like to find worldwide all objects
that bear a given [tag](../preface/osm_data_model.md#tags).

This only makes sense with the Overpass API for tags with less than 10'000 occurrences.
The respective number can be found at [Taginfo](nominatim.md#taginfo).
For larger numbers, it can take too much time
to get the data at all
or the browser crashes on the attempt of showing them
or both.

Searches that are [spatially constrained](#local) do work well even for frequent tags.

A typical example for rare tags are names of things, [here](https://overpass-turbo.eu/?lat=51.47&lon=0.0&zoom=12&Q=CGI_STUB) _Köln_
(German name of _Cologne_):

    nwr[name="Köln"];
    out center;

Even after triggering the request by _Execute_ nothing visible happens.
Instead, clicking the [magnifier](../targets/turbo.md#basics) moves the viewport to the data.
We use a global viewport for all of the following requests
such that you do not need to move the viewport.

Such searches can fail in seemingly straightforward cases, too.
The term _Frankfurt_ [collects results](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) all over the globe,
but the biggest city of that name, Frankfurt am Main, is not found at all:

    nwr[name="Frankfurt"];
    out center;

Having the suffix _am Main_ in the name hampers the city from being found.
Overpass API would neglect its [mission](../preface/assertions.md#faithful)
if it found an object beside that mismatch.
An interpreting search constitutes a job for a geocoder, e.g. [Nominatim](nominatim.md).

Still Overpass API posesses filters suitable to catch the name with suffix, e.g. by a _regular expression_.
We can [request all objects](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB)
whose names start with _Frankfurt_;
due to the large number of hits this search takes time,
but the result's size is harmless in this case despite the warning message:

    nwr[name~"^Frankfurt"];
    out center;

Many more typical use cases for _regular expressions_ are elaborated on [later](#regex).

These are not exactly few hits,
in particular roads whose names start with _Frankfurt_.
In most cases we search for only one of the three OpenStreetMap object types.
The boundaries of a city are always encoded as a _relation_.
We can narrow down to this object type
as we [replace](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB) _nwr_ (for nodes-ways-relations) by _relation_:

    relation[name="Köln"];
    out geom;

Here the [output verbosity](../targets/formats.md#extras) has been changed from _center_ to _geom_
to show the full geometry of the object.

Correspondingly, there are the types _node_ and _way_ instead of _nwr_.
They deliver only nodes respectively ways.

Finally a remark about tags with special characters (everything except letters, digits, and the underscore) in the _key_ or in the _value_:
The attentive reader might have spotted that the _value_ in the tag filter is always in quotation marks.
Quotation marks are suggested around _keys_ as well,
thus the request above shall strictly look like:
<!-- NO_QL_LINK -->

    relation["name"="Köln"];
    out geom;

But Overpass API silently wraps the key in quotation marks
whenever it is clear that an ordinary literal is intended.
This cannot work with special characters
because special characters can have a special meaning
and the user might have made a typo elsewhere in writing down the requests.

Quotation marks in literals are escaped
by prepending them with a backslash.

<a name="local"/>
## Local

If one requests all objects with a certain tag within a certain area,
then it is actually a combination of more than one filter.
Combining filters is described thoroughly in [Combining by And and Or](union.md) and [Pipelineing](chaining.md).
Here we keep focus on certain standard use cases.

All objects in a unique area are e.g. [all cafés in Cologne](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB):

    area[name="Köln"];
    nwr[amenity=cafe](area);
    out center;

The section [Areas](../full_data/area.md#per_tag) covers the operating mode of the first line.
Our attention here goes to line two:
This is a _query_ for types _nwr_ (i.e. _nodes_, _ways_, and _relations_).
The presence of the first filter `[amenity=cafe]` determines
that only objects are admissible that carry a tag with key _amenity_ and value _cafe_.
The second filter `(area)` restricts the result to objects from a certain area.

The filter `(area)` operates based on [the step-by-step paradigm](../preface/design.md#sequential).

This way we select objects that fulfill both the tag condition and the spatial condition.
These selected objects are, again by [the step-by-step paradigm](../preface/design.md#sequential),
available for the following statement.
This prints them to the user.

If this sounds too complex to you
then a different and simpler way may appeal to you:
You can shape the result spatially [by bounding box](../full_data/bbox.md#filter)
and combine this with a filter for a tag ([example](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB)):

    nwr[amenity=cafe]({{bbox}});
    out center;

The central element again here is the statement starting with _nwr_:
The filter `[amenity=cafe]` works the same way as before.
The filter `({{bbox}})` is expanded by [Overpass Turbo](../targets/turbo.md#convenience) to the current viewport as a bounding box,
and Overpass API uses that bounding box as the second and spatial filter.

The order of the two filters [does not matter](https://overpass-turbo.eu/?lat=50.95&lon=6.95&zoom=10&Q=CGI_STUB) -  it never matters for filters:

    nwr({{bbox}})[amenity=cafe];
    out center;

has the same result as the request before.

The target type of the _query_ statement can and shall be selected amongst _node_, _way_, and _relation_ here, too.
For example for railway tracks [only ways](https://overpass-turbo.eu/?lat=50.94&lon=6.95&zoom=14&Q=CGI_STUB):

    way[railway=rail]({{bbox}});
    out geom;

<a name="regex"/>
## Special

<!-- Checked until here -->

We have already desired to search in a fuzzy way, in the case of _Frankfurt_.
[Regular expressions](https://www.gnu.org/software/grep/manual/grep.html#Regular-Expressions) are a very powerful tool for this.
A systematic introduction to regular expressions would go beyond the scope of this manual,
but it will provide a couple of examples for commonplace needs.

In some cases we know how a name starts.
For example, we [request here](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) all streets whose names start with _Emmy_:

    way[name~"^Emmy"];
    out geom;

The most important character in the entire request is the tilde `~`.
It turns the filter in the first line into a filter for regular expressions.
Now all in the database existing values for the tag with key `name` are compared against the regular expression that follows after the tilde.

The second most important character is the caret in the expression `^Emmy`.
It is part of the regular expression
and ensures that only values match that start with `Emmy`.
In total, the request could be stated as:

Find all objects of the type _way_
that have a tag with key `name` and a value
that starts with `Emmy`.

An appropriate [output statement](../targets/formats.md#extras) follows in the second line.

Similarly, one can search for values
that [end on](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) a given value, e.g. _Noether_:

    way[name~"Noether$"];
    out geom;

The tilde `~` again marks the filter to be for a regular expression.
The dollar sign `$` within the regular expression defines that the value shall end on `Noether`.

The [magnifier](../targets/turbo.md#basics) as a convenience feature in _Overpass Turbo_ zooms to the single result, in Paris.

It is also possible to search for a substring that is [anywhere inside](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB):

    way[name~"Noether"];
    out geom;

Write down the substring without any extra special characters for this purpose.

It is slightly more difficult
to search for two (or more) substrings, e.g. first name and surname,
when one does not know what is between the two substrings.
The names _Emmy_ and _Noether_ appear as divided by a space as well as by a hyphen.
Regular expressions allow to state this by putting all acceptable characters in [a pair of brackets](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB):

    way[name~"Emmy[ -]Noether"];
    out geom;

Alternatively, one can admit [any single character](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB):

    way[name~"Emmy.Noether"];
    out geom;

The single dot `.` does the job.
In a regular expression, a dot means
that every string with an arbitrary character at this position is a match.

Sometimes it is necessary to admit [any number of](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB) characters.
One actually searches for two separated substrings.
An example is the composer and musician _Bach_;
he has beside _Johann_ more first names:

    way[name~"Johann.*Bach"];
    out geom;

The two characters dot `.` and asterisk `*` shape that search term.
The dot matches an arbitrary character,
and the asterisk means
that the expression before (here `.`) may repeat any times (not at all, once, or multiple times).

Another repetition operator is the question mark `?`.
Then the expression before (below `h` on first and `o` on second occurrence) may appear [not at all or once](https://overpass-turbo.eu/?lat=0.0&lon=0.0&zoom=1&Q=CGI_STUB).
This helps with _Gerhard_ respectively _Gerard_ respectively _Gerardo Mercator_:

    way[name~"Gerh?ardo?.Mercator"];
    out geom;

The last example covers a use case that will reappear [later on](union.md) with the combination operators:
Find a value [from a given list](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=CGI_STUB) like e.g. the standard values _trunk_, _primary_, _secondary_, _tertiary_ for arterial streets!

    way[highway~"^(trunk|primary|secondary|tertiary)$"]({{bbox}});
    out geom;

We focus on the filter `[highway~"^(trunk|primary|secondary|tertiary)$"]`.
The tilde `~` indicates the regular expression.
In the regular expression the caret at the beginning and the dollar sign at the end enforce
that the full _value_ and not only a substring is a match to the search term.
The pipe sign `|` represents the logical _or_,
and the parentheses cater for
that caret and dollar sign apply to the full expression and not only one of the alternatives.

<a name="per_key"/>
## Per Key

It is also possible to search for the presence of a key only.

In most cases there are so many objects with a given key
that it makes sense to combine the criterion with a spatial criterion,
e.g. [all named objects in inner London](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[name](51.5,-0.11,51.52,-0.09);
    out geom;

We make the spatial selection by the bounding box `(51.5,-0.11,51.52,-0.09)`.
The criterion for the key is `[name]`, i.e.
the key in brackets.
It usually shall be in quotation marks.
But it can be written without if the key name does not contain special characters.
So many many large relations have a `name` tag as well
that on purpose only nodes and ways are selected.
This is accomplished by `nw`.

The criterion to search for a key can be freely combined with any other criterion.

For the sake of completeness, an example for a key criterion [without](https://overpass-turbo.eu/?lat=15&lon=0&zoom=2&Q=CGI_STUB) a spatial criterion:

    nw["not:name:note"];
    out geom;

We need quotation marks here because the key contains the special character `:` (double colon).

There is a certain convention in OpenStreetMap to construct special keys with double colons,
and it can be hard to list all possible variants and verify that the list is complete.
As a remedy, it is possible to use regular expressions to match keys as well.

We make a first attempt to find all objects that have multilingual names,
i.e. have a key that starts with `name`,
again in [inner London](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[~"^name"~"."](51.5,-0.11,51.52,-0.09);
    out geom;

The most important characters here are the two tildes `~`.
The first tilde before the first string indicates
that we want to match the key by the regular expression in the first string,
and the second tilde between the two strings indicates
that the second string is a regular expression to match the value.
There is no syntax variant to have a regular expression for the key only,
but the single dot `.` will anyway match any actual value.

We want to match only keys that start with `name`.
Thus there is a caret at the head of the first string as the usual syntax rule for regular expressions.
The result looks quite similar to the previous result.

The reson for this is that `name` is of course also a key that starts with `name`,
and few objects have multilingual names but no `name` tag.
Fortunately, the multilingual names have the form `name:XXX`,
i.e. it is asserted that `name` is followed by a double colon.
This outlines the [multilingually named objects](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[~"^name:"~"."](51.5,-0.11,51.52,-0.09);
    out geom;

The colon does not have a special meaning in regular expression syntax
thus can simply be appended to `name`.

The value part of the syntax can be used to actually restrict the allowed values.
We can e.g. select all objects that have [some bicycle prohibition](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[~"bicycle"~"^no$"](51.5,-0.11,51.52,-0.09);
    out geom;

Again, the two tilde syntax is used.
Now the value part `^no$` start with a caret and ends with a dollar sign
to restrict the allowed values to exactly `no`.

The majority of the results are oneway that are open to bicycles, i.e. the tag `oneway:bicycle=no`.
Or in other words, not a bicycle restriction at all.
To exclude objects that have a tag with key `oneway`, it is possible to [use the negated key criterion](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[~"bicycle"~"^no$"][!oneway](51.5,-0.11,51.52,-0.09);
    out geom;

This differs from the positive key criterion
by having a shrek after the opening bracket and before the string specifying the key.

In principle, it is possible to relax the criterion to match case insensitive.
This is [switched for both](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB) key and value expression together:

    nw[~"^name:"~".",i](51.5,-0.11,51.52,-0.09);
    out geom;

The `,i` at the end of the criterion is the switch.
However, there is no discernible difference.

This is somewhat expected as keys by convention are made of lower case letters in OpenStreetMap.
We can nonetheless search for [objects with keys that contain uppercase letters](https://overpass-turbo.eu/?lat=51.51&lon=-0.1&zoom=14&Q=CGI_STUB):

    nw[~"[A-Z]"~"."](51.5,-0.11,51.52,-0.09);
    out geom;

The regular expression `[A-Z]` matches all strings that contain at least one uppercase letter.

<a name="numbers"/>
## Per Number

...
