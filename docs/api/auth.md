Authentication is required for most API endpoints. The Pi-hole API uses a session-based authentication system. This means that you will not be able to use a static token to authenticate your requests. Instead, you will be given a session ID (SID) that you will have to use. If you didn't set a password for your Pi-hole, you don't have to authenticate your requests.

To get a session ID, you will have to send a `POST` request to the `/api/auth` endpoint with a payload containing your password. Note that it is also possible to use an application password instead of your regular password, e.g., if you don't want to put your password in your scripts or if you have 2FA enabled for your regular password. One application password can be generated in the web interface on the settings page.

<!-- markdownlint-disable code-block-style -->
???+ example "Authentication with password"

    === "bash / cURL"

        ```bash
        curl -k -X POST "https://pi.hole/api/auth" --data '{"password":"your-password"}'
        ```

    === "Python 3"

        ```python
        import requests

        url = "https://pi.hole/api/auth"
        payload = {"password": "your-password"}

        response = requests.request("POST", url, json=payload, verify=False)

        print(response.text)
        ```

    === "JavaScript (plain)"

        ```javascript
        var data = JSON.stringify({"password":"your-password"});
        var xhr = new XMLHttpRequest();

        xhr.addEventListener("readystatechange", function () {
          if (this.readyState === this.DONE) {
            console.log(JSON.parse(this.responseText));
          }
        });

        xhr.open("POST", "https://pi.hole/api/auth");
        xhr.send(data);
        ```

    === "JavaScript (jQuery)"

        ```javascript
        $.ajax({
          url: "https://pi.hole/api/auth",
          type: "POST",
          data: JSON.stringify({"password":"your-password"}),
          dataType: "json",
          contentType: "application/json"
        }).done(function(data) {
          console.log(data);
        }).fail(function(xhr, status, error) {
          console.log(error);
        });
        ```

    === "C"

        ```c
        #include <stdio.h>
        #include <stdlib.h>
        #include <curl/curl.h>

        int main(void)
        {
          CURL *curl;
          CURLcode res;

          curl_global_init(CURL_GLOBAL_ALL);

          curl = curl_easy_init();
          if(curl) {
            curl_easy_setopt(curl, CURLOPT_URL, "https://pi.hole/api/auth");
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, "{\"password\":\"your-password\"}");
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
            curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");

            struct curl_slist *headers = NULL;
            headers = curl_slist_append(headers, "Content-Type: application/json");
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

            res = curl_easy_perform(curl);

            curl_easy_cleanup(curl);
          }

          curl_global_cleanup();

          return 0;
        }
        ```

    **Parameters**

    Specify either your password or an application password as `password` in the payload.

???+ success "Success response"

    Response code: `HTTP/1.1 200 OK`

    ```json
    {
      "session": {
        "valid": true,
        "totp": false,
        "sid": "vFA+EP4MQ5JJvJg+3Q2Jnw=",
        "csrf": "Ux87YTIiMOf/GKCefVIOMw=",
        "validity": 300
      },
      "took": 0.0002
    }
    ```

???+ failure "Error response"

    Response code: `HTTP/1.1 401 - Unauthorized`

    ```json
    {
      "error": {
        "key": "unauthorized",
        "message": "Unauthorized",
        "hint": null
      },
      "took": 0.003
    }
    ```

On success, this will return a JSON object containing the session ID (SID) and the time until your session expires (validity in seconds).
You can use this SID from this point to authenticate your requests to the API.

## Use the SID to access API endpoints

Once you have a valid SID, you can use it to authenticate your requests. You can do this in four different ways:

1. In the request URI: `http://pi.hole/api/info/version?sid=9N80JpYyHRBX4c5RW95%2Fyg%3D` (your SID needs to be URL-encoded)
2. In the payload of your request: `{"sid":"vFA+EP4MQ5JJvJg+3Q2Jnw="}`
3. In the `X-FTL-SID` header: `X-FTL-SID: vFA+EP4MQ5JJvJg+3Q2Jnw=`
4. In the `sid` cookie: `Cookie: sid=vFA+EP4MQ5JJvJg+3Q2Jnw=`

> Note that when using cookie-based authentication, you will also need to send a `X-CSRF-TOKEN` header with the CSRF token that was returned when you authenticated. This is to prevent a certain kind of identity theft attack the Pi-hole API is immune against. Also note that the API checks for a session ID in the cookie header before checking the request URI. Setting the session ID in the request URI is meaningless in cases where the browser automatically sets the session ID in the cookie header.

