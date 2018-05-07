Connect via e.g. `telnet 127.0.0.1 4711` or use `echo ">command" | nc 127.0.0.1 4711`

- `>quit`: Closes connection to client

- `>kill`: Terminates `FTL`

- `>stats` : Get current statistics
 ```
 domains_being_blocked 116007
 dns_queries_today 30163
 ads_blocked_today 5650
 ads_percentage_today 18.731558
 unique_domains 1056
 queries_forwarded 4275
 queries_cached 20238
 clients_ever_seen 11
 unique_clients 9
 status enabled
 ```

- `>overTime` : over time data (10 min intervals)
 ```
 1525546500 163 0
 1525547100 154 1
 1525547700 164 0
 1525548300 167 0
 1525548900 151 0
 1525549500 143 0
 [...]
 ```

- `>top-domains` : get top domains
 ```
 0 8462 x.y.z.de
 1 236 safebrowsing-cache.google.com
 2 116 pi.hole
 3 109 z.y.x.de
 4 93 safebrowsing.google.com
 5 96 plus.google.com
 [...]
 ```
 Variant: `>top-domains (15)` to show (up to) 15 entries

- `>top-ads` : get top ad domains
 ```
 0 8 googleads.g.doubleclick.net
 1 6 www.googleadservices.com
 2 1 cdn.mxpnl.com
 3 1 collector.githubapp.com
 4 1 www.googletagmanager.com
 5 1 s.zkcdn.net
 [...]
 ```
 Variant: `>top-ads (14)` to show (up to) 14 entries

- `top-clients` : get recently active top clients (IP addresses + host names (if available))
 ```
 0 9373 192.168.2.1 router
 1 484 192.168.2.2 work-machine
 2 8 127.0.0.1 localhost
 ```
 Variant: `>top-clients (9)` to show (up to) 9 client entries or `>top-clients withzero (15)` to show (up to) 15 clients even if they have not been active recently (see PR #124 for further details)

- `>forward-dest` : get forward destinations (IP addresses + host names (if available)) along with the percentage. The first result (ID -2) will always be the percentage of domains answered from blocklists, whereas the second result (ID -1) will be the queries answered from cache
 ```
 -2 18.70 blocklist blocklist
 -1 67.10 cache cache
 0 14.20 127.0.0.1 localhost
 ```
 Variant: `>forward-dest unsorted` to show forward destinations in unsorted order (equivalent to using `>forward-names`)

- `>querytypes` : get collected query types percentage
 ```
 A (IPv4): 53.45
 AAAA (IPv6): 45.32
 ANY: 0.00
 SRV: 0.64
 SOA: 0.05
 PTR: 0.54
 TXT: 0.00
 ```

- `>getallqueries` : get all queries that FTL has in memory
 ```
 1525554586 A fonts.googleapis.com 192.168.2.100 3 0 4 6
 1525554586 AAAA fonts.googleapis.com 192.168.2.100 3 0 4 5
 1525554586 A www.mkdocs.org 192.168.2.100 3 0 4 7
 1525554586 AAAA www.mkdocs.org 192.168.2.100 2 0 3 21
 1525554586 A squidfunk.github.io 192.168.2.100 2 0 3 20
 1525554586 A pi-hole.net 192.168.2.100 3 0 4 5
 1525554586 AAAA squidfunk.github.io 192.168.2.100 3 0 1 6
 1525554586 AAAA pi-hole.net 192.168.2.100 2 0 1 18
 1525554586 A github.com 192.168.2.100 3 0 4 5
 1525554586 AAAA github.com 192.168.2.100 2 0 1 18
 ```
 Variants: `>getallqueries (37)` show (up to) 37 latest entries, `>getallqueries-time 1483964295 1483964312` gets all queries that FTL has in its database in a limited time interval, `>getallqueries-time 1483964295 1483964312 (17)` show matches in the (up to) 17 latest entries, `>getallqueries-domain www.google.com` gets all queries that FTL has in its database for a specific domain name, `>getallqueries-client 2.3.4.5` : gets all queries that FTL has in its database for a specific client name *or* IP

- `>recentBlocked` : get most recently pi-holed domain name
 ```
 www.googleadservices.com
 ```
 Variant: `>recentBlocked (4)` show the four most recent blocked domains

- `>memory` : get information about `FTL`'s memory usage due to its internal data structure
 ```
 memory allocated for internal data structure: 2944708 bytes (2.94 MB)
 dynamically allocated allocated memory used for strings: 23963 bytes (23.96 KB)
 Sum: 2968671 bytes (2.97 MB)
 ```

- `>clientID` : Get ID of currently connected client
 ```
 6
 ```

- `>version` : Get version information of the currently running FTL instance
 ```
 version v1.6-3-g106498d-dirty
 tag v1.6
 branch master
 date 2017-03-26 13:10:43 +0200
 ```

- `>dbstats` : Get some statistics about `FTL`'s' long-term storage database (this request may take some time for processing in case of a large database file)
 ```
 queries in database: 2700304
 database filesize: 199.20 MB
 SQLite version: 3.23.1
 ```

- `>domain pi-hole.net`: Get detailed information about domain (if available)
 ```
 Domain "pi-hole.net", ID: 254
 Total: 179
 Blocked: 0
 Wildcard blocked: false
 ```

 - `>cacheinfo`: Get DNS server cache size and usage information
 ```
 cache-size: 500000
 cache-live-freed: 0
 cache-inserted: 15529
 ```

{!abbreviations.md!}
