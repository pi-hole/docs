`pihole-FTL` offers an efficient DNS cache that helps speed up your Internet experience. This DNS cache is part of the embedded `dnsmasq` server. Setting the cache size to zero (`dns.cache.size = 0`) disables caching. The DNS TTL value is used for determining the caching period. `pihole-FTL` clears its cache on receiving `SIGHUP`. The cache is not persistent across restarts.

<!-- markdownlint-disable code-block-style -->
!!! warning Some warning about the DNS cache size
    **There is no benefit in increasing this number *unless* the number of DNS cache evictions is greater than zero.**

    A larger cache *will* consume more memory on your node, leaving less memory available for other caches of your Pi-hole. If you push this number to the extremes, it may even be that your Pi-hole gets short on memory and does not operate as expected.

    You cannot reduce the cache size below `150` when DNSSEC is enabled because the DNSSEC validation process uses the cache.

    If cache evictions are frequently occurring, monitor the performance and consider optimizing your DNS configuration by increasing `dns.cache.size`.
<!-- markdownlint-enable code-block-style -->

## Query cache optimizer (`dns.cache.optimizer`)

If a DNS name exists in the cache, but its time-to-live (TTL) has expired only recently, the data will be used anyway (a refreshing from upstream is triggered). This can improve DNS query delays especially over unreliable or slow Internet connections. This feature comes at the expense of possibly sometimes returning out-of-date data and less efficient cache utilization, since old data cannot be flushed when its TTL expires, so the cache becomes mostly least-recently-used. To mitigate issues caused by massively outdated DNS replies, the maximum overaging of cached records is limited. We strongly recommend staying below 86400 (1 day) with this option. The default value of `dns.cache.optimizer` is one hour (`3600` seconds) which was carefully tested to provide a good balance between cache efficiency and query performance without having otherwise adverse effects. Our investigations revealed, that there has always been a grace time larger than an hour in addition to the TTL of DNS records, so this value should be safe for any practical use cases.

## Cacheing of queries blocked upstream (`dns.cache.upstreamBlockedTTL`)

This setting allows you to specify the TTL used for queries blocked upstream. Once the TTL expires, the query will be forwarded to the upstream server again to check if the block is still valid. Defaults to caching for one day (86400 seconds). Setting `dns.cache.upstreamBlockedTTL` to zero disables caching of queries blocked upstream.

## Cache metrics

The Settings -> System page gives live information about the cache usage. The following metrics are available:

### DNS cache size (`dns.cache.size`)

Size of the DNS domain cache, defaulting to 10,000 entries. It is the number of entries that can be actively cached at the same time.
This information may also be queried using `dig +short chaos txt cachesize.bind`.

### Active cache records

Number of *active* cache entries. It is the sum of all still valid and expired cache entries (see below) and is by definition always less than or equal to the cache size. If the number of active cache records is close to the cache size (> 90%), the cache size can be increased as a precaution to avoid cache evictions.

### Total cache insertions

Number of total insertions into the cache. This number can be substantially larger than DNS cache size as expiring cache entries naturally make room for new insertions over time. Each lookup with a non-zero TTL will be cached.

This information may also be queried using `dig +short chaos txt insertions.bind`

### DNS cache evictions

The number of cache entries that had to be removed although the corresponding entries were **not** expired. Old cache entries get removed if the cache is full to make space for more recent domains. **The cache size should be increased when this number is larger than zero.** Optimizing your cache settings is crucial for maintaining optimal performance and resource utilization. It is advisable to regularly check for evictions to ensure your DNS cache operates effectively.

This information may also be queried using `dig +short chaos txt evictions.bind`

### Expired cache entries

The number of cache entries that have expired. These queries may be served from the cache if the query cache optimizer is enabled and the cache entry is not too old when the query is made. The number of expired entries is part of the active cache records if the query optimizer is enabled.

### Immortal cache entries

The number of cache entries that have been marked as immortal. These entries will never expire. As such, they are part of the active cache entries.

### Pie chart

The pie chart shows the current cache utilization broken down into the individual cached record types and their status (active, stale = expired).
