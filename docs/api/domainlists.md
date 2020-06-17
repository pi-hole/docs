# DNS - Domain Lists

## List all items

- `GET /api/whitelist/exact`
- `GET /api/whitelist/regex`
- `GET /api/blacklist/exact`
- `GET /api/blacklist/regex`

<!-- markdownlint-disable code-block-style -->
???+ example "Request (required authorization)"

    === "cURL"

        ``` bash
        curl -X GET http://pi.hole:8080/api/whitelist/exact \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/api/whitelist/exact'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        response = requests.get(URL, headers=HEADERS)

        print(response.json())
        ```

    **Parameters**

    None

??? success "Success response"

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
            "comment": null
        }
    ]
    ```

    **Reply type**

    Array of objects (may be empty if no item of the requested flavor exist)

    **Fields**

    ??? info "Domain/regular expression (`"domain": string`)"
        Item depending on the list type.

    ??? info "Enabled (`"enabled": boolean`)"
        Whether this item is enabled or disabled.

    ??? info "Addition time (`"date_added": number`)"
        Unix timestamp of addition of this item to Pi-hole's database.

    ??? info "Modification time (`"date_modified": number`)"
        Unix timestamp of modification of this item in Pi-hole's database.

    ??? info "Comment (`"comment": [null|string]`)"
        User-provided free-text comment for this item. May be `null` if not specified.

??? failure "Error response"

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

## List specific item

- `GET /api/whitelist/exact/<domain>`
- `GET /api/whitelist/regex/<domain>`
- `GET /api/blacklist/exact/<domain>`
- `GET /api/blacklist/regex/<domain>`

<!-- markdownlint-disable code-block-style -->
???+ example "Request (required authorization)"

    === "cURL"

        ``` bash
        curl -X GET http://pi.hole:8080/api/whitelist/exact/whitelisted.com \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/api/whitelist/exact/'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        domain = 'whitelisted.com'
        response = requests.get(URL + domain, headers=HEADERS)

        print(response.json())
        ```

    **Parameters**

    Specify the requested item through the URL (`<domain>`)

??? success "Success response"

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

    **Fields**

    See description of the `GET` request above.

??? failure "Error response"

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

## Add/update item

**Create new entry (error on existing identical record)**

- `POST /api/whitelist/exact`
- `POST /api/whitelist/regex`
- `POST /api/blacklist/exact`
- `POST /api/blacklist/regex`

**Create new or update existing entry (no error on existing record)**

- `PATCH /api/whitelist/exact`
- `PATCH /api/whitelist/regex`
- `PATCH /api/blacklist/exact`
- `PATCH /api/blacklist/regex`

<!-- markdownlint-disable code-block-style -->
???+ example "Request (required authorization)"

    === "cURL"

        ``` bash
        curl -X POST http://pi.hole:8080/api/whitelist/exact \
             -H "Authorization: Token <your-access-token>" \
             -H "Content-Type: application/json" \
             -d '{"domain": "whitelisted.com", "enabled": true, "comment": "Some text"}'
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/api/whitelist/exact'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}
        data = {"domain": "whitelisted.com", "enabled": True, "comment": "Some text"}

        response = requests.post(URL, json=data, headers=HEADERS)

        print(response.json())
        ```

    **Required parameters**

    ??? info "Domain/regular expression (`"domain": string`)"
        Domain or (JSON-escaped) regular expression to be added to the database.

    **Optional parameters**

    ??? info "Enabled (`"enabled": boolean`)"
        Whether this item should be added as enabled or disabled.

    ??? info "Comment (`"comment": string`)"
        User-provided free-text comment for this item.

??? success "Success response"

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

    **Fields**

    See description of the `GET` request above.

??? failure "Error response"

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

    !!! hint "Hint: Use `PATCH` instead of `POST`"
        When using `PATCH` instead of `POST`, duplicate domains are silently replaced without issuing an error.
<!-- markdownlint-enable code-block-style -->

---

## Remove item

- `DELETE /api/whitelist/exact/<domain>`
- `DELETE /api/whitelist/regex/<domain>`
- `DELETE /api/blacklist/exact/<domain>`
- `DELETE /api/blacklist/regex/<domain>`

<!-- markdownlint-disable code-block-style -->
???+ example "Request (required authorization)"

    === "cURL"

        **Domain**

        ``` bash
        domain="whitelisted.com"
        curl -X DELETE http://pi.hole:8080/api/whitelist/exact/${domain} \
             -H "Authorization: Token <your-access-token>"
        ```

        **Regular expression**

        ``` bash
        regex="$(echo -n "(^|\\.)facebook.com$" | jq -sRr '@uri')"
        curl -X DELETE http://pi.hole:8080/api/whitelist/exact/${regex} \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python"

        **Domain**

        ``` python
        import requests

        URL = 'http://pi.hole:8080/api/whitelist/exact/'
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

        URL = 'http://pi.hole:8080/api/whitelist/exact/'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        regex = urllib.parse.quote("(^|\\.)facebook.com$")
        response = requests.delete(URL + regex, headers=HEADERS)

        print(response.json())
        ```

    **Parameters**

    Specify the requested item through the URL (`<domain>`)

??? success "Success response"

    Response code: `HTTP/1.1 204 No Content`

??? failure "Error response (database permission error)"

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
