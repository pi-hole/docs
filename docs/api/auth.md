## Overview

The Pi-hole API uses **digest-access challenge-response authentication**. This method is one of the agreed-upon methods a web server can use to negotiate credentials with a client. Challenge-response authentication uses a cryptographic protocol that allows proving that the user knows the password *without revealing the password itself at any point in the process*.

## How it works

This method works as follows: The application first obtains a random challenge from the server. It then computes the response applying a cryptographic hash function to the server challenge combined with the user's password.
Upon receiving the response, the server applies the same hash function to the challenge combined with its own copy of the user's password. If the resulting value matches the response sent by the application, this indicates that the user has submitted the correct password.

Assume the following:

1. Bob is controlling access to the API.
2. Alice comes along seeking entry.
3. Bob issues a challenge, perhaps `52w72y`.
4. Alice must respond with *the one string* of characters which "fits" the challenge Bob issued. The "fit" is determined by a cryptographically secure algorithm "known" to Bob and Alice.
5. Only if this response is correct, Alice is granted access.

As a result, the password itself is never transmitted plain-text. Eavesdropping on the communication is of no use to an attacker:

1. The use of a hash function does not allow the access data (the password) to be reconstructed, and
2. Furthermore, as Bob issues a different challenge each time, a previous correct response cannot be reused.
    Hence, replay attacks are prevented.

