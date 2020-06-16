# DNS - Status

## GET: Obtain current blocking status

Resource: `GET /admin/api/dns/blocking`

Requires authorization: No

### Parameters

None

### Examples

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl http://pi.hole:8080/admin/api/dns/blocking
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/dns/blocking'

        response = requests.get(URL)

        print(response.json())
        ```

!!! success "Response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "status": "active"
    }
    ```
<!-- markdownlint-enable code-block-style -->

## `POST`: Set/change blocking status

Resource: `POST /admin/api/dns/blocking`

Requires authorization: Yes

### Parameters

Name | Required | Type | Description | Default | Example
---- | -------- | ---- | ----------- | ------- | -------
`status` | Yes | String | Requested status | | `active` or `inactive`
`delay` | Optional | Number | Requested delay until opposite status is active | `0` | `100` (seconds)

### Example

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl http://pi.hole:8080/admin/api/dns/blocking \
             -X POST \
             -H "Authorization: Token <your-access-token>" \
             -H "Content-Type: application/json" \
             -d '{"status":"active", "delay":30}'
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/dns/blocking'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}
        data = {"status":"active", "delay":30}

        response = requests.post(URL, json=data, headers=HEADERS)

        print(response.json())
        ```

!!! success "Response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "status": "active"
    }
    ```
<!-- markdownlint-enable code-block-style -->

{!abbreviations.md!}
