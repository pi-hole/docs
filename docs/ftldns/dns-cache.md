`pihole-FTL` offers an efficient DNS cache that helps speed up your Internet experience. This DNS cache is part of the embedded `dnsmasq` server. Setting the cache size to zero disables caching. The DNS TTL value is used for determining the caching period. `pihole-FTL` clears its cache on receiving `SIGHUP`.

<!-- markdownlint-disable code-block-style -->
!!! warning Some warning about the DNS cache size
    **There is no benefit in increasing this number *unless* the number of DNS cache evictions is greater than zero.**

    A larger cache *will* consume more memory on your node, leaving less memory available for other caches of your Pi-hole. If you push this number to the extremes, it may even be that your Pi-hole gets short on memory and does not operate as expected.

    You can not reduce the cache size below `150` when DNSSEC is enabled because the DNSSEC validation process uses the cache.
<!-- markdownlint-enable code-block-style -->

### Cache metrics

The Settings page (System panel, FTL table) gives live information about the cache usage. It obtains its information from `http://pi.hole/admin/api.php?getCacheInfo`.

#### DNS cache size

Size of the DNS domain cache, defaulting to 10,000 entries. It is the number of entries that can be actively cached at the same time.
This information may also be queried using `dig +short chaos txt cachesize.bind`

The cache size is set in `/etc/dnsmasq.d/01-pihole.conf`. However, note that this setting does not survive Pi-hole updates. If you want to change the cache size permanently, add a setting

```plain
CACHE_SIZE=12345
```

in `/etc/pihole/setupVars.conf` and run `pihole -r` (Repair) to get the cache size changed for you automatically.

#### DNS cache insertions

Number of total insertions into the cache. This number can be substantially larger than DNS cache size as expiring cache entries naturally make room for new insertions over time. Each lookup with a non-zero TTL will be cached.

This information may also be queried using `dig +short chaos txt insertions.bind`

#### DNS cache evictions

The number of cache entries that had to be removed although the corresponding entries were **not** expired. Old cache entries get removed if the cache is full to make space for more recent domains. The cache size should be increased when this number is larger than zero.

This information may also be queried using `dig +short chaos txt evictions.bind`
