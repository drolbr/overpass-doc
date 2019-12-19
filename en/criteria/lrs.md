List represented sets
=====================

Tools to make sense of tags representing multiple values.
This evolved in OpenStreetMap into representation as comma separated lists.

<a name="intro"/>
## Multiple values

In some cases it is necessary in OpenStreetMap
to record on an object for a single _key_ multiple different _values_.
An example are multi-storey structures:
Even if each element viewed alone resides usually on a single level,
stairs and elevators have as purpose to connect multiple levels.
Thus, they occupy space in two or more different levels.

A similar need pops up
when the operator of a street has assigned to a section multiple road numbers.
Multiple house numbers on a building or site [exist as well](https://overpass-turbo.eu/?lat=51.5&lon=0.0&zoom=13&Q=CGI_STUB):

    nwr["addr:housenumber"~";"]({{bbox}});
    out center;

The de facto standard for multiple values for the same _key_ is
that the values are all written down in the value and separated by semicolons.
This is a problem for multiple reasons:

First of all, a semicolon is a valid character within the _value_
such that a value that incidentally contains a semicolon gets forcibly split
if treated with an always splitting software.
This may happen inside or outside OpenStreetMap:
The semicolon is an established separator in popular formats like CSV as well.

Next, it must be reconstructed from the context whether the order of the elements matters.
Examples like the values `-2;-1` and `-1;-2` for the tag with key _level_ suggest
that the answer is no.
By contrast, for keys for sea marks or trail markers,
values like `red;white;blue` do differ in meaning from values like `blue;red;white`.

To store the order creates effort:
even for 15 items one only needs 2 bytes to indicate presence or absence for each
but 5 bytes to store a specific order.

Other questions occur in addition:

* Are `-1` and `-1.0` the same values?
* What about leading or trailing whitespace?
* What does it mean if a second semicolon follows the first with no characters in between?

I have set conventions valid for the Overpass API
that I expect to meet the contemporary usage the best possible:

_All values of tags are treated as atomic and semicolons have no special meaning,
unless a semicolon aware function is applied on the value.
Such functions may or may not ignore leading and trailing whitespace in each chunk.
If the resulting list contains only numbers,
then the functions may treat number of equal value as identical and may order by numerical value._

In the following sections we introduce the functions with the help of typical examples:

* How can we find all objects for that in its tag X occurs a given value Y?
* How can we find all objects for that in its tag X occurs at least one of a bunch of given values?
* How can one list all values occuring in one or more of multiple objects in the tag X?

Some of the features for analyzing the data also create semicolon separated lists.
This and how to handle those is explained [there](../analysis/index.md).

<a name="single"/>
## Searching for a Single Value

We pursuit to find all stairs that touch level `-2` in one of the most important tube stations of London (_Bank_ and _Monument_).
The search for _only the value_ [does not find anything](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way[highway=steps][level=-2]({{bbox}});
    out center;

The idea to use a regular expression comes to mind.
But this is at best substantially unwieldy and is not elaborated on here.
Please note that such a regular expression is prone to match values like `-2.3` or `-2.7`;
and these values exist here in the data.

Instead, exactly the objects that have the value `-2` directly or indirectly in a semicolon list
[are selected](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB) by the semicolon aware function `lrs_in`:

    way[highway=steps]({{bbox}})
      (if:lrs_in("-2",t["level"]));
    out center;

Objects with _values_ like `-2;-1` or `-3;-2` are found by the request as well as the _value_ `-2` alone.

In particular:
Lines 1 and 2 together form a _query_ statement with in total three filters.
We discuss only the filter `(if:lrs_in("-2",t["level"]))` here.
The shell `(if:...)` is the generic filter
that evaluates for each object [the evaluator](../preface/design.md#evaluators) supplied as argument.
The filter selects exactly the objects for which the evaluator computes something different from `0`, `false` or the empty value.
We screen the objects with the evaluator `lrs_in("-2",t["level"])`.
It has two arguments:

* the first argument, here the constant `-2`, is the value to find in the list.
* the second argument, here the expression `t["level"]`, is the list to search.

Thus, this encodes the instruction:
Request all _ways_ (`way`) within the bounding box (`({{bbox}})`) with _value_ `steps` for the _key_ `highway`
that contain in the value for the key `level` interpreted as a semicolon separated list the value `-2`.

All semicolon aware functions start with the prefix `lrs_`;
it stands for _list represented sets_.

Please note that the filter `(if:...)` is a so called _weak_ filter
and cannot be used as a standalone filter
because then worldwidely all objects would have to be screened whether they might match.
The following attempt to query worldwide results in [an error message](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way(if:lrs_in("-2",t["level"]));
    out center;

For almost all use cases this is not a problem,
because another constraint manifests anyway as a strong filter, e.g. the bounding box.
For most of the other cases, the additional filter `[level]` for [the presence of the key only](todo.md) can serve as a strong filter.
Specifically for `level`, this approach does not make sense
because due to the large number of matching objects,
a lot of objects need to be inspected.
Finally, the amount of data is a challenge for the browser:
<!-- NO_QL_LINK -->

    way[level](if:lrs_in("-2",t["level"]));
    out center;

By contrast, for other tags this can be an appropriate solution.

The filter `[level]` used here for the first time is elaborated on in the [following section](misc_criteria.md#per_key).

If we conversely want to hide all stairs that end on level `-2`
then we [can request a logical negation](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB): by placing a shrek `!` in front of the evaluator:

    way[highway=steps]({{bbox}})
      (if:!lrs_in("-2",t["level"]));
    out center;

Please reflect whether you want to select stairs
that have no key `stairs` set at all.
Only stairs [with _level_](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=17&Q=CGI_STUB):

    way[highway=steps]({{bbox}})
      (if:!lrs_in("-2",t["level"]))
      [level];
    out center;

<a name="multiple"/>
## Searching for Multiple Values

<!-- Not yet checked -->

We search London for a restaurant with regionally typical cuisine.
It is unclear whether we shall query for `british`, `english`, or `regional`.

We could do so with an [_union_ statement](union.md#union) collecting [queries for all possible values](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB):

    (
      nwr[cuisine]({{bbox}})
        (if:lrs_in("english",t["cuisine"]));
      nwr[cuisine]({{bbox}})
        (if:lrs_in("british",t["cuisine"]));
      nwr[cuisine]({{bbox}})
        (if:lrs_in("regional",t["cuisine"]));
    );
    out center;

But this quickly gets large,
both for a bigger number of values as well as for other applications of a combination by _or_.

We rather use the semicolon aware function `lrs_isect` (_isect_ stems from _intersection_);
it [picks the common values](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB) of two semicolon separated lists:

    nwr[cuisine]({{bbox}})
       (if:lrs_isect(t["cuisine"],"english;british;regional"));
    out center;

The filter `(if:lrs_isect(t["cuisine"],"english;british;regional")` in line 2 deserves the attention:
The generic filter `(if:...)` again evaluates for each object
whether a value different from `0`, `false`, and the empty values results from evaluating.
The supplied evaluator `lrs_isect(t["cuisine"],"english;british;regional")` has two arguments.
It interprets both as lists (a value without a semicolon is a list with the value as the only one entry).
It returns the entries that occur in both lists,
i.e. it returns a nonempty value
if and only if one of the values `english`, `british`, or `regional` is contained in the list for the tag with key `cuisine`.

This becomes a complete request
by combining it with filters for the visible bounding box and general filter for the key `cuisine`.
Line 3 contains the print statement.

The function `lrs_isect` can be logically negated as well
to obtain boolean true exactly if `lrs_isect` delivers an empty list.

We let enumerate here [all occurring values](https://overpass-turbo.eu/?lat=51.512&lon=-0.0875&zoom=14&Q=CGI_STUB) for the purpose of illustration:

    [out:csv(cuisine, isect, negated)];
    nwr[cuisine]({{bbox}});
    for (t["cuisine"])
    {
      make info cuisine=_.val,
        isect="{"+lrs_isect(_.val,"english;british;regional")+"}",
        negated="{"+!lrs_isect(_.val,"english;british;regional")+"}";
      out;
    }

The details of the syntax are explained in the chapter [Analyzing Data](../analysis/index.md).
The column `cuisine` contains each value of the tag _cuisine_.
The column `isect` contains what `lrs_isect(_.val,"english;british;regional")` computes from this value.
For non-empty values you need to scroll a bit,
but they appear beginning from the values containing `british` on.
The column `negated` contains what the negation operator `!` converts the value of `isect` to.
The empty entry is inverted to `1`,
and any filled entry here is inverted to `0`.

<a name="all"/>
## All Values

...
