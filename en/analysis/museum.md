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

...

Diff
Adiff
compare

timeline
retro

<a name="josm"/>
## Unearthing with JOSM

Before you handcraft too much, a short reminder:
if your want to revert a complete changeset then the reverter plugin does this more reliable than manual work.

It is possible to edit removed data back into OpenStreetMap, although some caveats apply.
The basic process is to load the former data into JOSM and then copy over the elements one wants back to life.
Unless manual tweaking this applies new ids to the copied objects.

Make sure that you have turned on the Expert Mode in the JOSM settings.

Figure out the exact extent of the region (bounding box) and date that you want to reactivate data from.
Change the tab in the download dialogue to *Download from Overpass API*.
You can then download your data of interest with a request like

    [date:"$TIMESTAMP"];
    (
      nwr({{bbox}});
      node(w);
    );
    out meta;

This is the old data you can copy from.

Now go once again to the download dialogue and erase the request from the textfield.
This way you get the current data in the same bounding box.

You must download via *Download as a new layer*.
Only that way you have the current data in a proper data layer.

Now you can switch between the two layers by using the layers pane (Alt-Shift+L).
Turn the old state layer active by putting the check mark there and click if necessary the eye to get unobstructed view.
Copy from there what you want to reactivate. To save topology, do so in one step.
Turn the current state layer active by putting the check mark there and paste into that layer.

Now you have the reactivated objects as new objects there.
If they need to be welded into existing objects when do so now.
Finally, you can upload or complete the editing session with related edits.
As changesets should make clear intent, it is usually unhelpful
to mix a recontruction operation with genuinely new editing.
