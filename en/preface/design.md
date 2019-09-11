Run time model
==============

By which rules Overpass API executes a request?
Presenting each building block creates the insight
how these building boxes together are effective as a request.

<a name="sequential"/>
## Sequential Execution

Most sophisticated use cases for requests require to select elements relative to previous results.
A good example is supermarkets that are close to a railway station.
The supermarkets are related to the railway stations only by spatially being close to it.

According to the sentence structure
we first search supermarkets
then only keep supermarkets in the selection for which we have found a station nearby.
This approach in natural language quickly ends up in the muddle of relative sentences,
and in a formal language this is not less annoying.

Therefore the query language of Overpass API adheres to a step-by-step paradigm,
the so-called _imperative programming_.
At each point in time only a simple task is processed
and the complex tasks are accomplished by enqueuing multiple simple tasks.
This brings us to the following approach:

* Select all stations in the region of interest.
* Replace the selection by the supermarkets close to objects in the found result.
* Print the list of found supermarkets.

Line by line this results in the following query.
You can [execute](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=13&Q=nwr%5Bpublic_transport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%3B%0Anwr%5Bshop%3Dsupermarket%5D%28around%3A100%29%3B%0Aout%20center%3B) it right now:

    nwr[public_transport=station]({{bbox}});
    nwr[shop=supermarket](around:100);
    out center;

The details of the syntax are later explained.

For simpler cases one may want a simpler syntax,
but the resulting two-line-solution reflects the clear separation of duties:

    nwr[shop=supermarket]({{bbox}});
    out center;

