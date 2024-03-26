Component Overview
==================

This page gives an overview
which files exist in Overpass related directories,
which processes run during executing an Overpass API instance,
and how the parts work together.

<a name="directories"/>
## Directories and Overview

TODO

<a name="processes"/>
## Running Processes

For an Overpass API endpoint that is accessible over HTTPS (or HTTP) you need two things:

- Daemons that enable access to the database files and coordinate that with updates, thus constitute the database engine.
- A web server that terminates the HTTPS connections and forwards them by CGI to the database engine.

The `dispatcher` is a permanently running daemon.
It coordinates requests and updates and prevents requests from reading inconsistent data,
i.e. basically all other processes are unable to start if the dispatcher is down.
A sole exception is running `osm3s_query` with an extra `--db-dir=$DIR` parameter:
in that case the `osm3s_query` is run against the database in the given directory under the assumption that no concurrent updates take place.

The dispatcher can be shut down by calling `dispatcher --osm-base --terminate` on the command line or by sending a SIGTERM to it.
In both cases it will notify a running `update_database` to shutdown to ensure a proper shutdown of everything.

It is quite common that two `dispatcher` are running. The second instance needs to be started to coordinate the creation and upates of areas.
The two can be discerned by that one runs with the argument `--osm-base` and the other with `--areas`.
This dispatcher can be shut down by calling `dispatcher --areas --terminate` on the command line or by sending a SIGTERM to it.

The update process is performed by having the bash scripts `fetch_osc.sh` and `apply_osc_to_db.sh` run permanently.
An alternative update process is performed by the having the bash script `fetch_osc_and_apply.sh` run permanently.
The former pair keeps the minute diffs while the latter single process discards the downloaded OSC files after successfully applying them.
These processes call `update_database` to apply the downloaded files to the database.
All of these processes can be safely shutdown by sending a SIGTERM to one of them.
The process `update_database` get notified by `apply_osc_to_db.sh` resp. `fetch_osc_and_apply.sh` when those are shutdown,
and in turn `apply_osc_to_db.sh` resp. `fetch_osc_and_apply.sh` watch whether `update_database` has been shutdown and follow that suit.

The permanent process for the area updates is `rules_loop.sh` or `rules_delta_loop.sh`.
Both of them periodically start an worker process `osm3s_query --rules`, and that process does the actual area updates.

You may see a couple of usually short lived processes called `interpreter`.
These are the worker processes called from the web server by CGI to run the actual requests.

<a name="bin"/>
## Files in *bin*

The files in the `bin` directory are those
that are designed to run permanently or are needed sometimes for auxiliary jobs.
Only a subset is necessary for the standard running instances,
many are there to keep up backwards compatibility.

The two files that are most essential are `dispatcher` and `update_from_dir`.

The `dispatcher` coordinates running requests and updates and is therefore inevitable in any typical system.
So is the binary `update_from_dir` which is called from both of the provided update mechanisms.

The update process on the public instances keeps the downloaded minute diffs to allow for forensics if the system crashed.
This update process is performed by having the bash scripts `fetch_osc.sh` and `apply_osc_to_db.sh` run permanently.
An alternative update process is performed by the bash script `fetch_osc_and_apply.sh`.
This update process discards the downloaded minute diffs once they have successfully been applied.

Both update mechanisms make every minute use of `update_from_dir` and use `migrate_database` once after startup
to bring the database format to the version that is supported by the used software version for updates.

The binary `osm3s_query` is equivalent to the interpreter endpoint for the supported query language
but designed for use at the command line.

The bash scripts `rules_loop.sh` and `rules_delta_loop.sh` perform the updates for the generated, relation based areas.
They rely on `osm3s_query`.
These are again alternatives to each other:
while `rules_loop.sh` will always generate all areas from scratch,
the script `rules_delta_loop.sh` regenerates only those areas of which the uderlying data has changed.

Finally, the bash script `download_clone.sh` shall be executed to download a copy of the database.
As this is a very large download it is designed to run only once and afterwards keep the database up to date with minute diffs.

These are the files that are useful for a standard Overpass API instance.
From here on follow a couple of files which offer features for special interest only or manual maintenance.

The binary `update_database` allows to update or to initially set up the database from a single OSM or OSC XML file.
It is used to create a database from a planet file.

The script `clone.sh` is the server end of the clone mechanism and creates a consolidated copy of the database.

The binary `translate_xapi` is a helper for the XAPI compatibility layer.
It translates the XAPI query language to the Overpass XML query language.

The three binaries `bbox_brim_query`, `draw_route_svg`, and `sketch_route_svg` are helpers for the line diagram feature,
see below in the `cgi-bin` directory.

The three binaries `escape_xml`, `tocgi`, and `uncgi` are further helpers
for both the XAPI compatibility layer as well as for the line diagram feature.
They may be useful to perform what they are called in isolation, i.e. URL de- or encode for debugging purposes.

The two scripts `init_osm3s.sh` and `run_osm3s_minutely.sh` are convenience scripts
and have been used on the French public instance.
The script `reboot.sh` has been used in the past to enable an automated restart after a reboot
but is currently unmaintained.

<a name="cgi-bin"/>
## Files in *cgi-bin*

The files in the `cgi-bin` subdirectory are exactly those
that can be executed via HTTPS.
Thus, they are called *endpoints*.
None of these executables is intended to run for a long time,
although `interpreter` may run quite long if there is a huge query for it.
All others should be quick, otherwise there is a malfunction.

The endpoint `interpreter` is the standard query util.
It has its name because it interprets the queries that are provided to it.

The endpoint `timestamp` informs whether the used database is current.
It returns the timestamp of the latest applied diff.