<!-- markdownlint-disable code-block-style -->
!!! info "A note about security"

    By modern cryptography standards this authentication method may be considered relatively weak. However, for our purpose - protecting your password against evesdropping on an otherwise unprotected channel, is yet far superior to other plain methods, such as the still widely used HTTP Basic Authentication.
    Our particular implementation was chosen to mitigate the most important threads, while still being very easy to implement (for third-party apps, etc.):

    - **The plain password is never sent clear to the server, preventing [Phishing](https://en.wikipedia.org/wiki/Phishing).**
    - The unique random nounce together with the self-salted password hashing effectively **prevents chosen-plaintext-attacks** using precomputed rainbow tables.

    ??? info "About the security of the SHA-256 algorithm"
        **It is not feasible to reverse the SHA-256 algorithm using a brute-force attack as this would require a lot more energy than mankind has available for use.**
        
        A good explanation about the Thermodynamic limits applying here is by Bruce Schneier in [`Applied Cryptography`](https://www.schneier.com/blog/archives/2009/09/the_doghouse_cr.html):

        > One of the consequences of the second law of thermodynamics is that a certain amount of energy is necessary to represent information. To record a single bit by changing the state of a system requires an amount of energy no less than $kT$, where $T$ is the absolute temperature of the system and $k$ is the Boltzman constant. (Stick with me; the physics lesson is almost over.)
        >
        > Given that $k=1.38\cdot 10^{-16}$ erg/K, and that the ambient temperature of the universe is $3.2$ K, an ideal computer running at $3.2$ K would consume $4.4\cdot 10^{-16}$ ergs every time it set or cleared a bit. To run a computer any colder than the cosmic background radiation would require extra energy to run a heat pump.
        >
        > Now, the annual energy output of our sun is about $1.21\cdot 10^{41}$ ergs. This is enough to power about $2.7\cdot 10^{56}$ single bit changes on our ideal computer; enough state changes to put a 187-bit counter through all its values. If we built a Dyson sphere around the sun and captured all of its energy for 32 years, without any loss, we could power a computer to count up to $2^{192}$. Of course, it wouldn’t have the energy left over to perform any useful calculations with this counter.
        >
        > But that’s just one star, and a measly one at that. A typical supernova releases something like $10^{51}$ ergs. (About a hundred times as much energy would be released in the form of neutrinos, but let them go for now.) If all of this energy could be channeled into a single orgy of computation, a `219`-bit counter could be cycled through all of its states.
        >
        > These numbers have nothing to do with the technology of the devices; they are the maximums that thermodynamics will allow. And they strongly imply that **brute-force attacks against 256-bit keys will be *infeasible* until computers are built from something other than matter and occupy something other than space**.
<!-- markdownlint-enable code-block-style -->

## Description of the algorithm

The algorithm itself is pretty simple:

1. The client requests a cryptographic nonce as the challenge to ensure that every challenge-response sequence is unique. Each challenge is valid for 8 seconds after its generation. The unique challenge can be requested at `GET /api/auth`

2. The client computes the correct response using the simple two-step algorithm

    $$
    \begin{align}
    \textrm{pwhash} &= \textrm{SHA256}(\textrm{SHA256}(\textrm{password}))\\
    \textrm{response} &= \textrm{SHA256}(\textrm{challenge} + ":" + \textrm{pwhash})
    \end{align}
    $$

    where all intermediate steps are always done with an ASCII (hex) representation of the data.

3. The client sends the computed response back to the server at `POST /api/auth` using the `response` as `POST` parameter.

    The server responds with either HTTP code `200` on success, `400` (bad request) or `401` (unauthorized) on failure, or `500` (on an internal error). If authentication succeeds, the API returns a session cookie as well as a session token. One of them needs to can be included with subsequent requests to the API.

<!-- markdownlint-disable code-block-style -->
??? info "The cryptographic nonce"
    It is impractical to implement a true nonce as Pi-hole is supposed to run on various systems and architectures. Hence, we employ a non-linear additive-feedback pseudo-random number generator and a cryptographically secure hash function to generate challenges that are highly unlikely to occur more than once. The period of the used pseudo-random number generator is very large, approximately $16 \cdot ((2^{31}) - 1) = 34\,359\,738\,352$.

    **When requesting 10 challenges per second, the uniqueness of the generated challenges would still be guaranteed for over 100 years.**

    Random-number generation is a complex topic. *Numerical Recipes in C: The Art of Scientific Computing* (William H. Press, Brian P. Flannery, Saul A. Teukolsky, William T. Vetterling; New York: Cambridge University Press, 2007, 3rd ed.) provides an excellent discussion of practical random-number generation issues in Chapter 7 (Random Numbers).

    For a more theoretical discussion which also covers many practical issues in depth, see Chapter 3 (Random Numbers) in Donald E. Knuth's *The Art of Computer Programming*, volume 2 (Seminumerical Algorithms), 2nd ed.; Reading, Massachusetts: Addison-Wesley Publishing Company, 1981. 
<!-- markdownlint-enable code-block-style -->

Because of the "one-way" properties of the SHA-256 hash function, it is not possible to recover the password from the response sent by the client.

On successful authentication, the server returns both a session cookie (via its response headers) and a session ID (in the payload). Both can be used independently to authenticate. If both are supplied, the session cookie will be preferred by the server.

## Examples

Getting a challenge is simple and straightforward:

``` bash
curl -X GET http://pi.hole/api/auth
```

Result:

``` json
{
    "challenge": "a2926b025bcc8618c632f81cd6cf7c37ee051c08aab74b565fd5126350fcd056",
    "session":
    {
    "valid":    false,
    "sid":      null,
    "validity": null
    }
}
```

Below, we provide concrete examples of how to authenticate with the Pi-hole API. These simplified examples are prrof-of-concept to aid your understanding. They do not deal with possible errors such as a failed connection. They do work both with succeeded and failed login attempts.

!!! info "Security hint"
    You can always store the `pwhash` (the double-hashed password) instead of `password` (the plaintext password) if you are using this in a script.

### Bash

``` bash
computePWhash() {
    local password hash1 hash2
    password="${1}"
    # Compute password hash twice to avoid rainbow table vulnerability
    hash1=$(echo -n "$password" | sha256sum | sed 's/\s.*$//')
    hash2=$(echo -n "$hash1" | sha256sum | sed 's/\s.*$//')
    echo "${hash2}"
}
computeResponse() {
    local pwhash challenge response
    pwhash="${1}"
    challenge="${2}"
    response=$(echo -n "${challenge}:${pwhash}" | sha256sum | sed 's/\s.*$//')
    echo "${response}"
}
```

``` bash
password="ABC"
pwhash="$(computePWhash "$password")"

challenge="$(curl -s -X GET http://pi.hole/api/auth | jq --raw-output .challenge)"
response="$(computeResponse "$pwhash" "$challenge")"
session="$(curl -s -X POST --data response="$response" http://pi.hole/api/auth)"

valid=$(jq .session.valid <<< "${session}")
sid="$(jq --raw-output .session.sid <<< "${session}")"
```

### Javascript

We recommend using [`geraintluff/sha256`](https://github.com/geraintluff/sha256) providing a small (less than 1 KB) SHA-256 implementation.

``` javascript
function getPWhash(password) {
    // Compute password hash twice to mitigate rainbow
    // table vulnerability
    return sha256(sha256(password));
}

function sendResponse(pwhash, challenge) {
    var response = sha256(challenge + ":" + pwhash);
    $.ajax({
        url: "http://pi.hole/api/auth",
        method: "POST",
        data: { response: response }
    })
        .done(function (data) {
            console.log("Login successful");
            session = data.session;
            console.log(session);
        })
        .fail(function (data) {
            console.log("Login failed");
        });
}

function doLogin(pwhash) {
    $.ajax({
        url: "http://pi.hole/api/auth",
        method: "GET"
    }).done(function (data) {
        if ("challenge" in data) {
            console.log("Challenge received");
            sendResponse(pwhash, data.challenge);
        }
    });
}

var password = "ABC";
var pwhash = getPWhash("ABC");
doLogin(pwhash);
```

### Python 3

``` python
import requests
from hashlib import sha256

url = "http://pi.hole/api/auth"

password = b"ABC"
pwhash = sha256(sha256(password).hexdigest().encode("ascii")).hexdigest().encode("ascii")

challenge = requests.get(url).json()["challenge"].encode('ascii')
response = sha256(challenge + b":" + pwhash).hexdigest().encode("ascii")
session = requests.post(url, data = {"response": response}).json()

valid = session["session"]["valid"] # True / False
sid = session["session"]["sid"] # SID string if succesful, null otherwise
```

### Result of the authentication

The result of a successful authentication is

``` json
{
    "session":
    {
    "valid":    true,
    "sid":      "XwrWDU7EDg64dX0sxmURDA==",
    "validity": 300
    }
}
```

together with a session cookie
