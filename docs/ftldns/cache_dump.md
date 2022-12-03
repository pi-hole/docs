## Cache dump interpretation

The `dnsmasq` core embedded into `pihole-FTL` prints a dump of the current cache content into the main log file (default location `/var/log/pihole/pihole.log`) when receiving `SIGUSR1`, e.g. by

``` bash
sudo killall -USR1 pihole-FTL
```

Such a cache dump looks like

``` plain
cache size 10000, 0/20984 cache insertions re-used unexpired cache entries.
queries forwarded 10247, queries answered locally 14713
queries for authoritative zones 0
pool memory in use 22272, max 24048, allocated 480000
server 127.0.0.1#5353: queries sent 10801, retried or failed 69
server 192.168.2.1#53: queries sent 388, retried or failed 3

Host                                     Address                        Flags      Expires
imap.strato.de                 2a01:238:20a:202:54f0::1103              6F         Wed Dec 15 20:51:59 2021
imap.strato.de                 81.169.145.103                           4F         Wed Dec 15 20:51:59 2021
api.github.com                                                          6F   N     Wed Dec 15 20:36:02 2021
www.googleapis.com             2a00:1450:4001:831::200a                 6F         Wed Dec 15 20:34:35 2021
www.googleapis.com             2a00:1450:4001:801::200a                 6F         Wed Dec 15 20:34:35 2021
www.googleapis.com             2a00:1450:4001:80e::200a                 6F         Wed Dec 15 20:34:35 2021
www.googleapis.com             2a00:1450:4001:80f::200a                 6F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.185.170                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.185.202                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.185.234                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.181.234                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             172.217.16.138                           4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.186.42                           4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.186.74                           4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.186.106                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.186.138                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.186.170                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             172.217.18.106                           4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.184.202                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.184.234                          4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             216.58.212.138                           4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.185.74                           4F         Wed Dec 15 20:34:35 2021
www.googleapis.com             142.250.185.106                          4F         Wed Dec 15 20:34:35 2021
KLA                            192.168.2.246                            4F  D      Thu Dec 16 12:49:00 2021
dominik-desktop                192.168.2.224                            4F  D      Thu Dec 16 18:03:49 2021
fritz.repeater                 192.168.2.3                              4FRI   H
lan                                                                      F  D      Thu Dec 16 20:08:29 2021
dominik-laptop.lan             192.168.2.206                            4FR D      Thu Dec 16 20:07:45 2021
dominik-laptop.lan             2a02:b30:f0c:cf00::1ac                   6FR D      Wed Dec 15 21:07:44 2021
dominik-laptop.lan             fd00::1ac                                6FR D      Wed Dec 15 21:07:44 2021
Internet-Radio                 192.168.2.239                            4F  D      Thu Dec 16 12:54:33 2021
Internet-Radio.lan             192.168.2.239                            4FR D      Thu Dec 16 12:54:33 2021
textsecure-service.whispersyst 13.248.212.111                           4F         Wed Dec 15 20:32:00 2021
textsecure-service.whispersyst 76.223.92.165                            4F         Wed Dec 15 20:32:00 2021
textsecure-service.whispersyst                                          6F   N     Wed Dec 15 20:42:00 2021
arduino.hosted-by-discourse.co 184.104.202.141                          4F         Wed Dec 15 20:35:40 2021
arduino.hosted-by-discourse.co 2001:470:1:9a5::141                      6F         Wed Dec 15 20:35:40 2021
posteo.de                      185.67.36.168                            4F      V  Wed Dec 15 20:32:59 2021
posteo.de                      2a05:bc0:1000::168:1                     6F      V  Wed Dec 15 20:32:59 2021
posteo.de                      23244   8 256                            KF      V  Wed Dec 15 20:32:59 2021
posteo.de                      53881   8 257                            KF      V  Wed Dec 15 20:32:59 2021
posteo.de                      53881   8   2                            SF      V  Wed Dec 15 20:46:13 2021
strato.de                                                               SF   N  V  Wed Dec 15 20:51:59 2021
ip6-allnodes                   ff02::1                                  6FRI   H
ubuntu.com                                                              SF   N  V  Thu Dec 16 08:31:26 2021
fritz.2400                     192.168.2.3                              4F I   H
de                             57564   8 256                            KF      V  Wed Dec 15 20:32:59 2021
de                             26755   8 257                            KF      V  Wed Dec 15 20:32:59 2021
de                             63015   8 256                            KF      V  Wed Dec 15 20:32:59 2021
de                             26755   8   2                            SF      V  Thu Dec 16 16:38:18 2021
<Root>                         20326   8 257                            KF      V  Thu Dec 16 17:46:14 2021
<Root>                         14748   8 256                            KF      V  Thu Dec 16 17:46:14 2021
<Root>                         20326   8   2                            SF I
i.stack.imgur.com              ipv4.imgur.map.fastly.net                CF         Fri Dec 17 22:10:29 2021

[...]
```

