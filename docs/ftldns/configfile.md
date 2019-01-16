You can create a file `/etc/pihole/pihole-FTL.conf` that will be read by *FTL*DNS on startup.

Possible settings (**the option shown first is the default**):
### DNS settings

- `BLOCKINGMODE=NULL|IP-NODATA-AAAA|IP|NXDOMAIN`<br>
  How should `FTL` reply to blocked queries?<br>
**[More details](blockingmode.md)**

### Statistics settings

- `MAXLOGAGE=24.0`<br>
  Up to how many hours of queries should be imported from the database and logs? Maximum is 744 (31 days)

- `PRIVACYLEVEL=0|1|2|3|4`<br>
  Which privacy level is used?<br>
**[More details](privacylevels.md)**

- `IGNORE_LOCALHOST=no|yes`<br>
  Should `FTL` ignore queries coming from the local machine?

- `AAAA_QUERY_ANALYSIS=yes|no`<br>
  Allow `FTL` to analyze AAAA queries from pihole.log?

- `ANALYZE_ONLY_A_AND_AAAA=false|true`<br>
  Should `FTL` only analyze A and AAAA queries?

### Socket settings

- `SOCKET_LISTENING=localonly|all`<br>
  Listen only for local socket connections or permit all connections

- `FTLPORT=4711`<br>
  On which port should FTL be listening?

### Host name resolution

- `RESOLVE_IPV6=yes|no`<br>
  Should `FTL` try to resolve IPv6 addresses to host names?

- `RESOLVE_IPV4=yes|no`<br>
  Should `FTL` try to resolve IPv4 addresses to host names?

### Database settings
**[Further details concerning the database](database.md)**

- `DBIMPORT=yes|no`<br>
  Should `FTL` load information from the database on startup to be aware of the most recent history?

- `MAXDBDAYS=365`<br>
  How long should queries be stored in the database? Setting this to `0` disables the database

- `DBINTERVAL=1.0`<br>
  How often do we store queries in FTL's database [minutes]?

- `DBFILE=/etc/pihole/pihole-FTL.db`<br>
  Specify path and filename of FTL's SQLite3 long-term database. Setting this to `DBFILE=` disables the database altogether

### Debugging options

- `DEBUG_DATABASE=false|true`<br>
  Print debugging information about database actions. This prints performed SQL statements as well as some general information such as the time it took to store the queries and how many have been saved to the database.

- `DEBUG_NETWORKING=false|true`<br>
  Prints a list of the detected interfaces on startup of `pihole-FTL`. Also prints whether these interfaces are IPv4 or IPv6 interfaces.

- `DEBUG_LOCKS=false|true`<br>
  Print information about shared memory locks. Messages will be generated when waiting, obtaining, and releasing a lock.

- `DEBUG_QUERIES=false|true`<br>
  Print extensive query information (domains, types, replies, etc.). This has always been part of the legacy `debug` mode of `pihole-FTL`.

- `DEBUG_FLAGS=false|true`<br>
  Print flags of queries received by the DNS hooks. Only effective when `DEBUG_QUERIES` is enabled as well.

- `DEBUG_SHMEM=false|true`<br>
  Print information about shared memory buffers. Messages are either about creating or enlarging shmem objects or string injections.

- `DEBUG_GC=false|true`<br>
  Print information about garbage collection (GC): What is to be removed, how many have been removed and how long did GC take.

- `DEBUG_ARP=false|true`<br>
  Print information about ARP table processing: How long did parsing take, whether read MAC addresses are valid, and if the `macvendor.db` file exists.

- `DEBUG_REGEX=false|true`<br>
  Controls if *FTL*DNS should print extended details about regex matching into `pihole-FTL.log`.<br>
  Due to legacy reasons, we also support the following setting to be used for enabling the same functionality:<br>
  `REGEX_DEBUGMODE=false|true`<br>
  Note that if one of them is set to `true`, the other one cannot be used to disable this setting again.<br>
  **[More details](regex/overview.md)**

{!abbreviations.md!}