???+ example "Authentication with SID"

    === "bash / cURL"

        ```bash
        # Example: Authentication with SID in the request URI
        curl -k -X GET "https://pi.hole/api/dns/blocking?sid=vFA+EP4MQ5JJvJg+3Q2Jnw="
        ```

    === "Python 3"

        ```python
        # Example: Authentication with SID in the request header
        import requests

        url = "https://pi.hole/api/dns/blocking"
        payload = {}
        headers = {
          "X-FTL-SID": "vFA+EP4MQ5JJvJg+3Q2Jnw=",
        }

        response = requests.request("GET", url, headers=headers, data=payload, verify=False)

        print(response.text)
        ```

    === "JavaScript (plain)"

        ```javascript
        var data = null;
        var xhr = new XMLHttpRequest();

        xhr.addEventListener("readystatechange", function () {
          if (this.readyState === this.DONE) {
            console.log(JSON.parse(this.responseText));
          }
        });

        // The browser sets the "Cookie: sid=vFA+EP4MQ5JJvJg+3Q2Jnw=" header automatically
        xhr.open("GET", "https://pi.hole/api/dns/blocking");
        xhr.setRequestHeader("X-CSRF-TOKEN", "Ux87YTIiMOf/GKCefVIOMw=");
        xhr.send(data);
        ```

    === "JavaScript (jQuery)"

        ```javascript
        $.ajax({
          url: "https://pi.hole/api/dns/blocking",
          type: "GET",
          data: null,
          dataType: "json",
          contentType: "application/json",
          headers: {
            "X-FTL-SID": "vFA+EP4MQ5JJvJg+3Q2Jnw=",
          }
        }).done(function(data) {
          console.log(data);
        }).fail(function(xhr, status, error) {
          console.log(error);
        });
        ```

    **Parameters**

    Specify the SID in one of the four ways described above.

    **Headers**

    If you use cookie-based authentication, you will also need to send a `X-CSRF-TOKEN` header with the CSRF token that was returned when you authenticated.

## Authentication with 2FA

