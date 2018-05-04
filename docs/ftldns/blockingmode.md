Pi-hole *FTL*DNS supports two different methods for blocking queries. Both have their advantages and drawbacks. They are summarized on this page. The blocking mode can be configured in `/etc/pihole/pihole-FTL.conf`.

## Pi-hole's IP based blocking
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

## Pi-hole's NXDOMAIN based blocking
`/etc/pihole/pihole-FTL.conf` setting:
```
BLOCKINGMODE=NXDOMAIN
```
Queries DNS queries will be answered with an empty response (no answer section) and status `NXDOMAIN` (*no such domain*)
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
