You can create a file `/etc/pihole/pihole-FTL.conf` that will be read by *FTL*DNS on startup.

Possible settings (**the option shown first is the default**):
### DNS settings

#### `BLOCKINGMODE=NULL|IP-NODATA-AAAA|IP|NXDOMAIN` {#blocking_mode data-toc-label='Blocking Mode'}
How should `FTL` reply to blocked queries?<br>
**[More details](blockingmode.md)**

### Statistics settings

#### `MAXLOGAGE=24.0` {#maxlogage data-toc-label='Max Log Age'}
  Up to how many hours of queries should be imported from the database and logs? Maximum is 744 (31 days)
<hr/>
#### `PRIVACYLEVEL=0|1|2|3|4` {#privacylevel data-toc-label='Privacy Level'}
  Which privacy level is used?<br>
**[More details](privacylevels.md)**
<hr/>
#### `IGNORE_LOCALHOST=no|yes` {#ignore_localhost data-toc-label='Ignore localhost'}
  Should `FTL` ignore queries coming from the local machine?
<hr/>
#### `AAAA_QUERY_ANALYSIS=yes|no` {#aaaa_query_analysis data-toc-label='AAAA Query Analysis'}
  Allow `FTL` to analyze AAAA queries from pihole.log?
<hr/>
#### `ANALYZE_ONLY_A_AND_AAAA=false|true` {#analyze_only_a_and_aaaa data-toc-label='Analyze A and AAAA Only'}
  Should `FTL` only analyze A and AAAA queries?

### Socket settings

#### `SOCKET_LISTENING=localonly|all` {#socket_listening data-toc-label='Socket Listening'}
  Listen only for local socket connections or permit all connections
<hr/>
#### `FTLPORT=4711` {#ftlport data-toc-label='FTLDNS Port'}
  On which port should FTL be listening?

### Host name resolution

#### `RESOLVE_IPV6=yes|no` {#resolve_ipv6 data-toc-label='Resolve IPV6'}
  Should `FTL` try to resolve IPv6 addresses to host names?
<hr/>
#### `RESOLVE_IPV4=yes|no` {#resolve_ipv4 data-toc-label='Resolve IPV4'}
  Should `FTL` try to resolve IPv4 addresses to host names?

### Database settings
**[Further details concerning the database](database.md)**

#### `DBIMPORT=yes|no` {#dbimport data-toc-label='DB Import'}
  Should `FTL` load information from the database on startup to be aware of the most recent history?
<hr/>
#### `MAXDBDAYS=365` {#maxdbdays data-toc-label='Max DB Days'}
  How long should queries be stored in the database? Setting this to `0` disables the database
<hr/>
#### `DBINTERVAL=1.0` {#dbinterval data-toc-label='DB Interval'}
  How often do we store queries in FTL's database [minutes]?
<hr/>
#### `DBFILE=/etc/pihole/pihole-FTL.db` {#dbfile data-toc-label='DB File'}
  Specify path and filename of FTL's SQLite3 long-term database. Setting this to `DBFILE=` disables the database altogether<br>


### Debugging options

#### `REGEX_DEBUGMODE=false|true` {#regex_debugmode data-toc-label='REGEX Debug Mode'}
  Controls if *FTL*DNS should print extended details about regex matching into `pihole-FTL.log`.<br>
  **[More details](regex/overview.md)**


{!abbreviations.md!}