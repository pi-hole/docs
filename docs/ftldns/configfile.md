You can create a file `/etc/pihole/pihole-FTL.conf` that will be read by *FTL*DNS on startup.

Possible settings (**the option shown first is the default**):

## DNS settings

### BLOCKINGMODE
`BLOCKINGMODE=NULL|IP-NODATA-AAAA|IP|NXDOMAIN`

How should `FTL` reply to blocked queries?

**[More details](blockingmode.md)**

## Statistics settings

### MAXLOGAGE
`MAXLOGAGE=24.0`

Up to how many hours of queries should be imported from the database and logs? Maximum is 744 (31 days)

### PRIVACYLEVEL
`PRIVACYLEVEL=0|1|2|3|4`

Which privacy level is used?

**[More details](privacylevels.md)**

### IGNORE_LOCALHOST
`IGNORE_LOCALHOST=no|yes`

Should `FTL` ignore queries coming from the local machine?

### AAAA_QUERY_ANALYSIS
`AAAA_QUERY_ANALYSIS=yes|no`

Allow `FTL` to analyze AAAA queries from pihole.log?

### ANALYZE_ONLY_A_AND_AAAA
`ANALYZE_ONLY_A_AND_AAAA=false|true`

Should `FTL` only analyze A and AAAA queries?

## Socket settings

### SOCKET_LISTENING
`SOCKET_LISTENING=localonly|all`

Listen only for local socket connections or permit all connections

### FTLPORT
`FTLPORT=4711`

On which port should FTL be listening?

## Host name resolution

### RESOLVE_IPV6
`RESOLVE_IPV6=yes|no`

Should `FTL` try to resolve IPv6 addresses to host names?

### RESOLVE_IPV4
`RESOLVE_IPV4=yes|no`

Should `FTL` try to resolve IPv4 addresses to host names?

## Database settings

### DBIMPORT
`DBIMPORT=yes|no`

Should `FTL` load information from the database on startup to be aware of the most recent history?

**[More details](database.md)**

### MAXDBDAYS
`MAXDBDAYS=365`

How long should queries be stored in the database?
Setting this to `0` disables the database

**[More details](database.md)**

### DBINTERVAL
`DBINTERVAL=1.0`

How often do we store queries in FTL's database [minutes]?

**[More details](database.md)**

### DBFILE
`DBFILE=/etc/pihole/pihole-FTL.db`

Specify path and filename of FTL's SQLite3 long-term database. Setting this to `DBFILE=` disables the database altogether

**[More details](database.md)**

## Debugging options
### DEBUG_DATABASE
`DEBUG_DATABASE=false|true`

Print debugging information about database actions. This prints performed SQL statements as well as some general information such as the time it took to store the queries and how many have been saved to the database.

### DEBUG_NETWORKING
`DEBUG_NETWORKING=false|true`

Prints a list of the detected interfaces on startup of `pihole-FTL`. Also prints whether these interfaces are IPv4 or IPv6 interfaces.

### DEBUG_LOCKS
`DEBUG_LOCKS=false|true`

Print information about shared memory locks. Messages will be generated when waiting, obtaining, and releasing a lock.

### DEBUG_QUERIES
`DEBUG_QUERIES=false|true`

Print extensive query information (domains, types, replies, etc.). This has always been part of the legacy `debug` mode of `pihole-FTL`.

### DEBUG_FLAGS
`DEBUG_FLAGS=false|true`

Print flags of queries received by the DNS hooks. Only effective when `DEBUG_QUERIES` is enabled as well.

### DEBUG_SHMEM
`DEBUG_SHMEM=false|true`

Print information about shared memory buffers. Messages are either about creating or enlarging shmem objects or string injections.

### DEBUG_GC
`DEBUG_GC=false|true`

Print information about garbage collection (GC): What is to be removed, how many have been removed and how long did GC take.

### DEBUG_ARP
`DEBUG_ARP=false|true`

Print information about ARP table processing: How long did parsing take, whether read MAC addresses are valid, and if the `macvendor.db` file exists.

### DEBUG_REGEX
`DEBUG_REGEX=false|true`

Controls if *FTL*DNS should print extended details about regex matching into `pihole-FTL.log`.

**[More details](regex/overview.md)**

Due to legacy reasons, we also support the following setting to be used for enabling the same functionality:

`REGEX_DEBUGMODE=false|true`

Note that if one of them is set to `true`, the other one cannot be used to disable this setting again.

{!abbreviations.md!}