where we stripped lines like `Dec 15 20:32:02 dnsmasq[4177892]:` for the sake of readability. The format is pretty self-explanatory.

### Cache metrics

``` plain
cache size 10000, 0/20984 cache insertions re-used unexpired cache entries.
```

tells us that the cache size is 10000 (Pi-hole's default value). None of the 20984 cache insertions had to overwrite still valid cache lines. If this number is zero, your cache was sufficiently large at any time. If this number is notably larger than zero, you should consider increasing the cache size.

### Query statistics

``` plain
queries forwarded 10247, queries answered locally 14713
queries for authoritative zones 0
```

Mostly self-explanatory. Queries answered locally can both be from local configuration, HOSTS files, DHCP leases, or from the local cache. Queries for authoritative zones can only appear when defining an authoritative zone (`dnsmasq` option `auth-server`).

### Blockdata statistics

``` plain
pool memory in use 22272, max 24048, allocated 480000
```

Blockdata is used to cache records that do not fit in normal cache records. These are `SRV` targets, and `DNSKEY` and `DS` key data objects. Negative (empty) entries do not occupy blockdata space. Blocks are preallocated to reduce heap fragmentation.

### Server statistics

```
server 127.0.0.1#5353: queries sent 10801, retried or failed 69
server 192.168.2.1#53: queries sent 388, retried or failed 3
```

Self-explanatory: Queries sent, retried, and failed to the individual upstream servers.

### Cache content

The first character of the flags describes the query type:

Character | Record type
----------|------------
`4` | `A` (IPv4 address)
`6` | `AAAA` (IPv6 address)
`C` | `CNAME`
`V` | `SRV`
`S` | `DS`
`K` | `DNSKEY`
`(empty)` | something else

The rest of the flags can be almost any combination of the following bits:

Bit | Interpretation
-------|---------------
`F` | Forward entry (domain-to-address record)
`R` | Reverse entry (address-to-domain, typically combined with `D` or `H`)
`I` | Immortal cache entry (no expiry, typically from local configuration)
`D` | DHCP-provided record
`N` | Negative record (This record does not exist)
`X` | NXDOMAIN (No record exists at all for this domain)
`H` | From HOSTS file (always combined with `I`)
`V` | DNSSEC verified

The `V` flag in negative DS records has a different meaning. Only validated `DS` records are every cached, and the `V` bit is used to store information about the presence of an `NS` record for the domain, i.e., if there's a zone cut at that point.

### Examples

#### `A` (`DHCP` provided)

``` plain
Host                                     Address                        Flags      Expires
Internet-Radio                 192.168.2.239                            4F  D      Thu Dec 16 12:54:33 2021
Internet-Radio.lan             192.168.2.239                            4FR D      Thu Dec 16 12:54:33 2021
```

Both cache entries describe an IPv4 cache record for a device in the local network. The `Internet-Radio.lan` has an `R` as it is the name to be served for a reverse lookup as it includes the local network domain `lan`.

#### `DNSKEY/DS`

``` plain
Host                                     Address                        Flags      Expires
de                             57564   8 256                            KF      V  Wed Dec 15 20:32:59 2021
de                             26755   8 257                            KF      V  Wed Dec 15 20:32:59 2021
de                             63015   8 256                            KF      V  Wed Dec 15 20:32:59 2021
de                             26755   8   2                            SF      V  Thu Dec 16 16:38:18 2021
<Root>                         20326   8 257                            KF      V  Thu Dec 16 17:46:14 2021
<Root>                         14748   8 256                            KF      V  Thu Dec 16 17:46:14 2021
<Root>                         20326   8   2                            SF I
```

The first three cache records are `DNSKEY` records (type `K`) of the `de` domain, the fifth and sixth cache records are `DNSKEY` records of the root zone.
The three numbers in the `address` field correspond to the key tag, the algorithm ID, and the key flags. The fourth and seventh entry corresponds to a `DS` record (type `S`) where the three numbers are the key tag, the used algorithm ID, and the digest.

Note that `DS` records may have an empty `address` field when they are `NODATA` (flag `N`) like

```
Host                                     Address                        Flags      Expires
hosted-by-discourse.com                                                 SF   N  V  Sat Dec 18 11:06:03 2021
```

The `DS` of the root zone is marked *immortal* as it is given by the locally defined `trust-anchor`.

#### `CNAME`

``` plain
Host                                     Address                        Flags      Expires
i.stack.imgur.com              ipv4.imgur.map.fastly.net                CF         Fri Dec 17 22:10:29 2021
```

The `address` field corresponds to the `CNAME` target record.

#### `SRV`

``` plain
Host                                     Address                        Flags      Expires
_sip._tcp.pcscf2.ims.telekom.d 100 10 5062 pspcscfhost2.ims.telekom.de  VF         Sat Dec 18 13:33:37 2021
```

The `address` field lists the priority (`100` in the example), the weight (`10`), and the SRV port (`5062`), followed by the target (`pspcscfhost2.ims.telekom.de`).
