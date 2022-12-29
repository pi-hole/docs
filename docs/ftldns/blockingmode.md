Pi-hole *FTL*DNS currently supports the following modes for blocking queries:

* NULL (default and recommended)
* IP-NODATA-AAAA
* IP
* NXDOMAIN
* NODATA

Each mode has their advantages and drawbacks which will be discussed in detail below.

!!! note
    In order to configure a blocking mode, you must edit the *FTL*DNS configuration file (`/etc/pihole/pihole-FTL.conf`). Once you've made any changes to the blocking mode, you must restart Pi-hole with `pihole restartdns`.

## Pi-hole's unspecified IP or NULL blocking mode

In `NULL` mode, which is both the default and recommended mode for Pi-hole *FTL*DNS, blocked queries will be answered with the "unspecified address" (`0.0.0.0` or `::`). The "unspecified address" is a reserved IP address specified by [RFC 3513 - Internet Protocol Version 6 (IPv6) Addressing Architecture, section 2.5.2](https://tools.ietf.org/html/rfc3513#section-2.5.2). If no mode is explicitly defined in the configuration file, Pi-hole will default to this mode. To set this mode explicitly, set `BLOCKINGMODE=NULL` in `/etc/pihole/pihole-FTL.conf`.

A blocked query would look like the following:

```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY

;; ANSWER SECTION:
doubleclick.net.        2       IN      A       0.0.0.0
doubleclick.net.        2       IN      AAAA    ::
```

**Advantages:**

* Clients should not even try to establish a connection for the requested website/address
* Reduces overall traffic
* Solves potential HTTPS timeouts, as requests are never performed
* No need to run a web server on your Pi-hole for a block page. This should reduce complexity when running other web services on the same machine

**Disadvantages:**

* Clients may not handle the unspecified address properly and attempt to connect to the address anyways

## Pi-hole's IP (IPv6 NODATA) blocking mode

In `IP-NODATA-AAAA` mode, blocked queries will be answered with the local IPv4 addresses of your Pi-hole (see [BLOCK_IP4](configfile.md#block_ipv4) for additional options). Blocked AAAA queries will be answered with `NODATA-IPV6` and clients will only try to reach your Pi-hole over its static IPv4 address. To set this mode explicitly, set `BLOCKINGMODE=IP-NODATA-AAAA` in `/etc/pihole/pihole-FTL.conf`.

Assuming your Pi-hole server is at `192.168.1.42`, then a blocked query would look like the following:

```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY

;; ANSWER SECTION:
doubleclick.net.        2       IN      A       192.168.1.42
```

**Advantages:**

* Serves IPv4-only replies and hence mitigates issues with rotating IPv6 prefixes

**Disadvantages:**

* May cause time-outs for HTTPS content even with properly configured firewall rules

## Pi-hole's full IP blocking mode

In `IP` mode, blocked queries will be answered with the local IP addresses of your Pi-hole (see [BLOCK_IP4](configfile.md#block_ipv4) and [BLOCK_IP6](configfile.md#block_ipv6) for additional options). To set this mode explicitly, set `BLOCKINGMODE=IP` in `/etc/pihole/pihole-FTL.conf`.

A blocked query would look like the following:

```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY

;; ANSWER SECTION:
doubleclick.net.        2       IN      A       192.168.2.11
doubleclick.net.        2       IN      AAAA    fda2:2001:4756:0:ab27:beff:ef37:4242
```

**Advantage:**

* Handles both IPv4 and IPv6 queries with a reply

**Disadvantages:**

* May cause time-outs for HTTPS content even with properly configured firewall rules
* May cause problems with alternating prefixes on IPv6 addresses (see `IP-AAAA-NODATA`)

## Pi-hole's NXDOMAIN blocking mode

In `NXDOMAIN` mode, blocked queries will be answered with an empty response (i.e., there won't be an *answer* section) and status `NXDOMAIN`. A `NXDOMAIN` response should indicate that there is *no such domain* to the client making the query. To set this mode explicitly, set `BLOCKINGMODE=NXDOMAIN` in `/etc/pihole/pihole-FTL.conf`.

A blocked query would look like the following:

```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY
```

**Advantages & Disadvantages:** This mode is similar to `NULL` blocking mode, but experiments suggest that clients may try to resolve blocked domains more often compared to `NULL` blocking.

## Pi-hole's NODATA blocking mode

In `NODATA` mode, blocked queries will be answered with an empty response (no answer section) and status `NODATA`. A `NODATA` response indicates that the domain exists, but there is no record for the requested query type. To set this mode explicitly, set `BLOCKINGMODE=NODATA` in `/etc/pihole/pihole-FTL.conf`.

A blocked query would look like the following:

```
;; QUESTION SECTION:
;doubleclick.net.               IN      ANY
```

**Advantages & Disadvantages:** This mode is similar to `NXDOMAIN` blocking mode. Clients might have a better acceptance of `NODATA` replies compared to `NXDOMAIN` replies.

