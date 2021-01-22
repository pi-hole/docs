# DNS - Domain Lists

## List all domains/regex

- `GET /api/domains` (all domains + regex)
- `GET /api/domains/allow` (only allowed domains + regex)
- `GET /api/domains/allow/exact` (only allowed domains)
- `GET /api/domains/allow/regex` (only allowed regex)
- `GET /api/domains/deny` (only denied domains + regex)
- `GET /api/domains/deny/exact` (only denied domains)
- `GET /api/domains/deny/regex` (only denied regex)
- `GET /api/domains/exact` (allowed + denied domain)
- `GET /api/domains/regex` (allowed + denied regex)

<!-- markdownlint-disable code-block-style -->
???+ example "🔒 Request"

    === "cURL"

        ``` bash
        curl -X GET http://pi.hole/api/domains \
             -d sid="$sid"
        ```

    === "Python 3"

        ``` python
        import requests

        url = 'http://pi.hole:8080/api/domains'
        sid = '<valid session id>'
        data = {"sid": sid}

        response = requests.get(url, json=data)

        print(response.json())
        ```

    **Parameters**

    None

??? success "Success response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "domains":  [{
                "id":             0,
                "domain":         "allowed.com",
                "type":           "allow/exact",
                "comment":        null,
                "groups":         [0],
                "enabled":        true,
                "date_added":     1611239095,
                "date_modified":  1611239095
        }, {
                "id":             1,
                "domain":         "allowed_disabled.com",
                "type":           "allow/exact",
                "comment":        null,
                "groups":         [0],
                "enabled":        false,
                "date_added":     1611239100,
                "date_modified":  1611239136
        }, {
                "id":             2,
                "domain":         "denied.com",
                "type":           "deny/exact",
                "comment":        null,
                "groups":         [0],
                "enabled":        true,
                "date_added":     1611239144,
                "date_modified":  1611239144
        }, {
                "id":             3,
                "domain":         "regex_deny_rule",
                "type":           "deny/regex",
                "comment":        null,
                "groups":         [0],
                "enabled":        true,
                "date_added":     1611239170,
                "date_modified":  1611239170
        }]
    }
    ```

    **Reply type**

    Array of objects (may be empty if no item of the requested flavor exist)

    **Fields**

    ??? info "Database ID (`"id": number`)"
        Database ID of this domain/regular expression

    ??? info "Domain/regex (`"domain": string`)"
        Item depending on the list type.

    ??? info "Type of entry (`"type": string`)"
        String specifying item type. Can be one of
        - `allow/exact`
        - `deny/exact`
        - `allow/regex`
        - `deny/regex`

    ??? info "Comment (`"comment": [null|string]`)"
        User-provided free-text comment for this item. May be `null` if not specified.

    ??? info "Group associations (`"groups": array)"
        Array of group IDs this item is associated with.

    ??? info "Enabled (`"enabled": boolean`)"
        Whether this item is enabled or disabled.

    ??? info "Addition time (`"date_added": number`)"
        Unix timestamp of addition of this item to Pi-hole's database.

        Use `#!bash date -d @1589108911` to obtain a human-readable datetime string.

    ??? info "Modification time (`"date_modified": number`)"
        Unix timestamp of modification of this item in Pi-hole's database.

        Use `#!bash date -d @1589104951` to obtain a human-readable datetime string.

??? failure "Error response"

    Response code: `HTTP/1.1 400 - Bad request`

    ``` json
    {
        "error": {
            "key": "database_error",
            "message": "Could not read domains from database table",
            "data": {
                "sql_msg": "Database not available"
            }
        }
    }
    ```
<!-- markdownlint-enable code-block-style -->

## List specific domain/regex

- `GET /api/domains/allow/exact/<domain or regex>`
- `GET /api/domains/allow/regex/<domain or regex>`
- `GET /api/domains/allow/exact/<domain or regex>`
- `GET /api/domains/allow/regex/<domain or regex>`

