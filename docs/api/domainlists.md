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
        curl -X GET http://pi.hole:8080/admin/api/whitelist/exact \
             -H "Authorization: Token <your-access-token>"
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
        },
        {
            "domain": "whitelisted2.com",
            "enabled": false,
            "date_added": 1589104951,
            "date_modified": 1589104951,
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

## GET: List specific item

Resources:

- `GET /admin/api/whitelist/exact/<domain>`
- `GET /admin/api/whitelist/regex/<domain>`
- `GET /admin/api/blacklist/exact/<domain>`
- `GET /admin/api/blacklist/regex/<domain>`

Requires authorization: Yes

### Parameters

The domain/regex to be listed is specified through the URL (`<domain>`).

### Example

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl -X GET http://pi.hole:8080/admin/api/whitelist/exact/whitelisted.com \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/whitelist/exact/'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        domain = 'whitelisted.com'
        response = requests.get(URL + domain, headers=HEADERS)

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

## POST/PATCH: Add item

Resources:

**Create new entry (error on existing identical record)**

- `POST /admin/api/whitelist/exact`
- `POST /admin/api/whitelist/regex`
- `POST /admin/api/blacklist/exact`
- `POST /admin/api/blacklist/regex`

**Create new or update existing entry (no error on existing record)**

- `PATCH /admin/api/whitelist/exact`
- `PATCH /admin/api/whitelist/regex`
- `PATCH /admin/api/blacklist/exact`
- `PATCH /admin/api/blacklist/regex`

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
        curl -X POST http://pi.hole:8080/admin/api/whitelist/exact \
             -H "Authorization: Token <your-access-token>" \
             -H "Content-Type: application/json" \
             -d '{"domain":"whitelisted.com", "enabled":true, "comment":"Some text"}'
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/whitelist/exact'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}
        data = {"domain":"whitelisted.com", "enabled":True, "comment":"Some text"}

        response = requests.post(URL, json=data, headers=HEADERS)

        print(response.json())
        ```

!!! success "Success response"

    Response code: `HTTP/1.1 201 Created`

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

    When using `PATCH` instead of `POST`, duplicate domains are silently replaced without triggering an error.
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
        domain="whitelisted.com"
        curl -X DELETE http://pi.hole:8080/admin/api/whitelist/exact/${domain} \
             -H "Authorization: Token <your-access-token>"
        ```

        **Regular expression**

        ``` bash
        regex="$(echo -n "(^|\\.)facebook.com$" | jq -sRr '@uri')"
        curl -X DELETE http://pi.hole:8080/admin/api/whitelist/exact/${regex} \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python"

        **Domain**

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/whitelist/exact/'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        domain = 'whitelisted.com'
        response = requests.delete(URL + domain, headers=HEADERS)

        print(response.json())
        ```

        **Regular expression**

        ``` python
        import requests
        import urllib

        URL = 'http://pi.hole:8080/admin/api/whitelist/exact/'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        regex = urllib.parse.quote("(^|\\.)facebook.com$")
        response = requests.delete(URL + regex, headers=HEADERS)

        print(response.json())
        ```

!!! success "Success response"

    Response code: `HTTP/1.1 204 No Content`

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
