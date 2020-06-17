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
        curl -X GET http://pi.hole:8080/admin/api/dns/blocking
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
        "blocking": true,
        "timer": null
    }
    ```

    If there is currently a timer running, the reply will be like

    ``` json
    {
        "blocking": false,
        "timer": {
            "delay": 5,
            "blocking_target": true
        }
    }
    ```
<!-- markdownlint-enable code-block-style -->

## `POST`: Set/change blocking status

Resource: `POST /admin/api/dns/blocking`

Requires authorization: Yes

### Parameters

Name | Required | Type | Description | Example
---- | -------- | ---- | ----------- | -------
`blocking` | Yes | Boolean | Requested status | `true`
`delay` | Optional | Number | Requested delay until opposite status is active, running timer can be disabled by setting delay to `-1` | `100` (seconds)

### Example

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl -X POST http://pi.hole:8080/admin/api/dns/blocking \
             -H "Authorization: Token <your-access-token>" \
             -H "Content-Type: application/json" \
             -d '{"blocking":false, "delay":30}'
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/dns/blocking'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}
        data = {"blocking":False, "delay":30}

        response = requests.post(URL, json=data, headers=HEADERS)

        print(response.json())
        ```

!!! success "Response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "blocking": false,
        "timer": {
            "delay": 30,
            "blocking_target": true
        }
    }
    ```

    Remember that `timer` may be `null` if there is no active timer.
<!-- markdownlint-enable code-block-style -->

{!abbreviations.md!}
