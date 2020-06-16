# DNS - Domain Lists

## GET: List all items

Resources:

- `GET /admin/api/whitelist/exact`
- `GET /admin/api/whitelist/regex`
- `GET /admin/api/blacklist/exact`
- `GET /admin/api/blacklist/regex`

Requires authorization: Yes

### Parameters

None

### Example

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl -H "Authorization: Token <your-access-token>" \
             http://pi.hole:8080/admin/api/whitelist/exact
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/whitelist/exact'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        response = requests.get(URL, headers=HEADERS)

        print(response.json())
        ```

!!! success "Success response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    [
        {
            "domain": "whitelisted.com",
            "enabled": true,
            "date_added": 1589108911,
            "date_modified": 1589108911,
            "comment": ""
        }
    ]
    ```

!!! failure "Error response (database not available)"

    Response code: `HTTP/1.1 402 - Request failed`

    ``` json
    {
        "error": {
            "key": "database_error",
            "message": "Could not remove domain to gravity database",
            "data": {
                "sql_msg": "Database not available"
            }
        }
    }
    ```
<!-- markdownlint-enable code-block-style -->

## PUT: Add item

Resources:

- `PUT /admin/api/whitelist/exact`
- `PUT /admin/api/whitelist/regex`
- `PUT /admin/api/blacklist/exact`
- `PUT /admin/api/blacklist/regex`

Requires authorization: Yes

### Parameters

Name | Required | Type | Description | Default | Example
---- | -------- | ---- | ----------- | ------- | -------
`domain` | Yes | String | Domain to be added |  |`whitelisted.com`
`enabled` | Optional | Boolean | Should this domain be used? | `true` | `true`
`comment` | Optional | String | Comment for this domain | `null` | `Some text`


### Example

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl http://pi.hole:8080/admin/api/whitelist/exact \
             -X PUT \
             -H "Authorization: Token <your-access-token>" \
             -H "Content-Type: application/json" \
             -d @body.json
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/whitelist/exact'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}
        data = json.load(open('body.json', 'rb'))

        response = requests.put(
            URL,
            json=data,
            headers=HEADERS,
        )

        print(response.json())
        ```

    The content of `body.json` is

    ``` json
    {
        "domain": "whitelisted.com",
        "enabled": true,
        "comment": "Some text"
    }
    ```

!!! success "Success response"

    Response code: `HTTP/1.1 201 Created`

    ``` json
    {
        "key": "added",
        "domain": "whitelisted.com"
    }
    ```

!!! failure "Error response (duplicated domain)"

    Response code: `HTTP/1.1 402 - Request failed`

    ``` json
    {
        "error": {
            "key": "database_error",
            "message": "Could not add domain to gravity database",
            "data": {
                "domain": "whitelisted.com",
                "enabled": true,
                "comment": "Some text",
                "sql_msg": "UNIQUE constraint failed: domainlist.domain"
            }
        }
    }
    ```
<!-- markdownlint-enable code-block-style -->

---

## DELETE: Remove item

Resources:

- `DELETE /admin/api/whitelist/exact/<domain>`
- `DELETE /admin/api/whitelist/regex/<domain>`
- `DELETE /admin/api/blacklist/exact/<domain>`
- `DELETE /admin/api/blacklist/regex/<domain>`

Requires authorization: Yes

### Parameters

The domain/regex to be removed is specified through the URL (`<domain>`).

### Example request

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        **Domain**

        ``` bash
        curl http://pi.hole:8080/admin/api/whitelist/exact/whitelisted.com \
             -X DELETE \
             -H "Authorization: Token <your-access-token>"
        ```

        **Regular expression**

        ``` bash
        regex="$(echo -n "(^|\\.)facebook.com$" | jq -sRr '@uri')"
        curl http://pi.hole:8080/admin/api/whitelist/exact/${regex} \
             -X DELETE \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python"

        **Domain**

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/whitelist/exact/whitelisted.com'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        response = requests.delete(URL, headers=HEADERS)

        print(response.json())
        ```

        **Regular expression**

        ``` python
        import requests
        import urllib

        regex = urllib.parse.quote("(^|\\.)facebook.com$")
        URL = 'http://pi.hole:8080/admin/api/whitelist/exact/'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        response = requests.delete(URL + regex, headers=HEADERS)

        print(response.json())
        ```

!!! success "Success response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "key": "removed",
        "domain": "whitelisted.com"
    }
    ```

!!! failure "Error response (database permission error)"

    Response code: `HTTP/1.1 402 - Request failed`

    ```json
    {
        "error": {
            "key": "database_error",
            "message": "attempt to write a readonly databas",
            "data": {
                "domain": "whitelisted.com",
                "sql_msg": "Database not available"
            }
        }
    }
    ```
<!-- markdownlint-enable code-block-style -->

{!abbreviations.md!}