If you have 2FA enabled for your Pi-hole, you will need to provide a TOTP token in addition to your password. You can generate this token using any TOTP app, e.g., [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2) or [Authy](https://authy.com/download/). The Pi-hole API will return a `totp` flag in the response to indicate whether 2FA is enabled on your Pi-hole.

???+ example "Authentication with 2FA"

    === "bash / cURL"

        ```bash
        curl -k -X POST "https://pi.hole/api/auth" --data '{"password":"your-password", "totp":123456}'
        ```

    === "Python 3"

        ```python
        import requests

        url = "https://pi.hole/api/auth"
        payload = {
          "password": "your-password",
          "totp": 123456
        }

        response = requests.request("POST", url, json=payload, verify=False)

        print(response.text)
        ```

    === "JavaScript (plain)"

        ```javascript
        var data = JSON.stringify({"password":"your-password", "totp":123456});
        var xhr = new XMLHttpRequest();

        xhr.addEventListener("readystatechange", function () {
          if (this.readyState === this.DONE) {
            console.log(JSON.parse(this.responseText));
          }
        });

        xhr.open("POST", "https://pi.hole/api/auth");
        xhr.send(data);
        ```

    === "JavaScript (jQuery)"

        ```javascript
        $.ajax({
          url: "https://pi.hole/api/auth",
          type: "POST",
          data: JSON.stringify({"password":"your-password", "totp":123456}),
          dataType: "json",
          contentType: "application/json"
        }).done(function(data) {
          console.log(data);
        }).fail(function(xhr, status, error) {
          console.log(error);
        });
        ```

    **Parameters**

    Specify your password as `password` and the TOTP token you got from your TOTP app as `totp` in the payload.

## Handling Authentication Errors

When authenticating, it's possible to encounter errors. These can occur due to various reasons such as incorrect password, server issues, or network problems. Here's how you can handle these errors:

When you send a `POST` request to the `/api/auth` endpoint, the server will respond with a status code. If the authentication is successful, you will receive a `200 OK` status code. If there's an error, you will receive a different status code. Here are some common ones:

- `400 Bad Request`: This usually means that the JSON data in the request is not formatted correctly or the required fields are missing.
- `401 Unauthorized`: This means that the password provided is incorrect.
- `500 Internal Server Error`: This indicates that something went wrong on the server side (e.g., a system running out of memory).

In addition to the status code, the server will also return a JSON object with more information about the error, e.g.,

???+ failure "Error response"

    Response code: `HTTP/1.1 400 - Bad Request`

    ```json
    {
      "error": {
        "key": "bad_request",
        "message": "No password found in JSON payload",
        "hint": null
      },
      "took": 0.0001
    }
    ```

    or

    ```json
    {
      "error": {
        "key": "bad_request",
        "message": "Field password has to be of type 'string'",
        "hint": null
      },
      "took": 0.0003
    }
    ```

## Session Expiration

The session ID (SID) has a limited lifespan. Each successful request to the API will extend the lifespan of the SID. However, if there is a prolonged period of inactivity, the SID will expire and you will need to re-authenticate to obtain a new one. The timeout until the SID expires is configurable via a config setting.

## Logging Out

To end your session before the SID expires, you can send a `DELETE` request to the `/api/auth` endpoint. This will invalidate your current SID, requiring you to login again for further requests.

???+ example "Logout"

    === "bash / cURL"

        ```bash
        # Example: Logout with SID in the request URI
        curl -k -X DELETE "https://pi.hole/api/auth?sid=vFA+EP4MQ5JJvJg+3Q2Jnw="
        ```

    === "Python 3"

        ```python
        # Example: Logout with SID in the request header
        import requests

        url = "https://pi.hole/api/auth"
        payload = {}
        headers = {
          "X-FTL-SID": "vFA+EP4MQ5JJvJg+3Q2Jnw="
        }

        response = requests.request("DELETE", url, headers=headers, data=payload, verify=False)

        print(response.text)
        ```

    === "JavaScript (plain)"

        ```javascript
        var data = null;
        var xhr = new XMLHttpRequest();

        xhr.addEventListener("readystatechange", function () {
          if (this.readyState === this.DONE) {
            console.log(JSON.parse(this.responseText));
          }
        });

        // The browser sets the "Cookie: sid=vFA+EP4MQ5JJvJg+3Q2Jnw=" header automatically
        xhr.open("DELETE", "https://pi.hole/api/auth");
        xhr.setRequestHeader("X-CSRF-TOKEN", "Ux87YTIiMOf/GKCefVIOMw=");
        xhr.send(data);
        ```

    === "JavaScript (jQuery)"

        ```javascript
        $.ajax({
          url: "https://pi.hole/api/auth",
          type: "DELETE",
          data: null,
          dataType: "json",
          contentType: "application/json",
          headers: {
            "X-FTL-SID": "vFA+EP4MQ5JJvJg+3Q2Jnw="
          }
        }).done(function(data) {
          console.log(data);
        }).fail(function(xhr, status, error) {
          console.log(error);
        });
        ```

    **Parameters**

    Specify the SID in one of the four ways described above.

???+ success "Success response"

    Response code: `HTTP/1.1 410 - Gone`

    No content

Remember, it's important to manage your sessions properly to maintain the security of your Pi-hole API.

## Rate Limiting

The Pi-hole API implements a rate-limiting mechanism to prevent abuse. This means that you can try a certain number of login attempts per second. If you exceed this limit, you will receive a `429 Too Many Requests` response.

## Limited number of concurrent sessions

The Pi-hole API only allows a limited number of concurrent sessions. This means that if you try to login with a new session while the maximum number of sessions is already active, you may be denied access. This is to prevent abuse and resource exhaustion. In case you hit this limit, please make sure to logout from your sessions when you don't need them anymore as this will free up API slots for future requests. Unused sessions will be automatically terminated after a certain amount of time.

## Security Implications of Session-Based Authentication

Session-based authentication, while convenient and widely used, does have several security implications that Pi-hole addresses in the following ways:

1. **Session Hijacking**: If an attacker manages to steal a user's session ID, they can impersonate that user for the duration of the session. This is mitigated indirectly by the methods #2-#4 below and also by binding sessions to the client's IP address. Be aware that this may cause issues if your IP address changes during the session's lifetime (e.g., a device reconnecting to a different WiFi network).

2. **Cross-Site Scripting (`XSS`)**: XSS attacks can be used to steal session IDs if they are stored in JavaScript-accessible cookies. Pi-hole's session cookie is not accessible to JavaScript (`HttpOnly`), so this is not a concern.

3. **Cross-Site Request Forgery (`CSRF`)**: In a CSRF attack, an attacker tricks a victim into performing actions on their behalf. This is mitigated by using CSRF tokens or implementing the `SameSite` attribute for the session cookie.

4. **Session Fixation**: In this attack, an attacker provides a victim with a session ID, and if the victim authenticates with that session ID, the attacker can use it to impersonate the victim. This is mitigated by ever reusing session IDs but always regenerating them for each new session. Pi-hole sources the session ID from a cryptographically secure random number generator to ensure that it is unique, unpredictable, and safe.

5. **Idle Sessions**: If a session remains open for a long time without activity, it can be hijacked by an attacker. This is mitigated by both the high security of the generated SIDs, making them basically non-bruteforceable, and by the fact that the session ID is bound to the client's IP address. This means that an attacker would not only have to be on the same network as the victim but even be on the same machine to hijack their session. This is furthermore mitigated by implementing session timeouts.

Remember, no security measure is foolproof, but by understanding the potential risks and the multiple layers of defense your Pi-hole implemented against these risks, you can make an informed decision about how to use the Pi-hole API securely in the context of your own scripts. Always use the secure transmission method (HTTPS) offered by your Pi-hole to access the API. The strong encryption will prevent attackers from eavesdropping on your requests and makes stealing your session ID basically impossible.

{!abbreviations.md!}
