You can create a file `/etc/pihole/pihole-FTL.conf` that will be read by *FTL*DNS on startup.

Possible settings (**the option shown first is the default**):

### SOCKET_LISTENING
`SOCKET_LISTENING=localonly|all`

Listen only for local socket connections or permit all connections

### AAAA_QUERY_ANALYSIS
`AAAA_QUERY_ANALYSIS=yes|no`

Allow `FTL` to analyze AAAA queries from pihole.log?

### RESOLVE_IPV6
`RESOLVE_IPV6=yes|no`

Should `FTL` try to resolve IPv6 addresses to host names?

### RESOLVE_IPV4
`RESOLVE_IPV4=yes|no`

Should `FTL` try to resolve IPv4 addresses to host names?

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

### MAXLOGAGE
`MAXLOGAGE=24.0`

Up to how many hours of queries should be imported from the database and logs? Maximum is 744 (31 days)

### FTLPORT
`FTLPORT=4711`

On which port should FTL be listening?

### PRIVACYLEVEL
`PRIVACYLEVEL=0|1|2|3|4`

Which privacy level is used?

**[More details](privacylevels.md)**

### IGNORE_LOCALHOST
`IGNORE_LOCALHOST=no|yes`

Should `FTL` ignore queries coming from the local machine?

### BLOCKINGMODE
`BLOCKINGMODE=NULL|IP-AAAA-NODATA|IP|NXDOMAIN`

How should `FTL` reply to blocked queries?

**[More details](blockingmode.md)**

### REGEX_DEBUGMODE
```
REGEX_DEBUGMODE=false|true
```

Controls if *FTL*DNS should print extended details about regex matching into `pihole-FTL.log`.

**[More details](regex/overview.md)**


{!abbreviations.md!}