* The selection statement in the first line selects _what_ is returned
* The output statement commands _how_ the objects are returned. Details about that in the section [Formats](../targets/formats.md#faithful)

<a name="statements"/>
## Instructions and Filters

We compare the request for simply the supermarkets in the visible bounding box

    nwr[shop=supermarket]({{bbox}});
    out center;

with the request from above

    nwr[public_transport=station]({{bbox}});
    nwr[shop=supermarket](around:100);
    out center;

to identify the components.

The most important character is the semicolon;
every statement always ends with a semicolon.
By contrast, whitespace (line breaks, spaces, and tabs) are for the entire syntax irrelevant.
The statements are executed one after another in the order in which they are noted.
In both requests together, there are four distinct statements:

* ``nwr[shop=supermarket]({{bbox}});``
* ``nwr[public_transport=station]({{bbox}});``
* ``nwr[shop=supermarket](around:100);``
* ``out center;``

The statement ``out center`` is an output statement without further substructures.
The possibilities to control the output format are elaborated in section [Formats](../targets/formats.md).

All the other statements are _query_ statements, i.e. they select objects.
This applies to all statements starting with ``nwr`` and further keywords:
The keywords ``node``, ``way``, and ``relation`` select the respective type of object,
and ``nwr`` (abbreviating _nodes_, _ways_, and _relations_) admits all types of objects in the result.
The _query_ statements have substructures appearing multiple times:

* ``[shop=supermarket]`` and ``[public_transport=station]``
* ``({{bbox}})``
* ``(around:100)``

All substructures of a _query_ statement constraint which objects are found.
Therefore, they are called _filters_.
It is possible to combine any number of filters in a statement.
The _query_ statement selects exactly those objects that match all filter conditions.
The order of the filters does not play any role
because the filters are from a technical perspective applied in parallel.

While ``[shop=supermarket]`` and ``[public_transport=station]`` admit all objects
that carry a specific tag (supermarkets in one case, railway stations in the other),
the filters ``({{bbox}})`` and ``(around:100)`` perform spatial filtering.

The filter ``({{bbox}})`` matches exactly those objects
that are fully or partially inside the supplied bounding box.

A little bit more complicated works the ``(around:100)`` filter.
It needs as input the previous result,
then it accepts all objects that have to any of the given objects a distance of at most 100 meters.

Here the step-by-step paradigm kicks in:
The filter ``(around:100)`` gets in the given request as input exactly the railway stations
that have been found by the preceding statement.

<a name="block_statements"/>
## Block statements

How to connect two statements by or?
[This way](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=%28%0A%20%20nwr%5Bpublic%5Ftransport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20nwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%29%3B%0Aout%20center%3B) one finds all objects that are a supermarket or are a railway station:

    (
      nwr[public_transport=station]({{bbox}});
      nwr[shop=supermarket]({{bbox}});
    );
    out center;

Here, the two _query_ statements constitute a block within a larger structure.
Therefore, the structure marked by parentheses is called _block statement_.

This special block structure is called _union_
and it serves to connect multiple statements such
that it selects all objects that are selected by any statement within the block.
There must be at least one statement within the block and there can be an arbitrary number.

There are many other block statements:

* The block statement _difference_ offers to cut out a selection out of another selection.
* _if_ executes its block only if the condition in the head of _if_ evaluates to true.
  Also, an addition block with statements can be provided that is executed if the condition evaluates to false.
* _foreach_ executes its block once for every object in its input.
* _for_ first combines the objects to groups and then executes its block once per group.
* _complete_ acts in place of a _while_ loop.
* Further block statements offer to get back deleted objects or outdated versions of objects.

<a name="evaluators"/>
## Evaluators and Derived Elements

We haven't said yet
how to state conditions in the block statements _if_ or _for_.

The mechanism used for this is helpful also for other tasks.
You can e.g. create with this [a list of all street names](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28name%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%3B%0A%20%20out%3B%0A%7D) within an area.

    [out:csv(name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val;
      out;
    }

Lines 2 and 6 contain the simple statements ``way[highway]({{bbox}})`` resp. ``out``.
With ``[out:csv(name)]`` in line 1 the output format is controlled ([see there](../targets/index.md)).
The lines 3, 4, and 7 constitute the block statement ``for (t["name"])``;
it needs to know by which criterion it should group the elements.

This is answered by the _evaluator_ ``t["name"]``.
An _evaluator_ is an expression
that is evaluated in the context of the execution of a statement.

This particular evaluator is an expression that is evaluated once per each selected object
because _for_ needs one result for each selected object.
The expression ``t["name"]`` evaluates for a given object the value of the tag with key _name_ of that object.
If the object does not have a tag with key _name_
the expression returns an empty string.

Line 5 also contains with ``_.val`` an _evaluator_.
Its purpose is to generate the value that shall be printed.
The statement _make_ always generates one object from potentially many objects.
Therefore the value of ``_.val`` cannot depend on individual objects.
This special expression ``_.val`` delivers within a _for_ loop the value of the expression
for which the loop is performed.
In this case this is the value of the tag _name_ of all here processed objects.

If an object independent value is expected, but an object dependent expression is supplied,
then an error message is created.
This happens for example, if we want to compute the length of all streets:
[Please try](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dlength%28%29%3B%0A%20%20out%3B%0A%7D)!

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=length();
      out;
    }

The multiple segments of a street of the same name can have different lengths.
We can fix this by providing instructions in which way the objects shall be conflated.
Often one wants [a list](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dset%28length%28%29%29%3B%0A%20%20out%3B%0A%7D):

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=set(length());
      out;
    }

But in this particular case taking the sum [makes more sense](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=%5Bout%3Acsv%28length%2Cname%29%5D%3B%0Away%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dsum%28length%28%29%29%3B%0A%20%20out%3B%0A%7D):

    [out:csv(length,name)];
    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=sum(length());
      out;
    }

The statement _make_ creates always exactly one new object, a so-called _derived_.
Why generate an object at all?
Why not just take an OpenStreetMap object?
The reasons for this vary from application to application:
here we need something that we can print.
In other cases one wants
to change or remove tags from OpenStreetMap objects,
or to simplify the geometry,
or needs a carrier to transmit special information.
Quasi OpenStreetMap objects would have to adhere to the rules of OpenStreetMap objects
and do not allow for in those cases helpful degrees of freedom.
More importantly, they could be confused with actual OpenStreetMap objects and uploaded on accident.