<!-- markdownlint-disable code-block-style -->
???+ example "🔒 Request"

    === "cURL"

        ``` bash
        domain="allowed.com"
        curl -X GET http://pi.hole/api/domains/allow/exact/domains/${domain} \
             -d sid=$sid
        ```

    === "Python 3"

        ``` python
        import requests

        domain = 'allowed.com'
        url = 'http://pi.hole:8080/api/domains/allow/exact/' + domain
        sid = '<valid session id>'
        data = {"sid": sid}

        response = requests.get(url, json=data)

        print(response.json())
        ```

    **Parameters**

    Specify the requested item through the URL (`<domain>`)

??? success "Success response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "domains":  [{
                "id":             0,
                "domain":         "allowed.com",
                "type":           "allow/exact",
                "comment":        null,
                "groups":         [0],
                "enabled":        true,
                "date_added":     1611239095,
                "date_modified":  1611239095
        }]
    }
    ```

    **Fields**

    See description of the `GET` request above.

??? failure "Error response"

    Response code: `HTTP/1.1 400 - Bad request`

    ``` json
    {
        "error": {
            "key": "database_error",
            "message": "Could not read domains from database table",
            "data": {
                "sql_msg": "Database not available"
            }
        }
    }
    ```
<!-- markdownlint-enable code-block-style -->

## Add domain/regex

**Create new entry (error on existing identical record)**

- `POST /api/domains/allow/exact/<domain or regex>`
- `POST /api/domains/allow/regex/<domain or regex>`
- `POST /api/domains/allow/exact/<domain or regex>`
- `POST /api/domains/allow/regex/<domain or regex>`

<!-- markdownlint-disable code-block-style -->
???+ example "🔒 Request"

    === "cURL"

        ``` bash
        domain="allowed2.com"
        curl -X POST http://pi.hole/api/domains/allow/exact/${domain} \
             -d sid=$sid \
             -H "Content-Type: application/json" \
             -d '{"enabled": true, "comment": "Some text"}'
        ```

    === "Python 3"

        ``` python
        import requests

        domain = "allowed2.com"
        url = 'http://pi.hole:8080/api/domains/allow/exact/' + domain
        sid = '<valid session id>'
        data = {
            "enabled": True,
            "comment": "Some text",
            "sid": sid
        }

        response = requests.post(url, json=data)

        print(response.json())
        ```

    **Optional parameters**

    ??? info "Enabled (`"enabled": boolean`)"
        Whether this item should enabled or not.

    ??? info "Comment (`"comment": string`)"
        User-provided free-text comment for this item.

??? success "Success response"

    Response code: `HTTP/1.1 201 Created`

    ``` json
    {
        "domains":  [{
                "id":             4,
                "domain":         "allowed2.com",
                "type":           "allow/exact",
                "comment":        null,
                "groups":         [0],
                "enabled":        true,
                "date_added":     1611239095,
                "date_modified":  1611239095
        }]
    }
    ```

    **Fields**

    See description of the `GET` request above.

??? failure "Error response"

    Response code: `HTTP/1.1 400 - Bad Request`

    ``` json
    {
        "error": {
            "key": "database_error",
            "message": "Could not add domain to gravity database",
            "data": {
                "argument": "allowed2.com",
                "enabled": true,
                "comment": "Some text",
                "sql_msg": "UNIQUE constraint failed: domainlist.domain, domainlist.type"
            }
        }
    }
    ```

    !!! hint "Hint: Use `PUT` instead of `POST`"
        When using `PUT` instead of `POST`, duplicate domains are silently replaced without issuing an error.
<!-- markdownlint-enable code-block-style -->

## Update domain/regex

**Create new or update existing entry (no error on existing record)**

- `PUT /api/domains/allow/exact/<domain or regex>`
- `PUT /api/domains/allow/regex/<domain or regex>`
- `PUT /api/domains/allow/exact/<domain or regex>`
- `PUT /api/domains/allow/regex/<domain or regex>`

<!-- markdownlint-disable code-block-style -->
???+ example "🔒 Request"

    === "cURL"

        ``` bash
        domain="allowed2.com"
        curl -X PUT http://pi.hole/api/domains/allow/regex/${domain} \
             -d sid=$sid \
             -H "Content-Type: application/json" \
             -d '{"oldtype": "allow/exact", "enabled": true, "comment": "Some text"}'
        ```

    === "Python 3"

        ``` python
        import requests

        domain = "allowed2.com"
        url = 'http://pi.hole:8080/api/domains/allow/regex/' + domain
        sid = '<valid session id>'
        data = {
            "oldtype": "allow/exact",
            "enabled": True,
            "comment": "Some text",
            "sid": sid
        }

        response = requests.put(url, json=data)

        print(response.json())
        ```

    **Required parameters**

    ??? info "Previous type of domain/regex (`"oldtype": string`)"
        Type this domain/regex had before. If not identical to the target, e.g., `oldtype=allow/exact` and `url=http://pi.hole/api/domains/allow/regex/`, the domain/regex will be changed in type.

    **Optional parameters**

    ??? info "Enabled (`"enabled": boolean`)"
        Whether this item should enabled or not.

    ??? info "Comment (`"comment": string`)"
        User-provided free-text comment for this item.

