You can create a file `/etc/pihole/pihole-FTL.conf` that will be read by *FTL*DNS on startup.

!!! info
    Comments need to start with `#;` to avoid issues with PHP and `bash` reading this file. (See [https://github.com/pi-hole/pi-hole/pull/4081](https://github.com/pi-hole/pi-hole/pull/4081)  for more details)

Possible settings (**the option shown first is the default**):

---

### DNS settings

#### `BLOCKINGMODE=NULL|IP-NODATA-AAAA|IP|NXDOMAIN` {#blocking_mode data-toc-label='Blocking Mode'}

How should `FTL` reply to blocked queries?<br>
**[More details](blockingmode.md)**

#### `CNAME_DEEP_INSPECT=true|false` (PR [#663](https://github.com/pi-hole/FTL/pull/663)) {#cname_deep_inspect data-toc-label='Deep CNAME inspection'}

Use this option to disable deep CNAME inspection. This might be beneficial for very low-end devices.

#### `BLOCK_ESNI=true|false` (PR [#733](https://github.com/pi-hole/FTL/pull/733)) {#block_esni data-toc-label='ESNI blocking'}

[Encrypted Server Name Indication (ESNI)](https://tools.ietf.org/html/draft-ietf-tls-esni-06) is certainly a good step into the right direction to enhance privacy on the web. It prevents on-path observers, including ISPs, coffee shop owners and firewalls, from intercepting the TLS Server Name Indication (SNI) extension by encrypting it. This prevents the SNI from being used to determine which websites users are visiting.

ESNI will obviously cause issues for `pixelserv-tls` which will be unable to generate matching certificates on-the-fly when it cannot read the SNI. Cloudflare and Firefox are already enabling ESNI.
According to the IEFT draft (link above), we can easily restore `piselserv-tls`'s operation by replying `NXDOMAIN` to `_esni.` subdomains of blocked domains as this mimics a "not configured for this domain" behavior.

#### `EDNS0_ECS=true|false` (PR [#851](https://github.com/pi-hole/FTL/pull/851)) {#block_edns0_ecs data-toc-label='EDNS ECS overwrite'}

Should we overwrite the query source when client information is provided through EDNS0 client subnet (ECS) information?
This allows Pi-hole to obtain client IPs even if they are hidden behind the NAT of a router.

This feature has been requested and discussed on [Discourse](https://discourse.pi-hole.net/t/support-for-add-subnet-option-from-dnsmasq-ecs-edns0-client-subnet/35940), where further information on how to use it can be found.

#### `RATE_LIMIT=1000/60` (PR [#1052](https://github.com/pi-hole/FTL/pull/1052)) {#rate_limit data-toc-label='Query rate limiting'}

Control FTL's query rate-limiting. Rate-limited queries are answered with a `REFUSED` reply and not further processed by FTL.

The default settings for FTL's rate-limiting are to permit no more than `1000` queries in `60` seconds. Both numbers can be customized independently.
It is important to note that rate-limiting is happening on a *per-client* basis. Other clients can continue to use FTL while rate-limited clients are short-circuited at the same time.

For this setting, both numbers, the maximum number of queries within a given time, **and** the length of the time interval (seconds) have to be specified. For instance, if you want to set a rate limit of 1 query per hour, the option should look like `RATE_LIMIT=1/3600`.
The time interval is relative to when FTL has finished starting (start of the daemon + possible delay by `DELAY_STARTUP`)  then it will advance in steps of the rate-limiting interval. If a client reaches the maximum number of queries it will be blocked until **the end of the current interval**. This will be logged to `/var/log/pihole/FTL.log`, e.g. `Rate-limiting 10.0.1.39 for at least 44 seconds`. If the client continues to send queries while being blocked already and this number of queries during the blocking exceeds the limit the client will continue to be blocked **until the end of the next interval** (`FTL.log` will contain lines like `Still rate-limiting 10.0.1.39 as it made additional 5007 queries`).  As soon as the client requests less than the set limit, it will be unblocked (`Ending rate-limitation of 10.0.1.39`).

Rate-limiting may be disabled altogether by setting `RATE_LIMIT=0/0` (this results in the same behavior as before FTL v5.7).

#### `LOCAL_IPV4=` (unset by default, PR [#1293](https://github.com/pi-hole/FTL/pull/1293)) {#local_ipv4 data-toc-label='Force local A reply'}

By default, `FTL` determines the address of the interface a query arrived on and uses this address for replying to `A` queries with the most suitable address for the requesting client. This setting can be used to use a fixed, rather than the dynamically obtained, address when Pi-hole responds to the following names:

- `pi.hole`
- `<the device's hostname>`
- `pi.hole.<local domain>`
- `<the device's hostname>.<local domain>`

#### `LOCAL_IPV6=` (unset by default, PR [#1293](https://github.com/pi-hole/FTL/pull/1293)) {#local_ipv6 data-toc-label='Force local AAAA reply'}
<!-- markdownlint-disable-next-line MD051 -->
Used to overwrite the IP address for local `AAAA` queries. See [`LOCAL_IPV4`](#local_ipv4) for details on when this setting is used.

#### `BLOCK_IPV4=` (unset by default, PR [#1293](https://github.com/pi-hole/FTL/pull/1293)) {#block_ipv4 data-toc-label='Force blocked A reply'}

By default, `FTL` determines the address of the interface a query arrived on and uses this address for replying to `A` queries with the most suitable address for the requesting client. This setting can be used to use a fixed, rather than the dynamically obtained, address when Pi-hole responds in the following cases:

- `IP` blocking mode is used and this query is to be blocked
- A regular expression with the [`;reply=IP` regex extension](../regex/pi-hole.md#specify-reply-type) is used

#### `BLOCK_IPV6=` (unset by default, PR [#1293](https://github.com/pi-hole/FTL/pull/1293)) {#block_ipv6 data-toc-label='Force blocked AAAA reply'}
<!-- markdownlint-disable-next-line MD051 -->
Used to overwrite the IP address for blocked `AAAA` queries. See [`BLOCK_IPV4`](#block_ipv4) for details on when this setting is used.

#### `REPLY_WHEN_BUSY=DROP|ALLOW|BLOCK|REFUSE` (PR [#1156](https://github.com/pi-hole/FTL/pull/1156) & PR [#1341](https://github.com/pi-hole/FTL/pull/1341)) {#reply_when_busy data-toc-label='Database busy reply'}

When the gravity database is locked/busy, how should Pi-hole handle queries?

- `ALLOW` - allow all queries when the database is busy
- `BLOCK` - block all queries when the database is busy. This uses the configured `BLOCKINGMODE` (default `NULL`)
- `REFUSE` - refuse all queries which arrive while the database is busy
- `DROP` - just drop the queries, i.e., never reply to them at all.

Despite `REFUSE` sounding similar to `DROP`, it turned out that many clients will just immediately retry, causing up to several thousands of queries per second. This does not happen in `DROP` mode.

#### `MOZILLA_CANARY=true|false` (PR [#1148](https://github.com/pi-hole/FTL/pull/1148)) {#mozilla_canary data-toc-label='Mozilla canary domain handling'}

Should Pi-hole always replies with `NXDOMAIN` to `A` and `AAAA` queries of `use-application-dns.net` to disable Firefox's automatic DNS-over-HTTP?
This is following the recommendation on [https://support.mozilla.org/en-US/kb/configuring-networks-disable-dns-over-https](https://support.mozilla.org/en-US/kb/configuring-networks-disable-dns-over-https)


#### `BLOCK_TTL=2` (PR [#1173](https://github.com/pi-hole/FTL/pull/1173)) {#block_ttl data-toc-label='Blocked domains lifetime'}

FTL's internal TTL to be handed out for blocked queries. This setting allows users to select a value different from the `dnsmasq` config option `local-ttl`. This seems useful in context of locally used hostnames that are known to stay constant over long times (printers, etc.).

Note that large values may render whitelisting ineffective due to client-side caching of blocked queries.

#### `BLOCK_ICLOUD_PR=true|false` (PR [#1171](https://github.com/pi-hole/FTL/pull/1171)) {#icloud_private_relay data-toc-label='iCloud Private Relay domain handling'}

Should Pi-hole always reply with `NXDOMAIN` to `A` and `AAAA` queries of `mask.icloud.com` and `mask-h2.icloud.com` to disable Apple's iCloud Private Relay to prevent Apple devices from bypassing Pi-hole?
This is following the recommendation on [https://developer.apple.com/support/prepare-your-network-for-icloud-private-relay](https://developer.apple.com/support/prepare-your-network-for-icloud-private-relay)

---

### Statistics settings

#### `MAXLOGAGE=24.0` {#maxlogage data-toc-label='Max Log Age'}

Up to how many hours of queries should be imported from the database and logs? Values greater than the hard-coded maximum of 24h need a locally compiled `FTL` with a changed compile-time value.

#### `PRIVACYLEVEL=0|1|2|3` {#privacylevel data-toc-label='Privacy Level'}

Which privacy level is used?<br>
**[More details](privacylevels.md)**

#### `IGNORE_LOCALHOST=no|yes` {#ignore_localhost data-toc-label='Ignore localhost'}

Should `FTL` ignore queries coming from the local machine?

#### `AAAA_QUERY_ANALYSIS=yes|no` {#aaaa_query_analysis data-toc-label='AAAA Query Analysis'}

Should FTL analyze `AAAA` queries? The DNS server will handle `AAAA` queries the same way, regardless of this setting. All this does is ignoring `AAAA` queries when computing the statistics of Pi-hole. This setting is considered obsolete and will be removed in a future version.

#### `ANALYZE_ONLY_A_AND_AAAA=false|true` {#analyze_only_a_and_aaaa data-toc-label='Analyze A and AAAA Only'}

Should `FTL` only analyze A and AAAA queries?


#### `SHOW_DNSSEC=true|false` {#show_dnssec data-toc-label='Show automatic DNSSEC queries'}

Should FTL analyze and include automatically generated DNSSEC queries in the Query Log?

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

#### `PIHOLE_PTR=PI.HOLE|HOSTNAME|HOSTNAMEFQDN|NONE` (PR [#1111](https://github.com/pi-hole/FTL/pull/1111), [#1164](https://github.com/pi-hole/FTL/pull/1164)) {#pihole_ptr data-toc-label='Pi-hole PTR'}

Controls whether and how FTL will reply with for address for which a local interface exists. Valid options are:

- `PI.HOLE` (the default) respond with `pi.hole`
- `HOSTNAME` serve the machine's global hostname
- `HOSTNAMEFQDN` serve the machine's global hostname as fully qualified domain by adding the local suffix. See note below.
- `NONE` Pi-hole will **not** respond automatically on PTR requests to local interface addresses. Ensure `pi.hole` and/or hostname records exist elsewhere.

Note about `HOSTNAMEFQDN`: If no local suffix has been defined, FTL appends the local domain `.no_fqdn_available`. In this case you should either add `domain=whatever.com` to a custom config file inside `/etc/dnsmasq.d/` (to set `whatever.com` as local domain) or use `domain=#` which will try to derive the local domain from `/etc/resolv.conf` (or whatever is set with `resolv-file`, when multiple `search` directives exist, the first one is used).

#### `DELAY_STARTUP=0` (PR [#716](https://github.com/pi-hole/FTL/pull/716), PR [1349](https://github.com/pi-hole/FTL/pull/1349)) {#delay_startup data-toc-label='Delay resolver startup'}

During startup, in some configurations, network interfaces appear only late during system startup and are not ready when FTL tries to bind to them. Therefore, you may want FTL to wait a given amount of time before trying to start the DNS revolver. This setting takes any integer value between 0 and 300 seconds. To prevent delayed startup while the system is already running and FTL is restarted, the delay only takes place within the first 180 seconds (hard-coded) after booting.

#### `NICE=-10` (PR [#798](https://github.com/pi-hole/FTL/pull/798)) {#nice data-toc-label='Set niceness'}

Can be used to change the niceness of Pi-hole FTL. Defaults to `-10` and can be
disabled altogether by setting a value of `-999`.

The nice value is an attribute that can be used to influence the CPU scheduler
to favor or disfavor a process in scheduling decisions. The range of the nice
value varies across UNIX systems. On modern Linux, the range is `-20` (high
priority = not very nice to other processes) to `+19` (low priority).

#### `MAXNETAGE=[MAXDBDAYS]` (PR [#871](https://github.com/pi-hole/FTL/pull/871)) {#maxnetage data-toc-label='Network table cleaning'}

IP addresses (and associated host names) older than the specified number of days
are removed to avoid dead entries in the network overview table. This setting
defaults to the same value as `MAXDBDAYS` above but can be changed independently
if needed.

#### `NAMES_FROM_NETDB=true|false` (PR [#784](https://github.com/pi-hole/FTL/pull/784)) {#names_from_netdb data-toc-label='Load names from network table'}

Control whether FTL should use the fallback option to try to obtain client names
from checking the network table. This behavior can be disabled
with this option

Assume an IPv6 client without a host names. However, the network table knows -
though the client's MAC address - that this is the same device where we have a
host name for another IP address (e.g., a DHCP server managed IPv4 address). In
this case, we use the host name associated to the other address as this is the
same device.

#### `REFRESH_HOSTNAMES=IPV4|ALL|UNKNOWN|NONE` (PR [#953](https://github.com/pi-hole/FTL/pull/953)) {#refresh_hostnames data-toc-label='Refresh hostnames'}

With this option, you can change how (and if) hourly PTR requests are made to check for changes in client and upstream server hostnames. The following options are available:

- `REFRESH_HOSTNAMES=IPV4` - Do the hourly PTR lookups only for IPv4 addresses
   This is the new default since Pi-hole FTL v5.3.2. It should resolve issues with more and more very short-lived PE IPv6 addresses coming up in a lot of networks.
- `REFRESH_HOSTNAMES=ALL` - Do the hourly PTR lookups for all addresses
   This is the same as what we're doing with FTL v5.3(.1). This can create a lot of PTR queries for those with many IPv6 addresses in their networks.
- `REFRESH_HOSTNAMES=UNKNOWN` - Only resolve unknown hostnames
   Already existing hostnames are never refreshed, i.e., there will be no PTR queries made for clients where hostnames are known. This also means that known hostnames will not be updated once known.
- `REFRESH_HOSTNAMES=NONE` - Don't do any hourly PTR lookups
   This means we look host names up exactly once (when we first see a client) and never again. You may miss future changes of host names.

#### `PARSE_ARP_CACHE=true|false` (PR [#445](https://github.com/pi-hole/FTL/pull/445)) {#parse_arp_cache data-toc-label='Parse ARP cache'}

This setting can be used to disable ARP cache processing. When disabled, client identification and the network table will stop working reliably.

#### `CHECK_LOAD=true|false` (PR [#1249](https://github.com/pi-hole/FTL/pull/1249)) {#check_load data-toc-label='Check system load'}

Pi-hole is very lightweight on resources. Nevertheless, this does not mean that you should run Pi-hole on a server that is otherwise extremely busy as queuing on the system can lead to unnecessary delays in DNS operation as the system becomes less and less usable as the system load increases because all resources are permanently in use. To account for this, FTL regularly checks the system load. To bring this to your attention, FTL warns about excessive load when the 15 minute system load average exceeds the number of cores.

This check can be disabled with this setting.

#### `CHECK_SHMEM=90` (PR [#1249](https://github.com/pi-hole/FTL/pull/1249)) {#check_shmem data-toc-label='Check shared-memory limits'}

FTL stores history in shared memory to allow inter-process communication with forked dedicated TCP workers. If FTL runs out of memory, it cannot continue to work as queries cannot be analyzed any further. Hence, FTL checks if enough shared memory is available on your system and warns you if this is not the case.

By default, FTL warns if the shared-memory usage exceeds 90%. You can set any integer limit between `0` to `100` (interpreted as percentages) where `0` means that checking of shared-memory usage is disabled.

#### `CHECK_DISK=90` (PR [#1249](https://github.com/pi-hole/FTL/pull/1249)) {#check_disk data-toc-label='Check disk space'}
<!-- markdownlint-disable-next-line MD051 -->
FTL stores its long-term history in a database file on disk (see [here](../database/index.md)). Furthermore, FTL stores log files (see, e.g., [here](#file_LOGFILE)).

By default, FTL warns if usage of the disk holding any crucial file exceeds 90%. You can set any integer limit between `0` to `100` (interpreted as percentages) where `0` means that checking of disk usage is disabled.

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

#### `LOGFILE=/var/log/pihole/FTL.log` {#file_LOGFILE data-toc-label='Log file'}

The location of FTL's log file. If you want to move the log file to a different place, also consider [this FAQ article](https://discourse.pi-hole.net/t/moving-the-pi-hole-log-to-another-location-device/2041).

#### `PIDFILE=/run/pihole-FTL.pid` {#file_PIDFILE data-toc-label='Process identifier file'}

The file which contains the PID of FTL's main process.

#### `SOCKETFILE=/run/pihole/FTL.sock` {#file_SOCKETFILE data-toc-label='Socket file'}

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

#### `DEBUG_EDNS0=false|true` {#debug_edns0 data-toc-label='EDNS0'}

Print debugging information about received EDNS(0) data.

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

#### `DEBUG_REGEX=false|true` {#debug_regex data-toc-label='Regular expressions'}

Controls if *FTL*DNS should print extended details about regex matching into `FTL.log`.

**[More details](../regex/overview.md)**

#### `DEBUG_API=false|true` {#debug_api data-toc-label='Telnet'}

Print extra debugging information during telnet API calls. Currently only used to send extra information when getting all queries.

#### `DEBUG_OVERTIME=false|true` {#debug_overtime data-toc-label='Over Time Data'}

Print information about overTime memory operations, such as initializing or moving overTime slots.

#### `DEBUG_STATUS=false|true` {#debug_status data-toc-label='Query status'}

Print information about status changes for individual queries. This can be useful to identify unexpected `unknown` queries.

#### `DEBUG_CAPS=false|true` {#debug_caps data-toc-label='Linux capabilities'}

Print information about capabilities granted to the pihole-FTL process. The current capabilities are printed on receipt of `SIGHUP`, i.e., the current set of capabilities can be queried without restarting `pihole-FTL` (by setting `DEBUG_CAPS=true` and thereafter sending `killall -HUP pihole-FTL`).

#### `DEBUG_DNSMASQ_LINES=false|true` {#debug_dnsmasq_lines data-toc-label='Analyze dnsmasq log lines'}

Print file and line causing a `dnsmasq` event into FTL's log files. This is handy to implement additional hooks missing from FTL.

#### `DEBUG_VECTORS=false|true` (PR [#725](https://github.com/pi-hole/FTL/pull/725)) {#debug_vectors data-toc-label='Vectors'}

FTL uses dynamically allocated vectors for various tasks. This config option enables extensive debugging information such as information about allocation, referencing, deletion, and appending.

#### `DEBUG_RESOLVER=false|true` (PR [#728](https://github.com/pi-hole/FTL/pull/728)) {#debug_resolver data-toc-label='Resolver details'}

Extensive information about hostname resolution like which DNS servers are used in the first and second hostname resolving tries (only affecting internally generated PTR queries).

#### `DEBUG_EDNS0=false|true` (PR [#851](https://github.com/pi-hole/FTL/pull/851)) {#debug_edns0 data-toc-label='EDNS(0) data'}

Verbose logging during EDNS(0) header analysis.

#### `DEBUG_CLIENTS=false|true` (PR [#762](https://github.com/pi-hole/FTL/pull/762)) {#debug_clients data-toc-label='Clients'}

Log various important client events such as change of interface (e.g., client switching from WiFi to wired or VPN connection), as well as extensive reporting about how clients were assigned to its groups.

#### `DEBUG_ALIASCLIENTS=false|true` (PR [#880](https://github.com/pi-hole/FTL/pull/880)) {#debug_aliasclients data-toc-label='Aliasclients'}

Log information related to alias-client processing.

#### `DEBUG_EVENTS=false|true` (PR [#881](https://github.com/pi-hole/FTL/pull/881)) {#debug_events data-toc-label='Events'}

Log information regarding FTL's embedded event handling queue.

#### `DEBUG_HELPER=false|true` (PR [#914](https://github.com/pi-hole/FTL/pull/914)) {#debug_helper data-toc-label='Script helpers'}

Log information about script helpers, e.g., due to `dhcp-script`.

#### `ADDR2LINE=true|false` (PR [#774](https://github.com/pi-hole/FTL/pull/774)) {#addr2line data-toc-label='Addr2Line'}

Should FTL translate its own stack addresses into code lines during the bug backtrace? This improves the analysis of crashed significantly. It is recommended to leave the option enabled. This option should only be disabled when `addr2line` is known to not be working correctly on the machine because, in this case, the malfunctioning `addr2line` can prevent from generating any backtrace at all.

#### `DEBUG_EXTRA=false|true` (PR [#994](https://github.com/pi-hole/FTL/pull/994)) {#debug_extra data-toc-label='Misc.'}

Temporary flag that may print additional information. This debug flag is meant to be used whenever needed for temporary investigations. The logged content may change without further notice at any time.

### Deprecated options

#### `REPLY_ADDR4=` (unset by default, PR [#965](https://github.com/pi-hole/FTL/pull/965)) {#reply_addr4 data-toc-label='Force A reply'}

*This option is deprecated and may be removed in future versions, please use `BLOCK_IPV4` and `LOCAL_IPV4` instead*

If neither `BLOCK_IPV4` nor `LOCAL_IPV4` are set, this setting is used to set both of them. If either of the two is set, this setting is ignored altogether.

#### `REPLY_ADDR6=` (unset by default, PR [#965](https://github.com/pi-hole/FTL/pull/965)) {#reply_addr6 data-toc-label='Force AAAA reply'}

*This option is deprecated and may be removed in future versions, please use `BLOCK_IPV6` and `LOCAL_IPV6` instead*

If neither `BLOCK_IPV6` nor `LOCAL_IPV6` are set, this setting is used to set both of them. If either of the two is set, this setting is ignored altogether.

#### `PORTFILE=/run/pihole-FTL.port` {#file_PORTFILE data-toc-label='Port file'}

*This option is deprecated as FTL does not write any port file anymore. Please parse `pihole-FTL.conf` if you need to check if a custom API port is set.*

The file containing the port FTL's API is listening on.
