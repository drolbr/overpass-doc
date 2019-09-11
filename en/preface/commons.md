Commons
=======

The public instances await your queries.
They offer as much resources as possible,
but they also defend themselves against overuse.
Heavy users easily can set up their own instance.

<a name="magnitudes"/>
## Magnitudes

The mission of the public instances
is to be available to as many users as possible.
The computational power currently has to be shared between the roundabout 30'000 daily users.

The typical request has a run time of less than 1 second,
but there are also requests than run for much longer.
Each of the Overpass API servers can fulfill about 1 million requests per day,
and two servers listen on the address [overpass-api.de](https://wiki.openstreetmap.org/wiki/Overpass_API#Public_Overpass_API_instances).

It is extremely unlikely that you will ever cause problems with manually put requests.
Unfortunately, you may still run into load shedding - the quota algorithm is not perfect.

Examples of problematic behaviour:

1. Tens of thousands of times a day sending the same request (from the same address)
2. Asking for individual OSM elements one by one millions of times.
3. Stiching bounding boxes to scrape the full data of the complete world.
4. Setting up an app for more than just OSM mappers
   and relying on the public instances as backend.

In the first case, the querying script needs to be fixed.
In the cases 2 and 3, one better ought use a [planet dump](https://wiki.openstreetmap.org/wiki/Planet.osm) instead of the Overpass API.
In the last cast, only running your own instance sustainably serves your mission.
Setting up your own instance is subject of a [dedicated section](../more_info/setup.md).

In fact, the most users pose only a few requests.
The automatic load shedding thus aims
to give the first few requests per user precedence over the then numerous requests of heavy users.
A manual load shedding therefore will start with the most heavy users
and the following estimations for maximum use give us a broad safety margin.

It can be performed by the public servers for heavy users an amount of requests
that neither surpasses 10000 requests per day nor 1 GB as the total download volume.

Amongst the expressed goals of the Overpass API project is to make running your own instance really simple.
If you expect a higher demand than the above sketched usage limits,
then please read the [installation instructions](../more_info/setup.md).

If you are rather interested in the rules of the automatic load shedding
then please read the following section.

<a name="quotas"/>
## Quotas

The automatic load shedding keeps track which (anonymized) user puts which request
and assures that moderate users still can access the service
if the total volume of requests exceeds server capacity.

There are currently two independent public instances,
[z.overpass-api.de](https://z.overpass-api.de/api/status) and [lz4.overpass-api.de](https://lz4.overpass-api.de/api/status).
We start with the explanation of and with the help of the status request.

### Rate Limit

Requests usually are assigned by taking the IP address as the user.
If a user key is in the request, then it overrides the IP address.
For IPv4 addresses, the full address is evaluated.
For IPv6 addresses, currently the upper 64 bits of the IP address are evaluated.
Since it is still unclear which customs with address blocks become usual,
I may decide to take fewer leading bits into account in the future.
The user number calculated by the server is always in the first line of the [status request](https://overpass-api.de/api/status) behind ``Connected as:``.

Every execution of a request occupies one of the slots available to the user,
in particular for the full actual execution time plus a cool down time.
The purpose of the cool down time is
to give other users a chance to pose a request.
The cool down time grows with the load of the server and proportionate to the execution time.
During moments of low load the cool down time is just a fraction of the execution time,
during moments of high load the cool down time can be a multiple of the execution time.

A slippy map causes many short running requests in a short time.
To ensure that a user gets served all these requests
there are two mechanisms of goodwill:

* Multiple slots are made available to users.
  The number of available slots is written in line 3 after ``Rate limit:``.
* Requests stay enqueued up to 15 seconds on the server
  if not yet a slot is available to them.

An example: if such a slippy map submits 20 requests of 1 second run time,
and if the number of slots is 2 and the ratio of run time to cool down time is 1-by-1,
then

* the first two requests are processed immediately
* the next two requests are accepted,
  then processed with a delay of 2 seconds (1 second execution time plus 1 second cool down time)
* further requests are executed respectively later
* the requests 15 and 16 are executed after a delay of 14 seconds
* the requests 17 to 20 are discarded after 15 seconds
  because they have not secured a slot early enough

If the user still needs the content of the requests 17 to 20
(and not has already panned to a different place)
then the client framework shall resubmit the requests after the 15 seconds.
There is a reference implementation in the [section about OpenLayers and Leaflet](../targets/index.md).

The reason for this mechanism is scripts in an inifinite loop:
many of them submit multiple requests in parallel and are delayed by that mechanism in a meaningful way,
because they get responses including refusals appropriately delayed.

If runaway or long running requests in the order of many minutes have occupied a slot,
then the status response indicates from line 6 on
which slot is going to be available again at which time.

Requests that are denied due to the rate limit are answered with the [HTTP status code 429](https://tools.ietf.org/html/rfc6585#section-4).

### Timeout and Maxsize

Independent of the rate limit, there is a second mechanism.
This mechanism prioritizes small requests over large requests,
to ensure that many users with small requests can still be served
if the demand of the largest users would already exceed the capacity of the server.

There are two criteria for this, per run time and per maximum used RAM.
Each request contains a declaration of its expected maximum run time and expected maximum memory usage.
The declaration of maximum run time can be made explicit by prepending the request with a ``[timeout:...]``;
the declaration of maximum memory usage can be made explicit by prepending the request with a ``[maxsize:...]``.
Both can be combined.

If no maximum run time is declared then a default limit of 180 seconds applies.
For the maximum memory usage, the default value is 512 MiB.

If a request exceeds during execution its maximum run time or maximum memory limit,
then it is aborted by the server.
This [example](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=10&Q=%5Btimeout%3A3%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) stops after 3 seconds:

    [timeout:3];
    nwr[shop=supermarket]({{bbox}});
    out center;

The [same example with more run time](https://overpass-turbo.eu/?lat=51.4775&lon=0.0&zoom=10&Q=%5Btimeout%3A90%5D%3B%0Anwr%5Bshop%3Dsupermarket%5D%28%7B%7Bbbox%7D%7D%29%3B%0Aout%20center%3B) passes:

    [timeout:90];
    nwr[shop=supermarket]({{bbox}});
    out center;

Back to the quotas:
The server admits a request if and only if
it is going to use in both criteria at most half of the remaining available resources.
For the maximum accepted memory usage the value is currently 12 GiB.
If at the moment 8 requests with 512 MiB limit each are running,
then 4 GiB are used.
A further request is going to be admitted if and only if
it promises to use at most 4 GiB.
With this ninth request coming in addition,
there are still 4 GiB available,
and then a further request is only up to a promised size of 2 GiB accepted.

For the maximum run time the system behaves accordingly:
the currently common server limit is 262144 seconds.
This means that one request with a maximum run time of up to 1 day is accepted almost always,
but then every further request with such a long run time would be declined.
The rate limit mechanism with an accordingly long cool down time ensures
that not always the same user can profit from an extremely long run time.

Like with the rate limit, the server does not immediately deny requests,
but waits for 15 seconds
whether in the meantime sufficiently many other requests have been finished.

The load from the server's perspective is made public by Munin,
[here](https://z.overpass-api.de/munin/localdomain/localhost.localdomain/index.html#other) and [here](https://lz4.overpass-api.de/munin/localdomain/localhost.localdomain/index.html#other).

Requests that have been denied due to this resource mismatch are answered with an [HTTP status code 504](https://tools.ietf.org/html/rfc7231#section-6.6.5).
