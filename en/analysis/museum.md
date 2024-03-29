Working with Museum Data
========================

To make edits non-destructive,
data in OpenStreetMap is not truely deleted but superseded by newer versions.
We explain here the details about that mechanism
and how to retrieve other than recent data with the Overpass API.

<a name="date"/>
## A Point in Time

It is possible to retrieve old states of data.
A simple and illustrative example is to view [former buildings and highways](https://overpass-turbo.eu/?lat=51.525&lon=-0.25&zoom=16&Q=CGI_STUB) at the Old Oak construction site in London: 

    [date:"2018-01-01T00:00:00Z"];
    (
      way[highway]({{bbox}});
      way[building]({{bbox}});
    );
    out geom;

As you can see, some buildings match the background rendering, i.e. current buildings.
Some current buildings miss from the results which means that they have not been mapped at that date.
And some buldings no longer exist, as they had occupied the same space where now the construction site is situated.

You can play a little bit with the date (from 2013 to today) to see how the existing data varied.

<a name="timestamp"/>
## Timestamps vs Versions

...

<a name="foo"/>
## Foo

Diff
Adiff
compare

timeline
retro

<a name="josm"/>
## Unearthing with JOSM

Before you handcraft too much, a short reminder:
if your want to revert a complete changeset then the reverter plugin does this more reliable than manual work.

...
