The Pi-hole API is organized around [REST](http://en.wikipedia.org/wiki/Representational_State_Transfer). Our API has predictable resource-oriented URLs, accepts and returns reliable UTF-8 [JavaScript Object Notation (JSON)-encoded](http://www.json.org/) data for all API responses, and uses standard HTTP response codes and verbs.

Most (but not all) endpoints require authentication. API endpoints requiring authentication will fail with code `401 Unauthorized` if no key is supplied. See [API Reference: Authentication](auth.md) for details.

## Accessing the API documentation

The entire API is documented at http://pi.hole/api/docs and self-hosted by your Pi-hole to match 100% the API versions your local Pi-hole has. Using this locally served API documentation is preferred. In case you don't have Pi-hole installed yet, you can also check out the documentation for all branches online, e.g., [Pi-hole API documentation](https://ftl.pi-hole.net/master/docs/) (branch `master`). Similarly, you can check out the documentation for a specific other branches by replacing `master` with the corresponding branch name. <!-- markdownlint-disable-line no-bare-urls -->

## API endpoints

An overview of all available endpoints is available at the API documentation page. The endpoints are grouped by their functionality.

## JSON response

The form of replies to successful requests strongly depends on the selected endpoint, e.g.,

<!-- markdownlint-disable code-block-style -->
???+ success "Example reply: Success"

    Resource: `GET /api/dns/blocking`

    Response code: `HTTP/1.1 200 OK`

    ```json
    {
      "blocking": true
    }
    ```

    **Reply type**

    Object or Array

    **Fields**

    Depending on the particular endpoint
<!-- markdownlint-enable code-block-style -->

In contrast, errors have a uniform, predictable style to ease their programmatic treatment:

<!-- markdownlint-disable code-block-style -->
???+ failure "Example reply: Error (unauthorized access)"

    Resource: `GET /api/domains`

    Response code: `HTTP/1.1 401 Unauthorized`

    ```json
    {
        "error": {
            "key": "unauthorized",
            "message": "Unauthorized",
            "hint": null
        }
    }
    ```

    **Reply type**

    Object

    **Fields**

    ??? info "Key describing the error (`"key": string`)"
        This string may be used for internal categorization of error types

        Examples for `key` are:

        - `bad_request`

            Possible reason: Payload is invalid for this endpoint

        - `database_error`

            Possible reason: Failed to read/write to the database

    ??? info "Human-readable description of the error (`"message": string`)"
        This string may be shown to the user for troubleshooting

        Examples for `messages` are:

        - `Could not read domains from database table`

            Possible reason: Database is not readable

        - `No request body data`

            Possible reason: Payload is empty

        - `Invalid request body data`

            Possible reason: Payload is not valid JSON

        - `No "domain" string in body data`

            Possible reason: The required field `domain` is missing in the payload

    ??? info "Additional data (`"hint": [object|string|null]`)"

        The field `hint` may contain a JSON object or string. Its content depends on the error itself and may contain further details such as the interpreted user data. If no additional hint is available for this endpoint, `null` is returned.

        Examples for a failed request with `hint` being set is (domain is already on this list):

        ```json
        {
            "error":  {
                "key": "database_error",
                "message": "Could not add to gravity database",
                "hint": {
                    "argument": "abc.com",
                    "enabled": true,
                    "sql_msg": "UNIQUE constraint failed: domainlist.domain, domainlist.type"
                }
            }
        }
        ```
<!-- markdownlint-enable code-block-style -->

## HTTP methods used by this API

Each HTTP request consists of a method that indicates the action to be performed on the identified resource. The relevant standards is [RFC 2616](https://tools.ietf.org/html/rfc2616). Though, RFC 2616 has been very clear in differentiating between the methods, complex wordings are a source of confusion for many users.

Pi-hole's API uses the methods like this:

Method   | Description
---------|------------
`GET`    | **Read** from resource
`POST`   | **Create** a resource
`PATCH`  | **Update** existing resource
`PUT`    | **Create or Replace** a resource
`DELETE` | **Delete** existing resource

<!-- markdownlint-disable code-block-style -->
??? info "Summarized details from [RFC 2616, Scn. 9](https://tools.ietf.org/html/rfc2616#section-9) (`GET/POST/PUT/DELETE`) and [RFC 2068, Scn. 19.6.1.1](https://datatracker.ietf.org/doc/html/rfc2068#section-19.6.1.1) (`PATCH`)"
    ### `GET`

    The `GET` method means retrieve whatever information (in the form of an entity) that is identified by the URI.

    As `GET` requests do not change the state of the resource, these are said to be **safe methods**. Additionally, `GET` requests are **idempotent**, which means that making multiple identical requests must produce the same result every time until another method (`POST` or `PUT`) has changed the state of the resource on the server.

    For any given HTTP `GET`, if the resource is found on the server, then the API returns HTTP response code `200 (OK)` – along with the response body.

    In case a resource is NOT found on server, then the API returns HTTP response code `404 (Not found)`. Similarly, if it is determined that `GET` request itself is not correctly formed then API will return HTTP response code `400 (Bad request)`.

    ### `POST`

    Use `POST` APIs to **create new subordinate records**, e.g., a file is subordinate to a directory containing it or a row is subordinate to a database table. W`POST` methods are used to create a new resource into the collection of resources.

    If a resource has been created on the origin server, the response will be `201 (Created)`.
    Not all action performed using the `POST` method will result in a resource that can be identified by a URI. In such a case, either `200 (OK)` or `204 (No Content)` is the appropriate response status, depending on whether or not the response includes an entity that describes the result.

    Note that `POST` is **neither safe nor idempotent**, and invoking two identical `POST` requests typically results in an error.

    ### `PUT`

    Use `PUT` primarily to **update existing records** (if the resource does not exist, the API will typically create a new record for it). If a new record has been added at the given URI, or an existing resource is modified, either the `200 (OK)` or `204 (No Content)` response codes are sent to indicate successful completion of the request.

    ### `PATCH`

    The `PATCH` method is similar to `PUT` except that the entity contains a list of differences between the original version of the resource identified by the Request-URI and the desired content of the resource after the `PATCH`` action has been applied. The list of differences is in a format defined by the media type of the entity (e.g., "application/diff") and MUST include sufficient information to allow the server to recreate the changes necessary to convert the original version of the resource to the desired version.

    ### `DELETE`

    As the name applies, `DELETE` APIs are used to **delete records** (identified by the Request-URI).

    A successful response will be `200 (OK)` if the response includes an entity describing the status, `202 (Accepted)` if the action has not yet been enacted, or `204 (No Content)` if the action has been enacted but the response does not include an entity.

    `DELETE` operations are **idempotent**. If you `DELETE` a resource, it’s removed from the collection of resources. Repeatedly calling `DELETE` on that resource will not change the outcome – however, calling `DELETE` on a resource a second time *may* return a 404 (NOT FOUND) since it was already removed.

???+ info "Example"
    Let’s list down few URIs and their purpose to get better understanding when to use which method:

    Method + URI | Interpretation
    ---------------------|--------------------
    `GET /api/groups` | Get all groups
    `POST /api/groups` | Create a new group
    `GET /api/groups/abc` | Get the group `abc`
    `PUT /api/groups/abc` | Update the group `abc`
    `DELETE /api/groups/abc` | Delete group `abc`
<!-- markdownlint-enable code-block-style -->

## Error handling

Pi-hole uses conventional HTTP response codes to indicate the success or failure of an API request. In general: Codes in the `2xx` range indicate success. Codes in the `4xx` range indicate an error that failed given the information provided (e.g., a required parameter was omitted, missing authentication, etc.). Codes in the `5xx` range indicate an error with Pi-hole's API (these are rare).

Some `4xx` errors that could be handled programmatically include an error code that briefly explains the error reported:

Code | Description | Interpretation
---- | ----------- | --------------
`200` | `OK` | Everything worked as expected
`201` | `Content Created` | Added a new item
`204` | `No Content` | Removed an item
`400` | `Bad Request` | The request was unacceptable, often due to a missing required parameter
`401` | `Unauthorized` | No session identity provided for endpoint requiring authorization
`402` | `Request Failed` | The parameters were valid but the request failed
`403` | `Forbidden` | The API key doesn't have permissions to perform the request
`404` | `Not Found` | The requested resource doesn't exist
`429` | `Too Many Requests` | Too many requests hit the API too quickly
`500`, `502`, `503`, `504` | `Server Errors` | Something went wrong on Pi-hole's end (These are rare)

We recommend writing code that gracefully handles all possible API exceptions. The Pi-hole API is designed to support this by standardized error messages and human-readable hints for errors.

{!abbreviations.md!}
