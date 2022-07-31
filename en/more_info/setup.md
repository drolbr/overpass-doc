Installation of an Own Instance
===============================

How can I set up my own instance of the Overpass API
to be able to execute an arbitrary number of requests?

A [brief](https://overpass-api.de/no_frills.html) and a [detailed](https://overpass-api.de/full_installation.html) how to is available.
The essential three steps are:

1. install the software
2. import OpenStreetMap data
3. configure the service and the web server

The steps 1 and 2 should be distinct steps
because the amount of payload data is so big
that the most users will want to align their apporach on that.

Alternatively, the Overpass API also can be installed [with Docker containers](https://github.com/drolbr/docker-overpass).
