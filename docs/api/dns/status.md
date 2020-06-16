# DNS - Status

## GET: Obtain current blocking status

Resource: `GET /admin/api/dns/status`

Requires authorization: No

### Parameters

None

### Examples

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl http://pi.hole:8080/admin/api/dns/status
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/dns/status'

        response = requests.get(URL)

        print(response.json())
        ```

!!! success "Response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "status": "enabled"
    }
    ```
<!-- markdownlint-enable code-block-style -->

## `POST`: Set/change blocking status

Resource: `POST /admin/api/dns/status`

Requires authorization: Yes

### Parameters

Name | Required | Type | Description | Default | Example
---- | -------- | ---- | ----------- | ------- | -------
`action` | Yes | String | Requested status | | `enable` or `disable`
`time` | Optional | Number | Requested delay until opposite status is enabled | `0` | `100` (seconds)

### Example

<!-- markdownlint-disable code-block-style -->
!!! example "Request"

    === "cURL"

        ``` bash
        curl -X POST \
                -H "Authorization: Token <your-access-token>" \
                http://pi.hole:8080/admin/api/dns/status \
                -H "Content-Type: application/json" \
                -d @body.json
        ```

        The content of `body.json` is like,

        ``` json
        {
            "action": "enable",
            "time": 30
        }
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/admin/api/dns/status'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}
        data = json.load(open('body.json', 'rb'))

        response = requests.post(
            URL,
            json=data,
            headers=HEADERS,
        )

        print(response.json())
        ```

        The content of `body.json` is like,

        ``` json
        {
            "action": "enable",
            "time": 30
        }
        ```

!!! success "Response"

    Response code: `HTTP/1.1 200 OK`

    ``` json
    {
        "key": "enabled"
    }
    ```
<!-- markdownlint-enable code-block-style -->

{!abbreviations.md!}
