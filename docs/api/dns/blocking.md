# DNS - Status

## Obtain current blocking status

- `GET /api/dns/blocking`

<!-- markdownlint-disable code-block-style -->
???+ example "Request"

    === "cURL"

        ``` bash
        curl -X GET http://pi.hole:8080/api/dns/blocking
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/api/dns/blocking'

        response = requests.get(URL)

        print(response.json())
        ```

    **Parameters**

    None

??? success "Response"

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

    **Fields**

    ??? info "Status (`"blocking": boolean`)"
        Current blocking status.

    ??? info "Timer details (`"timer": [object|null]`)"
        Additional information about a possibly temporary blocking mode. If no timer is running (the current blocking mode is permanent), `null` is returned instead of an object.

        ??? info "Remaining time (`"delay": number`)"
            Seconds until the blocking status indicated by `"blocking_target"` is applied.

        ??? info "Remaining time (`"blocking_target": boolean`)"
            Status applied after the timer elapsed.

<!-- markdownlint-enable code-block-style -->

## Change blocking status

- `POST /api/dns/blocking`

<!-- markdownlint-disable code-block-style -->
???+ example "Request (required authorization)"

    === "cURL"

        ``` bash
        curl -X POST http://pi.hole:8080/api/dns/blocking \
             -H "Authorization: Token <your-access-token>" \
             -H "Content-Type: application/json" \
             -d '{"blocking": false, "delay": 30}'
        ```

    === "Python 3"

        ``` python
        import requests

        URL = 'http://pi.hole:8080/api/dns/blocking'
        TOKEN = '<your-access-token>'
        HEADERS = {'Authorization': f'Token {TOKEN}'}
        data = {"blocking": False, "delay": 30}

        response = requests.post(URL, json=data, headers=HEADERS)

        print(response.json())
        ```

    **Required parameters**

    ??? info "Status (`"blocking": boolean`)"
        Blocking status to be applied. When requesting the same status as is already set, a possibly running timer is disabled.

    **Optional parameters**

    ??? info "Timer delay (`"delay": number`)"
        Delay until the previous blocking status is re-applied. This can be used to disable Pi-hole's blocking temporarily. Subsequent requests overwrite previous timers. When omitting this value, a possibly running timer is disabled.

        This setting has no effect when requesting the same blocking state that is already active.

??? success "Response"

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

    **Fields**

    See description of the `GET` request above. Remember that `timer` may be `null` if there is no active timer.
<!-- markdownlint-enable code-block-style -->

{!abbreviations.md!}
