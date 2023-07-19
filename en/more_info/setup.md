Installation of an Own Instance
===============================

How can I set up my own instance of the Overpass API
to be able to execute an arbitrary number of requests?

// Mention: wiki, blog
This installation guide assumes that

- You have already acquired a server with enough disk space (500 GB to 1 TB recommended).
- You have at least a basic understanding of the Bash and Linux or another POSIX compliant operating system.

You might want to look into alternative installation guides if either not both are true or you are just curious.
I've recommended two especially helpful ones in [this blog post](/blog/more_install_instructions_60.html).

There is also an [Installation Guide](https://wiki.openstreetmap.org/wiki/OSM3S/install) on the OpenStreetMap wiki,
although it has rather the character of troubleshooting.
Beware that many parts there might be outdated.

To complete cross-references, the Overpass API also can be installed [with Docker containers](https://github.com/drolbr/docker-overpass).

The essential three steps are:

1. install the software
2. import OpenStreetMap data
3. configure the service and the web server

The steps 1 and 2 should be distinct steps
because the amount of payload data is so big
that the most users will want to align their apporach on that.

There is also an extra section below to explain how the components work together.
This shall make it easier for you to write your own control scripts.

## Install the software

Please ensure that the GNU autotools, a C++ compiler, the auxiliary program _wget_ and the libraries _expat_, _zlib_, and _lz4_ are installed.
The versions of the programs do not matter.
The Overpass API only uses their version-independent core functionality.

For e.g. Ubuntu you can ensure as follows that all required programs are installed:

    sudo apt-get install wget g++ make expat libexpat1-dev zlib1g-dev \\
        liblz4-dev

Please download for the Overpass API the [latest release](https://dev.overpass-api.de/releases/),
called [`osm-3s_latest.tar.gz`](https://dev.overpass-api.de/releases/osm-3s_latest.tar.gz).
Older releases also do work but
due to the backward compatibility there will be next to never a reason to use an old release.
The installation and maintenance of the software has improved over time,
and older versions often will need special attention.

Unpack the downloaded gzip file and change into the created directory.

Then compile on the command line with

    ./configure --enable-lz4
    make
    chmod 755 bin/*.sh cgi-bin/*

The command in the third line constitutes the installation.
The rationale for enabling the build directory instead of installing to the system path
is to avoid needing root permissions.

Usually, a linux software would now be installed by the sequence `configure` . `make` - `make install`.
This final step copies the executable files into the standard program directory and sets their executable flag.
Unfortunately only user root has the necessary permissions to copy to there.
Thus we leave the executables where they have been compiled
and turn them executable by using `chmod`.

The executables can freely be moved around in the file system,
but some executables expect some of the other executables in the same directory than themselves or in `../bin`.
For this reason it is highly recommended to only move the directories `bin` and `cgi-bin` in their entirety and only together.

## Load the data

You can skip this step and create your own database if you want to use a local extract instead.

In contrast to the comparably little size of the software installation, the OpenStreetMap data is big.
All data worldwide need also with only the geodata and only the current one already 350 GB to 400 GB (as of 2023).
Together with all the attic data 800 GB to 1 TB are needed.

The data can be copied from a public accessible, daily updated snapshot of the database.
This action is called _cloning_:

    mkdir -p db
    bin/download_clone.sh --db-dir="db/" --meta=no \\
        --source="https://dev.overpass-api.de/api_drolbr/"

Here, `meta` controls the level of detail and thus the amount of data:
With the value `no`, it remains with the factual data,
`meta` additionally loads the metadata of the editors
and `attic` loads both metadata and all now outdated data.

The transferred data is only 50% to 70% of the above mentioned amount,
because some temporary data for transaction insulation and the cache of areas does not need to be transferred.

The factual data are not critical in terms of privacy.
The metadata and/or outdated data records, on the other hand, you may only load,
if you have a legitimate interest.

After successful cloning, you can already make queries via

    bin/osm3s_query --db-dir="db/"

by passing the request on the standard input.

## Create an Own Database

You can skip this step if you have just cloned the global data.

If you only want to work with a local extract of the OpenStreetMap data,
then you can also create a database yourself from [an extract in OSM XML format](https://download.geofabrik.de).

These extracts are usually compressed.
However, you can decompress and import the data in one step.
In the following command, replace `$OSM_XML_FILE` with the name of the downloaded file,
`$EXEC_DIR` by the directory into which you compiled,
and `$DB_DIR` by the directory in which the data is to be stored.

Usually you can omit `$META`.
If you have a legitimate interest that outweighs the privacy of OSM users,
you can use `--meta` to load the metadata or `--keep-attic` to additionally load the old datasets.

For a BZ2-compressed file:

    bunzip2 <$OSM_XML_FILE \\
        | $EXEC_DIR/bin/update_database --db-dir="$DB_DIR/" $META

For a Gzip-compressed file:

    gunzip <$OSM_XML_FILE \\
        | $EXEC_DIR/bin/update_database --db-dir="$DB_DIR/" $META

The execution of this command can take a very long time.
Depending on the size of the file, the runtime can range from minutes to 24 hours.

After a successful import, you can already make queries via

    bin/osm3s_query --db-dir="db/"

by passing the request on the standard input.

## Configure the Service

To apply updates, you need three permanently running processes.

The script `fetch_osc.sh` downloads the updates every minute,
as soon as they become available;
they are stored in a designated directory.
The script `apply_osc_to_db.sh` applies the files found in this directory to the database.

An alternative to these both is the single script `fetch_osc_and_apply.sh`.
This script both fetches minute updates, immediately applies them, and removes the downloaded minute diffs afterwards.

The first instance of the daemon `dispatcher` takes care
that the writing and reading processes don't get in each other's way -
otherwise a process could want to read data
that has already been changed to a later status by an update.
Reading and writing processes communicate with `dispatcher` via two special files;
a shared memory with a fixed name helps the processes to find the `dispatcher`,
the socket in the data directory is used for communication.

With the following commands, the required processes can be started permanently.
The label `$DB_DIR` must be replaced by the name of the data directory.

Variant that only applies then discards the downloaded minute diffs:

    nohup bin/dispatcher --osm-base --db-dir="$DB_DIR/" &
    chmod 666 "$DB_DIR"/osm3s_osm_base
    nohup bin/fetch_osc_and_apply.sh "https://planet.openstreetmap.org/replication/minute/" &

Variant that retains the downloaded minute diffs.
Here `$DIFF_DIR` must be replaced by the directory to store the diffs in:

    nohup bin/dispatcher --osm-base --db-dir="$DB_DIR/" &
    chmod 666 "$DB_DIR"/osm3s_osm_base
    nohup bin/fetch_osc.sh auto \\
        "https://planet.openstreetmap.org/replication/minute/" \\
        "$DIFF_DIR/" &
    nohup bin/apply_osc_to_db.sh "$DIFF_DIR/" auto --meta=yes &

You should now be able to execute queries with

    bin/osm3s_query

by passing the query on standard input.

Catching-up may take some time.
On a magnetic hard disk, a speedup of 6 to real time is quite usual.
So if you have downloaded a two days old clone, which is a usual delay,
then catching up may take up to 12 hours.
SSDs tend to be a lot faster.

The next step is to enable areas.
Areas [are not](../../preface/osm_data_model.html#areas) a native data type of OpenStreetMap,
thus its entire implementation in Overpass API is [a huge workaround](../../full_data/area.html).

While there is effort to integrate areas into the main workflow,
for the moment being areas require to build some extra data structures.

It is necessary to run a second instance of the `dispatcher`
and to run a script that periodically updates the area cache:

    nohup bin/dispatcher --areas --db-dir="$DB_DIR/" &
    chmod 666 "$DB_DIR"/osm3s_areas
    nohup bin/rules_delta_loop.sh "$DB_DIR" &

See below for more details.

## Configure the Web Server

The database can be accessed via the web,
by accessing it from a web server via the _Common Gateway Interface_ [(CGI)](https://de.wikipedia.org/wiki/Common_Gateway_Interface).

There are many different web servers;
the public instances are currently run with Apache,
but there have also been successful versions with Nginx over the years.
We will explain a configuration with Apache here as an example.

The Common Gateway Interface must first be enabled in Apache,
by linking the module `cgi.load` in the subdirectory `mods-enabled` to its counterpart in the subdirectory `mods-available`.

Then, in the corresponding `VirtualHost`,
usually in the directory `sites-enabled`,
the CGI directory must be declared.
For the public instances with Apache 2.4, this is done by the following block;
`$ABSPATH_TO_EXEC_DIR` must be replaced by the absolute path to the target directory:

    ScriptAlias /api/ "$ABSPATH_TO_EXEC_DIR"
    <Directory "$ABSPATH_TO_EXEC_DIR">
        AllowOverride None
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Require all granted
    </Directory>
