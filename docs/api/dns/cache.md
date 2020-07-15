# DNS - Cache Info

## Obtain information about Pi-hole's DNS cache

- `GET /api/dns/cache`

<!-- markdownlint-disable code-block-style -->
???+ example "Request (requires authorization)"

    === "cURL"

        ``` bash
        curl -X GET http://pi.hole:8080/api/dns/cacheinfo \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/api/dns/cacheinfo'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        response = requests.get(URL, headers=HEADERS)

        print(response.json())
        ```

    **Parameters**

    None

??? success "Response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "cache_size": 10000,
        "cache_inserted": 509,
        "cache_evicted": 0
    }
    ```

    **Reply type**

    Object

    **Fields**

    ??? info "DNS cache size (`"cache_size": number`)"
        Size of the DNS domain cache, defaulting to 10,000 entries. You typically specify this number directly in `/etc/dnsmasq.d/01-pihole.conf`. It is the number of entries that can be actively cached at the same time. There is no benefit in enlarging this number *except* if the DNS cache evictions count is larger than zero.

        This information may also be queried using `#!bash dig +short chaos txt cachesize.bind`

    ??? info "DNS cache insertions (`"cache_inserted": number`)"

        Number of total insertions into the cache. This number can be substantially larger than DNS cache size as expiring cache entries naturally make room for new insertions over time. Each lookup with a non-zero TTL will be cached.

        This information may also be queried using `#!bash dig +short chaos txt insertions.bind`

    ??? info "DNS cache evictions (`"cache_evicted": number`)"

        The number of cache entries that had to be removed although the corresponding entries were **not** expired. Old cache entries get removed if the cache is full to make space for more recent domains.

        The cache size should be increased when the number of evicted cache entries is larger than zero.

        This information may also be queried using `#!bash dig +short chaos txt evictions.bind`

<!-- markdownlint-enable code-block-style -->

This endpoint cannot fail.

{!abbreviations.md!}
