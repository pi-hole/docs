# API Reference

The Pi-hole API is organized around [REST](http://en.wikipedia.org/wiki/Representational_State_Transfer). Our API has predictable resource-oriented URLs, accepts [form-encoded](https://en.wikipedia.org/wiki/POST_(HTTP)#Use_for_submitting_web_forms) request bodies, returns reliable UTF-8 [JSON-encoded](http://www.json.org/) data for all API responses, and uses standard HTTP response codes, authentication, and verbs.

## Authentication

The Pi-hole API uses API keys to authenticate requests. You can view your API key in the Pi-hole Dashboard (**TODO: Link**).

!!! warning
    Your API key carries many privileges, so be sure to keep it secure!
    Do not share your secret API keys in publicly accessible areas such as GitHub, client-side code, and so forth if your Pi-hole is reachable from the outside.

The Authorization HTTP header can be specified with `Token <your-access-token>` to authenticate as a user and have the same permissions that the user itself.

<!-- markdownlint-disable code-block-style -->
???+ example active "Example request"

    === "cURL"

        ``` bash
        curl -X GET http://pi.hole/api/dns/status \
             -H "Authorization: Token <your-access-token>"
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole/api/dns/status'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}

        response = requests.get(URL, headers=HEADERS)

        print(response.json())
        ```

??? success "Example reply: Success"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
      "blocking": true
    }
    ```

??? failure "Example reply: Error (unauthorized access)"

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
<!-- markdownlint-enable code-block-style -->

Most but not all endpoints require authentication. API endpoints requiring authentication will fail with code `401 Unauthorized` if no key is supplied.

## Errors

Pi-hole uses conventional HTTP response codes to indicate the success or failure of an API request. In general: Codes in the `2xx` range indicate success. Codes in the `4xx` range indicate an error that failed given the information provided (e.g., a required parameter was omitted, missing authentication, etc.). Codes in the `5xx` range indicate an error with Pi-hole's API (these are rare).

Some `4xx` errors that could be handled programmatically include an error code that briefly explains the error reported.

## HTTP code summary

Code | Description | Interpretation
---- | ----------- | --------------
`200` | `OK` | Everything worked as expected
`201` | `Content Created` | Added a new item
`204` | `No Content` | Removed an item
`400` | `Bad Request` | The request was unacceptable, often due to a missing required parameter
`401` | `Unauthorized` | No valid API key provided for endpoint requiring authorization
`402` | `Request Failed` | The parameters were valid but the request failed
`403` | `Forbidden` | The API key doesn't have permissions to perform the request
`404` | `Not Found` | The requested resource doesn't exist
`429` | `Too Many Requests` | Too many requests hit the API too quickly
`500`, `502`, `503`, `504` | `Server Errors` | Something went wrong on Pi-hole's end (These are rare)

## JSON response

The form of replies to successful requests strongly depends on the selected endpoint, e.g.,

<!-- markdownlint-disable code-block-style -->
???+ success "Example reply: Success"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
      "blocking": true
    }
    ```

    **Reply type**

    Object or Array

In contrast, errors have a uniform style to ease their programatic treatment:

???+ failure "Example reply: Error (unauthorized access)"

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
<!-- markdownlint-enable code-block-style -->

We recommend writing code that gracefully handles all possible API exceptions. The Pi-hole API is designed to support this by standardized error messages and human-readable hints for errors.

{!abbreviations.md!}