??? success "Success response"

    Response code: `HTTP/1.1 201 Created`

    ``` json
    {
        "domains":  [{
                "id":             4,
                "domain":         "allowed2.com",
                "type":           "allow/regex",
                "comment":        null,
                "groups":         [0],
                "enabled":        true,
                "date_added":     1611239095,
                "date_modified":  1611241276
        }]
    }
    ```

    Note that the regex moved from `allow/exact` to `allow/regex`.

    **Fields**

    See description of the `GET` request above.

## Delete domain/regex

- `DELETE /api/domains/allow/exact/<domain or regex>`
- `DELETE /api/domains/allow/regex/<domain or regex>`
- `DELETE /api/domains/allow/exact/<domain or regex>`
- `DELETE /api/domains/allow/regex/<domain or regex>`

<!-- markdownlint-disable code-block-style -->
???+ example "🔒 Request"

    === "cURL"

        **Domain**

        ``` bash
        domain="allowed2.com"
        curl -X DELETE http://pi.hole/api/domains/allow/exact/${domain} \
             -d sid=$sid
        ```

        **Regular expression need to be encoded**

        ``` bash
        regex="$(echo -n "(^|\\.)facebook.com$" | jq -sRr '@uri')"
        curl -X DELETE http://pi.hole/api/domains/allow/exact/${regex} \
             -d sid=$sid
        ```

    === "Python"

        **Domain**

        ``` python
        import requests

        domain = 'allowed2.com'
        url = 'http://pi.hole:8080/api/domains/allow/exact/' + domain
        sid = '<valid session id>'
        data = {"sid": sid}

        response = requests.delete(url, json=data)

        print(response.json())
        ```

        **Regular expression**

        ``` python
        import requests
        import urllib

        regex = urllib.parse.quote("(^|\\.)facebook.com$")
        url = 'http://pi.hole:8080/api/domains/allow/exact/' + regex
        sid = '<valid session id>'
        data = {"sid": sid}

        response = requests.delete(url, json=data)

        print(response.json())
        ```

    **Parameters**

    None.

??? success "Success response"

    Response code: `HTTP/1.1 204 No Content`

??? failure "Error response"

    Response code: `HTTP/1.1 400 - Bad Request`

    ```json
    {
        "error": {
            "key": "database_error",
            "message": "attempt to write a readonly databas",
            "data": {
                "argument": "allowed2.com",
                "sql_msg": "Database not available"
            }
        }
    }
    ```
<!-- markdownlint-enable code-block-style -->

{!abbreviations.md!}
