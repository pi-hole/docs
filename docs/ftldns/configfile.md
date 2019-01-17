You can create a file `/etc/pihole/pihole-FTL.conf` that will be read by *FTL*DNS on startup.

Possible settings (**the option shown first is the default**):
### DNS settings

- <div class="anchor" id="blocking_mode"></div>
  `BLOCKINGMODE=NULL|IP-NODATA-AAAA|IP|NXDOMAIN`<br>
  How should `FTL` reply to blocked queries?<br>
**[More details](blockingmode.md)**

### Statistics settings

- <div class="anchor" id="maxlogage"></div>
  `MAXLOGAGE=24.0`<br>
  Up to how many hours of queries should be imported from the database and logs? Maximum is 744 (31 days)

- <div class="anchor" id="privacylevel"></div>
  `PRIVACYLEVEL=0|1|2|3|4`<br>
  Which privacy level is used?<br>
**[More details](privacylevels.md)**

- <div class="anchor" id="ignore_localhost"></div>
  `IGNORE_LOCALHOST=no|yes`<br>
  Should `FTL` ignore queries coming from the local machine?

- <div class="anchor" id="aaaa_query_analysis"></div>
  `AAAA_QUERY_ANALYSIS=yes|no`<br>
  Allow `FTL` to analyze AAAA queries from pihole.log?

- <div class="anchor" id="analyze_only_a_and_aaaa"></div>
  `ANALYZE_ONLY_A_AND_AAAA=false|true`<br>
  Should `FTL` only analyze A and AAAA queries?

### Socket settings

- <div class="anchor" id="socket_listening"></div>
  `SOCKET_LISTENING=localonly|all`<br>
  Listen only for local socket connections or permit all connections

- <div class="anchor" id="ftlport"></div>
  `FTLPORT=4711`<br>
  On which port should FTL be listening?

### Host name resolution

- <div class="anchor" id="resolve_ipv6"></div>
  `RESOLVE_IPV6=yes|no`<br>
  Should `FTL` try to resolve IPv6 addresses to host names?

- <div class="anchor" id="resolve_ipv4"></div>
  `RESOLVE_IPV4=yes|no`<br>
  Should `FTL` try to resolve IPv4 addresses to host names?

### Database settings
**[Further details concerning the database](database.md)**

- <div class="anchor" id="dbimport"></div>
  `DBIMPORT=yes|no`<br>
  Should `FTL` load information from the database on startup to be aware of the most recent history?

- <div class="anchor" id="maxdbdays"></div>
  `MAXDBDAYS=365`<br>
  How long should queries be stored in the database? Setting this to `0` disables the database

- <div class="anchor" id="dbinterval"></div>
  `DBINTERVAL=1.0`<br>
  How often do we store queries in FTL's database [minutes]?

- <div class="anchor" id="dbfile"></div>
  `DBFILE=/etc/pihole/pihole-FTL.db`<br>
  Specify path and filename of FTL's SQLite3 long-term database. Setting this to `DBFILE=` disables the database altogether<br>


### Debugging options

- <div class="anchor" id="regex_debugmode"></div>
  `REGEX_DEBUGMODE=false|true`<br>
  Controls if *FTL*DNS should print extended details about regex matching into `pihole-FTL.log`.<br>
  **[More details](regex/overview.md)**


{!abbreviations.md!}
