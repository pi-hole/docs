Pi-hole *FTL*DNS supports two different methods for blocking queries. Both have their advantages and drawbacks. They are summarized on this page. The blocking mode can be configured in `/etc/pihole/pihole-FTL.conf`.

This setting can be updated by sending `SIGHUP` to `pihole-FTL` (`sudo killall -SIGHUP pihole-FTL`).

## Pi-hole's IP blocking
`/etc/pihole/pihole-FTL.conf` setting:
```
BLOCKINGMODE=IP
```

Queries will be answered with the local IP addresses of your Pi-hole (as configured in your `setupVars.conf` file)
```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY

;; ANSWER SECTION:
doubleclick.net.        2       IN      A       192.168.2.11
doubleclick.net.        2       IN      AAAA    fda2:2001:4756:0:ab27:beff:ef37:4242
```

##### Advantage
- Shows blocking page from which blocked webpages can be whitelisted

##### Disadvantages
- Requires a webserver to run on your Pi-hole
- May cause time-outs for HTTPS content even with properly configured firewall rules

## Pi-hole's NXDOMAIN blocking
`/etc/pihole/pihole-FTL.conf` setting:
```
BLOCKINGMODE=NXDOMAIN
```
Queries will be answered with an empty response (no answer section) and status `NXDOMAIN` (*no such domain*)
```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY
```

##### Advantages
- The client does not even try to establish a connection for the requested website
- Speedup and less traffic
- Solves potential HTTPS timeouts as requests are never performed
- No need to run a webserver on your Pi-hole (reduces complexity when running other web services on the same machine)

##### Disadvantage
- Blocking page cannot be shown and whitelisting has to be performed from the dashboard or CLI

## Pi-hole's unspecified IP blocking
`/etc/pihole/pihole-FTL.conf` setting:
```
BLOCKINGMODE=NULL
```

Queries will be answered with the unspecified address
```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY

;; ANSWER SECTION:
doubleclick.net.        2       IN      A       0.0.0.0
doubleclick.net.        2       IN      AAAA    ::
```

Following [RFC 3513, Internet Protocol Version 6 (IPv6) Addressing Architecture, section 2.5.2](https://tools.ietf.org/html/rfc3513#section-2.5.2), the address `0:0:0:0:0:0:0:0` (or `::` for short) is the unspecified address. It must never be assigned to any node and indicates the absence of an address. Following [RFC1122, section 3.2](https://tools.ietf.org/html/rfc1122#section-3.2), the address `0.0.0.0` can be understood as the IPv4 equivalent of `::`.

##### Advantages & Disadvantages
Similar to `NXDOMAIN` blocking. However, it is more experimental than `NXDOMAIN` as it is not clear if all clients behave correctly when receiving these addresses.

{!abbreviations.md!}
