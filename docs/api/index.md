# API Reference

The Pi-hole API is organized around [REST](http://en.wikipedia.org/wiki/Representational_State_Transfer). Our API has predictable resource-oriented URLs, accepts and returns reliable UTF-8 [JSON-encoded](http://www.json.org/) data for all API responses, and uses standard HTTP response codes and verbs.

Most (but not all) endpoints require authentication. API endpoints requiring authentication will fail with code `401 Unauthorized` if no key is supplied.

## JSON response

The form of replies to successful requests strongly depends on the selected endpoint, e.g.,

<!-- markdownlint-disable code-block-style -->
???+ success "Example reply: Success"

    Ressource: `GET /api/dns/blocking`

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
      "blocking": true
    }
    ```

    **Reply type**

    Object or Array

    **Fields**

    Depending on the particular endpoint

In contrast, errors have a uniform style to ease their programatic treatment:

???+ failure "Example reply: Error (unauthorized access)"

    Ressource: `GET /api/domains`

    Response code: `HTTP/1.1 401 Unauthorized`

    ``` json
    {
        "error": {
            "key": "unauthorized",
            "message": "Unauthorized",
            "data": null
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

    ??? info "Additional data (`"data": [object|null]`)"

        The field `data` may contain a JSON object. Its content depends on the error itself and may contain further details such as the interpreted user data. If no additional data is available for this endpoint, `null` is returned instead of an object.

        Examples for a failed request with `data` being set is (domain is already on this list):

        ``` json
        {
            "error":  {
                "key":  "database_error",
                "message":  "Could not add to gravity database",
                "data": {
                    "argument": "abc.com",
                    "enabled":  true,
                    "sql_msg":  "UNIQUE constraint failed: domainlist.domain, domainlist.type"
                }
            }
        }
        ```
<!-- markdownlint-enable code-block-style -->

## HTTP methods used by this API

Each HTTP request consists of a method that indicates the action to be performed on the identified resource. The relevant standards are [RFC 2616, Scn. 9](https://tools.ietf.org/html/rfc2616#section-9) (`GET/POST/PUT/DELETE`).

Pi-hole's API uses the methods like this:

Method   | Description
---------|------------
`GET`    | **Read** from resource. The resource may not exist.
`POST`   | **Create** resources
`PUT`    | **Create or Replace** the resource. This method commonly used to *update* entries.
`DELETE` | **Delete** existing resource

### `GET`

The `GET` method means retrieve whatever information (in the form of an entity) that is identified by the Request-URI.

### `POST`

The `POST` method is used to request that the origin server accept the entity enclosed in the request as a new subordinate of the resource identified by the Request-URI in the Request-Line. `POST` is designed to allow a uniform method to cover the following functions:

- Annotation of existing resources;
- Posting a message to a bulletin board, newsgroup, mailing list, or similar group of articles;
- Providing a block of data, such as the result of submitting a form, to a data-handling process;
- Extending a database through an append operation.

If a resource has been created on the origin server, the response will be `201 (Created)`.

Not all action performed using the `POST` method will result in a resource that can be identified by a URI. In such a case, either `200 (OK)` or `204 (No Content)` is the appropriate response status, depending on whether or not the response includes an entity that describes the result.

### `PUT`

The `PUT` method requests that the enclosed entity be stored under the supplied Request-URI. If the Request-URI refers to an already existing resource, the enclosed entity will be considered as a modified version of the one residing on the origin server. If the Request-URI does not point to an existing resource, and that URI is capable of being defined as a new resource by the requesting user agent, the origin server can create the resource with that URI.

The origin server will inform the user agent via a `200 (OK)` response if processing the entry was successful.

### `DELETE`

The `DELETE` method requests that the origin server delete the resource identified by the Request-URI. The API will not indicate success unless, at the time the response is given, it intends to delete the resource or move it to an inaccessible location.

A successful response will be `200 (OK)` if the response includes an entity describing the status, `202 (Accepted)` if the action has not yet been enacted, or `204 (No Content)` if the action has been enacted but the response does not include an entity.

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
