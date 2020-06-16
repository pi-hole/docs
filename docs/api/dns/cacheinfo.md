# DNS - Cache Info

## GET: Obtain cache information

Resource: `GET /admin/api/dns/cacheinfo`

Requires authorization: No

### Parameters

None

### Example

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl http://pi.hole:8080/admin/api/dns/cacheinfo \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/dns/cacheinfo'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        response = requests.get(URL, headers=HEADERS)

        print(response.json())
        ```

!!! success "Response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "cache_size": 10000,
        "cache_inserted": 509,
        "cache_evicted": 0
    }
    ```
<!-- markdownlint-enable code-block-style -->

See [DNS cache details](../../ftldns/dns-cache.md) for further information about the returned quantities.

This endpoint cannot fail.

{!abbreviations.md!}
