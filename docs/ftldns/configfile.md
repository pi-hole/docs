You can create a file `/etc/pihole/pihole-FTL.conf` that will be read by *FTL*DNS on startup.

Possible settings (**the option shown first is the default**):

---

### DNS settings

#### `BLOCKINGMODE=NULL|IP-NODATA-AAAA|IP|NXDOMAIN` {#blocking_mode data-toc-label='Blocking Mode'}

How should `FTL` reply to blocked queries?<br>
**[More details](blockingmode.md)**

#### `CNAME_DEEP_INSPECT=true|false` (PR [#663](https://github.com/pi-hole/FTL/pull/663)) {#cname_deep_inspect data-toc-label='Deep CNAME inspection'}

Use this option to disable deep CNAME inspection. This might be beneficial for very low-end devices

#### `BLOCK_ESNI=true|false` (PR [#733](https://github.com/pi-hole/FTL/pull/733)) {#block_esni data-toc-label='ESNI blocking'}

[Encrypted Server Name Indication (ESNI)](https://tools.ietf.org/html/draft-ietf-tls-esni-06) is certainly a good step into the right direction to enhance privacy on the web. It prevents on-path observers, including ISPs, coffee shop owners and firewalls, from intercepting the TLS Server Name Indication (SNI) extension by encrypting it. This prevents the SNI from being used to determine which websites users are visiting.

ESNI will obviously cause issues for `pixelserv-tls` which will be unable to generate matching certificates on-the-fly when it cannot read the SNI. Cloudflare and Firefox are already enabling ESNI.
According to the IEFT draft (link above), we can easily restore `piselserv-tls`'s operation by replying `NXDOMAIN` to `_esni.` subdomains of blocked domains as this mimics a "not configured for this domain" behavior.

---

### Statistics settings

#### `MAXLOGAGE=24.0` {#maxlogage data-toc-label='Max Log Age'}

Up to how many hours of queries should be imported from the database and logs? Maximum is 24.0

#### `PRIVACYLEVEL=0|1|2|3` {#privacylevel data-toc-label='Privacy Level'}

Which privacy level is used?<br>
**[More details](privacylevels.md)**

#### `IGNORE_LOCALHOST=no|yes` {#ignore_localhost data-toc-label='Ignore localhost'}

Should `FTL` ignore queries coming from the local machine?

#### `AAAA_QUERY_ANALYSIS=yes|no` {#aaaa_query_analysis data-toc-label='AAAA Query Analysis'}

Should FTL analyze `AAAA` queries? The DNS server will handle `AAAA` queries the same way, reglardless of this setting. All this does is ignoring `AAAA` queries when computing the statistics of Pi-hole. This setting is considered obsolete may may be removed in a future version.

#### `ANALYZE_ONLY_A_AND_AAAA=false|true` {#analyze_only_a_and_aaaa data-toc-label='Analyze A and AAAA Only'}

Should `FTL` only analyze A and AAAA queries?

---

### Other settings

#### `SOCKET_LISTENING=localonly|all` {#socket_listening data-toc-label='Socket Listening'}

Listen only for local socket connections or permit all connections

#### `FTLPORT=4711` {#ftlport data-toc-label='FTLDNS Port'}

On which port should FTL be listening?

#### `RESOLVE_IPV6=yes|no` {#resolve_ipv6 data-toc-label='Resolve IPV6'}

Should `FTL` try to resolve IPv6 addresses to hostnames?

#### `RESOLVE_IPV4=yes|no` {#resolve_ipv4 data-toc-label='Resolve IPV4'}

Should `FTL` try to resolve IPv4 addresses to hostnames?

#### `DELAY_STARTUP=0` (PR [#716](https://github.com/pi-hole/FTL/pull/716)) {#delay_startup data-toc-label='Delay resolver startup'}

In certain configurations, you may want FTL to wait a given amount of time before trying to start the DNS revolver. This is typically found when network interfaces appear only late during system startup and the interface startup priorities are configured incorrectly. This setting takes any integer value between 0 and 300 seconds

#### `NICE=-10` (PR [#798](https://github.com/pi-hole/FTL/pull/798)) {#nice data-toc-label='Set niceness'}

Can be used to change the niceness of Pi-hole FTL. Defaults to `-10` and can be
disabled altogether by setting a value of `-999`.

The nice value is an attribute that can be used to influence the CPU scheduler
to favor or disfavor a process in scheduling decisions. The range of the nice
value varies across UNIX systems. On modern Linux, the range is `-20` (high
priority = not very nice to other processes) to `+19` (low priority).

#### `NAMES_FROM_NETDB=true|false` (PR [#784](https://github.com/pi-hole/FTL/pull/784)) {#names_from_netdb data-toc-label='Load names from network table'}

Control whether FTL should use the fallback option to try to obtain client names
from checking the network table. This behavior can be disabled
with this option

Assume an IPv6 client without a host names. However, the network table knows -
though the client's MAC address - that this is the same device where we have a
host name for another IP address (e.g., a DHCP server managed IPv4 address). In
this case, we use the host name associated to the other address as this is the
same device.

---

### Long-term database settings

**[Further details concerning the database](../database/index.md)**

#### `DBIMPORT=yes|no` {#dbimport data-toc-label='Use database'}

Should `FTL` load information from the database on startup to be aware of the most recent history?

#### `MAXDBDAYS=365` {#maxdbdays data-toc-label='Max age'}

How long should queries be stored in the database? Setting this to `0` disables the database

#### `DBINTERVAL=1.0` {#dbinterval data-toc-label='Storing Interval'}

How often do we store queries in FTL's database [minutes]?

#### `DBFILE=/etc/pihole/pihole-FTL.db` {#dbfile data-toc-label='Database Filename'}

Specify the path and filename of FTL's SQLite3 long-term database. Setting this to `DBFILE=` disables the database altogether

---

### File options

#### `LOGFILE=/var/log/pihole-FTL.log` {#file_LOGFILE data-toc-label='Log file'}

The location of FTL's log file. If you want to move the log file to a different place, also consider [this FAQ article](https://discourse.pi-hole.net/t/moving-the-pi-hole-log-to-another-location-device/2041).

#### `PIDFILE=/var/run/pihole-FTL.pid` {#file_PIDFILE data-toc-label='Process identifier file'}

The file which contains the PID of FTL's main process.

#### `PORTFILE=/var/run/pihole-FTL.port` {#file_PORTFILE data-toc-label='Port file'}

The file containing the port FTL's API is listening on.

#### `SOCKETFILE=/var/run/pihole/FTL.sock` {#file_SOCKETFILE data-toc-label='Socket file'}

The file containing the socket FTL's API is listening on.

#### `SETUPVARSFILE=/etc/pihole/setupVars.conf` {#file_SETUPVARSFILE data-toc-label='setupVars file'}

The config file of Pi-hole containing, e.g., the current blocking status (do not change).

#### `MACVENDORDB=/etc/pihole/macvendor.db` {#file_MACVENDORDB data-toc-label='MacVendor database file'}

The database containing MAC -> Vendor information for the network table.

#### `GRAVITYDB=/etc/pihole/gravity.db` {#file_GRAVITYDB data-toc-label='Gravity database'}

Specify path and filename of FTL's SQLite3 gravity database. This database contains all domains relevant for Pi-hole's DNS blocking

---

### Debugging options

#### `DEBUG_ALL=false|true` {#debug_all data-toc-label='All'}

Enable all debug flags. If this is set to true, all other debug config options are ignored.

#### `DEBUG_DATABASE=false|true` {#debug_database data-toc-label='Database'}

Print debugging information about database actions. This prints performed SQL statements as well as some general information such as the time it took to store the queries and how many have been saved to the database.

#### `DEBUG_NETWORKING=false|true` {#debug_networking data-toc-label='Networking'}

Prints a list of the detected interfaces on the startup of `pihole-FTL`. Also, prints whether these interfaces are IPv4 or IPv6 interfaces.

#### `DEBUG_LOCKS=false|true` {#debug_locks data-toc-label='Locks'}

Print information about shared memory locks. Messages will be generated when waiting, obtaining, and releasing a lock.

#### `DEBUG_QUERIES=false|true` {#debug_queries data-toc-label='Queries'}

Print extensive query information (domains, types, replies, etc.). This has always been part of the legacy `debug` mode of `pihole-FTL`.

#### `DEBUG_FLAGS=false|true` {#debug_flags data-toc-label='Flags'}

Print flags of queries received by the DNS hooks. Only effective when `DEBUG_QUERIES` is enabled as well.

#### `DEBUG_SHMEM=false|true` {#debug_shmem data-toc-label='Shared Memory'}

Print information about shared memory buffers. Messages are either about creating or enlarging shmem objects or string injections.

#### `DEBUG_GC=false|true` {#debug_gc data-toc-label='Garbage Collection'}

Print information about garbage collection (GC): What is to be removed, how many have been removed and how long did GC take.

#### `DEBUG_ARP=false|true` {#debug_arp data-toc-label='Neighbor parsing'}

Print information about ARP table processing: How long did parsing take, whether read MAC addresses are valid, and if the `macvendor.db` file exists.

#### `DEBUG_REGEX=false|true` {#debug_regex data-toc-label='REGEX'}

Controls if *FTL*DNS should print extended details about regex matching into `pihole-FTL.log`.<br>
Due to legacy reasons, we also support the following setting to be used for enabling the same functionality:<br>
`REGEX_DEBUGMODE=false|true`
Note that if one of them is set to `true`, the other one cannot be used to disable this setting again.<br>
**[More details](regex/overview.md)**

#### `DEBUG_API=false|true` {#debug_api data-toc-label='Telnet'}

Print extra debugging information during telnet API calls. Currently only used to send extra information when getting all queries.

#### `DEBUG_OVERTIME=false|true` {#debug_overtime data-toc-label='Over Time Data'}

Print information about overTime memory operations, such as initializing or moving overTime slots.

#### `DEBUG_EXTBLOCKED=false|true` {#debug_extblocked data-toc-label='Externally blocked queries'}

Print information about why FTL decided that certain queries were recognized as being externally blocked.

#### `DEBUG_CAPS=false|true` {#debug_caps data-toc-label='Linux capabilities'}

Print information about capabilities granted to the pihole-FTL process. The current capabilities are printed on receipt of `SIGHUP`, i.e., the current set of capabilities can be queried without restarting `pihole-FTL` (by setting `DEBUG_CAPS=true` and thereafter sending `killall -HUP pihole-FTL`).

#### `DEBUG_DNSMASQ_LINES=false|true` {#debug_dnsmasq_lines data-toc-label='Analyze dnsmasq log lines'}

Print file and line causing a `dnsmasq` event into FTL's log files. This is handy to implement additional hooks missing from FTL.

#### `DEBUG_VECTORS=false|true` (PR [#725](https://github.com/pi-hole/FTL/pull/725)) {#debug_vectors data-toc-label='Vectors'}

FTL uses dynamically allocated vectors for various tasks. This config option enables extensive debugging information such as information about allocation, referencing, deletion, and appending.

#### `DEBUG_RESOLVER=false|true` (PR [#728](https://github.com/pi-hole/FTL/pull/728)) {#debug_resolver data-toc-label='Resolver details'}

Extensive information about hostname resolution like which DNS servers are used in the first and second hostname resolving tries (only affecting internally generated PTR queries).

{!abbreviations.md!}
