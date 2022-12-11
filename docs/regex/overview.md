A regular expression, or RegEx for short, is a pattern that **can be used for building arbitrarily complex filter** rules in *FTL*DNS.
We implement the POSIX Extended Regular Expressions similar to the one used by the UNIX `egrep` (or `grep -E`) command. We amend the regex engine by approximate blocking (compare to `agrep`) and other special features like matching to specific query types only.

Our implementation is light and fast as each domain is only checked once for a match. When you query `google.com`, it will be checked against your RegEx. Any subsequent query to the same domain will not be checked again until you restart `pihole-FTL`.

## Hierarchy of regex filters in *FTL*DNS

*FTL*DNS uses a specific hierarchy to ensure regex filters work as you expect them to. Whitelisting always has priority over blacklisting.
There are two locations where regex filters are important:

1. On loading the blocking domains form the `gravity` database table, *FTL*DNS skips not only exactly whitelisted domains but also those that match enabled whitelist regex filters.
2. When a queried domain matches a blacklist regex filter, the query will *not* be blocked if the domain *also* matches an exact or a regex whitelist entry.

## How to use regular expressions for filtering domains

*FTL*DNS reads in regular expression filters from the two [`regex` database views](../database/gravity/index.md).
To tell *FTL*DNS to reload the list of regex filters, either:

- Execute `pihole restartdns reload-lists` or
- Send `SIGHUP` to `pihole-FTL` (`sudo killall -SIGHUP pihole-FTL`) or
- Restart the service (`sudo service pihole-FTL restart`)

The first command is to be preferred as it ensures that the DNS cache itself remains intact. Hence, it is also the fastest of the available options.

## Pi-hole Regex debugging mode

To ease the usage of regular expression filters in *FTL*DNS, we offer a regex debugging mode. Set

```plain
DEBUG_REGEX=true
```

in your `/etc/pihole/pihole-FTL.conf` and restart `pihole-FTL` to enable or disable this mode.

Once the debugging mode is enabled, each match will be logged to `/var/log/pihole/FTL.log` in the following format:

```text
[2018-07-17 17:40:51.304] Regex blacklist (DB ID 15) >> MATCH: "whatever.twitter.com" vs. "((^)|(\.))twitter\."
```

The given DB ID corresponds to the ID of the corresponding row in the `domainlist` database table.

Note that validation is only done on the first occurrence of a domain to increase the computational efficiency of *FTL*DNS. The result of this evaluation is stored in an internal DNS cache that is separate from `dnsmasq`'s own DNS cache. This allows us to only flush this special cache when modifying the black- and whitelists *without* having to flush the entire DNS cache collected so far.