You can see the created objects if you [keep XML](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=16&Q=way%5Bhighway%5D%28%7B%7Bbbox%7D%7D%29%3B%0Afor%20%28t%5B%22name%22%5D%29%0A%7B%0A%20%20make%20Beispiel%20name%3D%5F%2Eval%2Clength%3Dsum%28length%28%29%29%3B%0A%20%20out%3B%0A%7D) as the output format:

    way[highway]({{bbox}});
    for (t["name"])
    {
      make Beispiel name=_.val,length=sum(length());
      out;
    }

<a name="sets"/>
## Multiple selections in parallel

In many cases, a single selection does not suffice to solve the problem.
Therefore, selections can also be stored in named variables
and thus multiple selections can be kept in parallel.

We want to find all objects of one kind
that are not close to objects of another kind.
Practical examples are often quality assurance,
e.g. railway platforms distant from railways, or addresses far away from any street.
Understanding the fine print of tagging goes beyond the scope of this section.

Instead, we determine all supermarkets
that are [not close to](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=14&Q=nwr%5Bpublic%5Ftransport%3Dstation%5D%28%7B%7Bbbox%7D%7D%29%2D%3E%2Eall%5Fstations%3B%0A%28%0A%20%20nwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0A%20%20%2D%20nwr%2E%5F%28around%2Eall%5Fstations%3A300%29%3B%0A%29%3B%0Aout%20center%3B) railway stations:

    nwr[public_transport=station]({{bbox}})->.all_stations;
    (
      nwr[shop=supermarket]({{bbox}});
      - nwr._(around.all_stations:300);
    );
    out center;

In line 3 the statement ``nwr[shop=supermarket]({{bbox}})`` selects all supermarkets in the bounding box.
We want to remove a subset from these and thus we use a block statement of type _difference_;
it can be recognized by the three components ``(`` in line 2, ``-`` in line 4, and ``)`` in line 5.

We must select all supermarkets close to stations.
For this purpose, we must select all stations first,
but we also need all supermarkets as selection.
Therefore, we redirect the selection of all stations through the _set variable_ ``all_stations``.
The selection is redirected in line 1 from a colloquial statement ``nwr[public_transport=station]({{bbox}})``
by the special syntax ``->.all_stations`` into the variable in question.
The amendment ``.all_stations`` in ``(around.all_stations:300)`` instructs the filter
to use the variable as source instead of just the last selection.

Thereby ``nwr[shop=supermarket]({{bbox}})(around.all_stations:300)`` is the right statement
to select exactly the supermarkets that we want to remove.
To speed up the request, we rather use the selection of the previous statement in line 3 -
there already are selected all supermarkets in the bounding box.
This happens with the _filter_ ``._``.
It restricts the selection to those objects
that are already in the default selection at the beginning of the execution of the statement.
Because we use the standard input here,
we can address it by its name ``_`` (simple underscore).

The flow of data during the execution of the request in full detail:

* Before the begin of the execution all selections are empty.
* Line 1 is executed.
  Controlled by ``->.all_stations``, all stations are afterwards selected in the variable ``all_stations``,
  and the default selection remains empty.
* Lines 2 to 5 are a block statement of type _difference_,
  and this block statement first executes its block of statements.
  Thus, the next statement to execute is line 3 ``nwr[shop=supermarket]({{bbox}})``.
  Line 3 carries no redirection,
  hence after the execution all supermarkets are selected in the default selection.
  The selection ``all_stations`` is not mentioned and therefore remains unchanged.
* The block statement _difference_ copies the result of its first operand,
  this is line 3.
* Line 4 uses the default selection as restriction,
  and in addition in the constraint ``(around.all_stations:300)``
  the selection ``all_stations`` is used as the source for the reference objects.
  The result is the new default selection and replaces the previous default selection.
  The selection ``all_stations`` remains unchanged.
* The block statement _difference_ copies the result of its second operand,
  this is line 4.
* The block statement _difference_ now calculates the difference between the two collected selections.
  Because nothing else is specified,
  the result becomes the new default selection.
  The selection ``all_stations`` remains unchanged.
* Finally, line 5 is executed.
  Without any explicit instruction, the statement ``out`` uses as source the default selection.
