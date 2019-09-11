Assertions
==========

The Overpass API will specific tagging schemes neither promote nor hamper.
It is intended to be backwards compatible for decades.

<a name="local"/>
## Locally Fast

The Overpass API is designed
to be quick to deliver data that is spatially close to each other.
Spatially disperse data can be delivered by the Overpass API as well,
but then it has no longer any advantage over a generic database.

Therefore, in many places in this manual
you will be deferred to one of the many other OpenStreetMap tools
if it is stronger optimized for the respective purpose.

<a name="faithful"/>
## Faithful to the Data Model

The data model of OpenStreetMap has, by its simplicity,
substantially contributed to the success of OpenStreetMap.
But for virtually every use case, one must convert the data to a different data model,
because otherwise the processing times would be too high.
This applies in particular to the rendering of a map and even more to routing and POI search.

None of these conversions are lossless,
every data model emphasizes some aspects, ignores other aspects and interprets the rest in the best possible way.
Thus, even a representation that is as faithful to reality as possible
may lead in the map, at routing and in other use cases to unexpected results.

Many mappers quite often address this by mis-mapping facts
that deliver in exchange for more desired results in the tool of choice.
The mapper rarely recognizes that the results are, that way, worse in other tools.
This practice is referred to by the expression [(mis-)mapping for the renderer](https://wiki.openstreetmap.org/wiki/Tagging_for_the_renderer).

The problem is that mapping against the facts in then promoted by a pretty map appearance
and faithful mapping is discouraged by an ugly map appearance.
For a third party the mapper has a hard time to proof that he indeed models faithfully.

Therefore, the Overpass API operates on the original data model:
It is precisely the mission of the Overpass API to show the data as it is modeled in OpenStreetMap.

This shifts the burden:
actually faultily modeled data can be demonstrated to be flawed.
For faithfully modeled data, it can be verified,
and it at least can be shown the full context.

<a name="tags"/>
## Tagging Neutrality

It is a trait of mankind that quickly occurs the opposite phenomenon:
Prophets pop up to spread the doctrine they believe were immaculate.

An example is multipolygons:
The problems to solve are
to model on the one hand areas with holes
and on the other hand areas that intrinsically and actually touch each other.
E.g. countries fill the complete landmass, i.e. any border is always the border of multiple countries.
To model that with closed ways only is not possible.

From the use case _holes_ the convention remained
that the tags are placed on the outer ring way.
This largely came from that the renderer had difficulties with relations.
Concurrently, some users have difficulties with certain particularities,
and that repeatedly has been an issue under the headline _touching inner rings_.

In total, multipolygon relations are a recurring subject
and editing them still requires good knowledge.

Some mappers have misunderstood this
such that multipolygon relations were the somewhat more mighty object,
and they have converted simple ways to multipolygons.
But this does not have any benefit
and both hampers the editing and bloats the database.

There are many controversies in other subjects:

* Footway in parallel to carriageways can be modeled as separate ways,
  or they can be by a complex system of rules represented by tags on the carriageway
  or one can restrict implicit modeling to simple cases with no potential to misunderstandings.
* In streets either all parts of the street can get a name.
  Or one restricts the name to at most one carriageway per direction of the method of transport with highest speed.
* In buildings with shops the shop can be the same object as the building or just a node in the building.
  The address can be mapped on only one of the two objects or on both.

To ensure that I create a universally useful tool
I keep it out of such dissents as much as possible.

For this reason the Overpass API is strictly tagging neutral,
i.e. no tag gets special treatment.

<a name="antiwar"/>
## Immutability

Another problem in this context is the ambition
to automatically change the data.
Although the idea sounds compelling,
it causes [many problems](https://2016.stateofthemap.org/2016/staying-on-the-right-side-best-practices-in-editing/).

For this reason the Overpass API does not support
to rewrite OpenStreetMap objects on the fly.
For the clearly existing and clearly justified need
to rewrite objects
the class of _deriveds_ has been introduced.
These are sufficiently different from OpenStreetMap objects
such that they cannot be directly written back.

Edits with various degrees of automation can still profit from the Overpass API.
Examples of this can be found in the section [JOSM](../targets/index.md).

<a name="ql"/>
## Versatile Query Language

Geodata bears its own intrinsic ordering criterion by _spatial proximity_.
For this reason they do not fit in any category
that is catered for by any well established query language.
For this reason Overpass API at all brings its own query language.

The query language is not only geared to use spatial proximity,
but can also accommodate for all of the particularities of the OpenStreetMap data model.
It is also crafted to ensure
that queries behave sane and nice on a publicly shared server,
i.e. neither huge attack surfaces exist, nor performance problems shall occur.

Finally, it turned out
that the OpenStreetMap community wants and profits from well complex searches.
They are catered for
by making the language as logically rigid and orthogonal as possible
such that nearly anything can be combined with anything.

<a name="infrastructure"/>
## Infrastructure

The Overpass API is designed to be infrastructure.
Thus, it is neither an end user software, nor a prototype.

Decisions on interfaces, in particular regarding the query language,
and over required dependencies are likely to have an impact for decades.
For this reason, alterations are introduced cautiously
and not before a form is found that can persist in the long run.

To be an infrastructure connected to the internet means
one must retain a sane load management even in the face of insane patterns of requests.
More on this in the [next section](commons.md#magnitudes).

<a name="libre"/>
## Free and Open

The Overpass API shall be held against the [four freedoms](https://www.gnu.org/philosophy/free-sw.html) of open source.

### Execute, Distribute

For this aim it does not suffice to offer the public instances,
because they have inevitably finite capacity.

Only with the publication of the [source code](https://github.com/drolbr/Overpass-API) in a form
that makes the [installation of independent instances](https://dev.overpass-api.de/no_frills.html) simple
the freedoms are warranted.
This includes designing the software such that eligible hardware is easy to obtain.

### Adapt, Modify

Here the [source code](https://github.com/drolbr/Overpass-API) is the essential ingredient.
The [license](https://github.com/drolbr/Overpass-API/blob/master/COPYING) caters for the legal side.