The endpoint `status` informs a single client about its quota status.
This includes some general information about the server as well to enable the client to detect outdated answers.
It is a bash script.

The endpoint `kill_my_queries` is the only endpoint with alters the state of the server.
It is intended to kill running queries of the same client.
Many clients are not able to stop a query reliably over HTTPS,
hence they can do so by this endpoint to relieve the server and save quota credits.
It is a bash script.

All other endpoints are special interest or legacy fetures outside the scope of the core Overpass API.
In particular, all of them are bash scripts.
All of them can be safely removed in a private instance unless the specific functionality is desired.

The endpoint `map` is a compatibility layer for the [export feature](https://openstreetmap.org/export) of the OpenStreetMap main website.
It is a bash script to wrap the actual request for a given bounding box.

The endpoint `convert` helps to convert between the older XML based query language and the newer OverpassQL query language.
It is a bash script to call `osm3s_query` with appropriate parameters to do the actual conversion.

The endpoints `convert_xapi`, `xapi` and `xapi_meta` are compatibility layers for a query language of the even older XAPI.
No productive use of XAPI since about a decade is known, so this is now really a matter of legacy.

The endpoints `augmented_diff`, `augmented_diff_status` and `augmented_state_by_date` have been the first attempt to supply [Augmented Diffs](https://wiki.openstreetmap.org/wiki/Overpass_API/Augmented_Diffs).
These have been superseded by just using a proper query for it,
because the interplay of minute diffs and timestamps of objects is non-trivial.

The endpoint `template` has been used in the past to manage server side templates for custom output formats.
This had been a helper feature for the [Permanent Id](https://wiki.openstreetmap.org/wiki/Overpass_API/Permanent_ID) to control what is shown for disambiguation.
There has not been any activity to diversify these disambiguation pages,
so this feature got in the meantime unmaintained, while otherise the Permanent Id is fully operational.

The endpoints `draw-line`, `sketch-line`, `sketch-options`, and `sketch-route` allow to show public transit routes.
Of these, `sketch-line` can be accessed via [this form](http://overpass-api.de/public_transport.html) on the public instances.
It calls `osm3s_query` and `sketch_route_svg` from the *bin* directory.
The other three endpoints do so as well, but are rarely used.

The endpoint `trigger_clone` shows the directory you can start to download a clone from.
This works only if the server is configured to offer clone, i.e. only for the [dev instance](https://dev.overpass-api.de/).

<a name="database-dir"/>
## Files in the Database Directory

During normal operations, more than 100 files are in the database directory.
They can be grouped most easily by looking at their extensions:

- files with file extension `bin` contain the actual payload data.
  They are read by `interpreter` and `osm3s_query` and written by `update_database` and `update_from_dir`.
  Those of the *bin* files that store derived area data are also read by `interpreter` and `osm3s_query`,
  but written by `osm3s_query --rules` with the updated areas.

- files with file extension `map` contain index data
  such that from any element (node, way, relation) id the geographical index of the full element can be found.
  These files are also read by `interpreter` and `osm3s_query` and written by `update_database` and `update_from_dir`.

- files with extension `idx` contain index data to allow finding the right file data box for a given geographical index.
  Each *idx* file corresponds to exactly one *bin* or *map* file by having the file extension `.idx` attached.
  The *idx* files are also read by `interpreter` and `osm3s_query` but only and fully on startup.
  A running update process (i.e. `update_database` or `update_from_dir`) does not write directly to these files
  but instead the dispatcher moves the temporary *shadow* files (see below) in place once an update succeeded.

- files with extension `shadow` are temporary files during an update process.
  These files are used by the updating process to ensure that no conflicts with concurrent reading processes arise.

We discuss the other file types further below.

<a name="update-mechs"/>
### The Update Mechanics

...

<a name="layers"/>
### Payload vs Meta vs Museum vs Areas

````
area_blocks.bin
areas.bin
area_tags_global.bin
area_tags_local.bin
node_attic_indexes.bin
node_changelog.bin
node_frequent_tags_attic.bin
node_frequent_tags.bin
node_keys.bin
nodes_attic.bin
nodes_attic_undeleted.bin
nodes.bin
nodes_meta_attic.bin
nodes_meta.bin
node_tags_global_attic.bin
node_tags_global.bin
node_tags_local_attic.bin
node_tags_local.bin
relation_attic_indexes.bin
relation_changelog.bin
relation_frequent_tags_attic.bin
relation_frequent_tags.bin
relation_keys.bin
relation_roles.bin
relations_attic.bin
relations_attic_undeleted.bin
relations.bin
relations_meta_attic.bin
relations_meta.bin
relation_tags_global_attic.bin
relation_tags_global.bin
relation_tags_local_attic.bin
relation_tags_local.bin
user_data.bin
user_indices.bin
way_attic_indexes.bin
way_changelog.bin
way_frequent_tags_attic.bin
way_frequent_tags.bin
way_keys.bin
ways_attic.bin
ways_attic_undeleted.bin
ways.bin
ways_meta_attic.bin
ways_meta.bin
way_tags_global_attic.bin
way_tags_global.bin
way_tags_local_attic.bin
way_tags_local.bin

nodes_attic.map
nodes.map
relations_attic.map
relations.map
ways_attic.map
ways.map
````

<a name="db-other"/>
### Other Files in the Database Directory

````
apply_osc_to_db.log
area_version
augmented_diffs
base-url
database.log
osm3s_areas
osm3s_osm_base
osm_base_shadow.status
osm_base_version
replicate_id
rules
server_name
templates
transactions.log
````

<a name="other_files"/>
## Other Files

osc
munin
TODO

<a name="other_other"/>
## Other Objects

TODO
/dev/shm
OVERPASS_X_DIR
