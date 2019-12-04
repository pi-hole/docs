`pihole-FTL` offers an efficient DNS cache that helps speed up your Internet experience. This DNS cache is part of the embedded `dnsmasq` server. Setting the cache size to zero disables caching. The DNS TTL value is used for determining the caching period. `pihole-FTL` clears its cache on receiving `SIGHUP`.

### Cache metrics

The Settings page (System panel, FTL table) gives live information about the cache usage. It obtains its information from `http://pi.hole/admin/api.php?getCacheInfo`.

#### DNS cache size
Size of the DNS domain cache, defaulting to 10,000 entries. You typically specify this number directly in `/etc/dnsmasq.d/01-pihole.conf`. It is the number of entries that can be actively cached at the same time. There is no benefit in enlarging this number *except* if the DNS cache evictions count is larger than zero.

This information may also be queried using `dig +short chaos txt cachesize.bind`

#### DNS cache insertions
Number of total insertions into the cache. This number can be substantially larger than DNS cache size as expiring cache entries naturally make room for new insertions over time. Each lookup with a non-zero TTL will be cached.

This information may also be queried using `dig +short chaos txt insertions.bind`

#### DNS cache evictions
Number of cache entries that had to be removed although the corresponding entries were **not** expired. Old cache entries get removed if the cache is full to make space for more recent domains. The cache size should be increased when this number is larger than zero.

This information may also be queried using `dig +short chaos txt evictions.bind`

{!abbreviations.md!}
