Connect via e.g. `telnet 127.0.0.1 4711` or use `echo ">command" | nc 127.0.0.1 4711`

#### `>quit` {data-toc-label='quit'}

Closes the connection to the client

---

#### `>stats` {data-toc-label='stats'}

Get current statistics

```text
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

---

#### `>overTime` {data-toc-label='overTime'}

Get over time data (10 min intervals)

```text
1525546500 163 0
1525547100 154 1
1525547700 164 0
1525548300 167 0
1525548900 151 0
1525549500 143 0
[...]
```

---

#### `>top-domains` {data-toc-label='top-domains'}

Get top domains

```text
0 8462 x.y.z.de
1 236 safebrowsing-cache.google.com
2 116 pi.hole
3 109 z.y.x.de
4 93 safebrowsing.google.com
5 96 plus.google.com
[...]
```

Variant: `>top-domains (15)` to show (up to) 15 entries

---

#### `>top-ads` {data-toc-label='top-ads'}

Get top ad domains

```text
0 8 googleads.g.doubleclick.net
1 6 www.googleadservices.com
2 1 cdn.mxpnl.com
3 1 collector.githubapp.com
4 1 www.googletagmanager.com
5 1 s.zkcdn.net
[...]
```

Variant: `>top-ads (14)` to show (up to) 14 entries

---

#### `>top-clients` {data-toc-label='top-clients'}

Get recently active top clients (IP addresses + hostnames (if available))

```text
0 9373 192.168.2.1 router
1 484 192.168.2.2 work-machine
2 8 127.0.0.1 localhost
```

Variant: `>top-clients (9)` to show (up to) 9 client entries or `>top-clients withzero (15)` to show (up to) 15 clients even if they have not been active recently (see PR #124 for further details)

---

#### `>forward-dest` {data-toc-label='forward-dest'}

Get forward destinations (IP addresses + hostnames (if available)) along with the percentage. The first result (ID -2) will always be the percentage of domains answered from blocklists, whereas the second result (ID -1) will be the queries answered from the cache

```text
-2 18.70 blocklist blocklist
-1 67.10 cache cache
0 14.20 127.0.0.1 localhost
```

Variant: `>forward-dest unsorted` to show forward destinations in unsorted order (equivalent to using `>forward-names`)

---

#### `>querytypes` {data-toc-label='querytypes'}

Get collected query types percentage

```text
A (IPv4): 53.45
AAAA (IPv6): 45.32
ANY: 0.00
SRV: 0.64
SOA: 0.05
PTR: 0.54
TXT: 0.00
```

---

#### `>getallqueries` {data-toc-label='getallqueries'}

Get all queries that FTL has in memory

```text
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

Variants:

- `>getallqueries (37)` show (up to) 37 latest entries,
- `>getallqueries-time 1483964295 1483964312` gets all queries that FTL has in its database in a limited time interval,
- `>getallqueries-time 1483964295 1483964312 (17)` show matches in the (up to) 17 latest entries,
- `>getallqueries-domain www.google.com` gets all queries that FTL has in its database for a specific domain name,
- `>getallqueries-client 2.3.4.5`: gets all queries that FTL has in its database for a specific client name *or* IP

---

#### `>recentBlocked` {data-toc-label='recentBlocked'}

Get most recently pi-holed domain name

```text
www.googleadservices.com
```

Variant: `>recentBlocked (4)` show the four most recent blocked domains

---

#### `>clientID` {data-toc-label='clientID'}

Get ID of currently connected client

```text
6
```

---

#### `>version` {data-toc-label='version'}

Get version information of the currently running FTL instance

```text
version v1.6-3-g106498d-dirty
tag v1.6
branch master
hash 106498d
date 2017-03-26 13:10:43 +0200
```

---

#### `>dbstats` {data-toc-label='dbstats'}

Get some statistics about `FTL`'s' long-term storage database (this request may take some time for processing in case of a large database file)

```text
queries in database: 2700304
database filesize: 199.20 MB
SQLite version: 3.23.1
```

---

#### `>cacheinfo` {data-toc-label='cacheinfo'}

Get DNS server cache size and usage information

```text
cache-size: 500000
cache-live-freed: 0
cache-inserted: 15529
```

---

#### `>dns-port` {data-toc-label='dns-port'}

Get DNS port FTL is listening on

```text
53
```

Note that the port can also be `0` if someone decides to disable the DNS server part of Pi-hole

---

#### `>maxlogage` {data-toc-label='maxlogage'}

Get timespan of the statistics shown on the dashboard (in seconds)

```text
86400
```

---

#### `>gateway` {data-toc-label='gateway'}

Get the IP of the gateway of the default route and the corresponding interface

```text
192.168.0.1 enp2s0
```

Note that if no non-default route could be found, `0.0.0.0` and an empty interface string is returned

---

#### `>interfaces` {data-toc-label='interfaces'}

Get extended information of the interfaces of th Pi-hole device

```text
eth0 UP 1000 2.2GB 5.6GB 10.0.1.5 fd00:e57b:XXXX:210e:1a1,2a01:XXXX:c15b,fe80::2e5c:XXXX:4060
wlan0 DOWN -1 0.0B 0.0B - -
docker0 UP 10000 837.6MB 300.7MB 172.17.0.1,169.254.241.237 -
lo UP -1 48.0MB 48.0MB 127.0.0.1 -
wg0 UP -1 1.0GB 141.2MB 10.0.40.1 -
sum UP 0 4.2GB 6.1GB - -
```

Column definitions are:

1. Interface name
2. UP/DOWN status
3. Link speed in MBit/s (-1 means "Not available" (like link down) or "Not applicable" (like virtual interface))
4. TX bytes
5. RX bytes
6. Associated IPv4 addresses
7. Associated IPv6 addresses

The default interface (the one connected to the gateway) will always be the first. The sum will always be the last one - even if you have (for whatever reason) an interface called sum. Regarding the link speed: It won't work for most WiFi interfaces as the speed is not known at the kernel level. Instead, the drivers manage them dynamically depending on package loss, signal strength, etc. - in this case, you'll see link speed -1 as well
