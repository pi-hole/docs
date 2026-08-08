Pi-hole can act as an encrypted resolver for the clients in your network. FTL answers DNS-over-TLS (DoT), DNS-over-HTTPS (DoH) and DNS-over-QUIC (DoQ) queries itself, so you no longer need a separate proxy in front of Pi-hole to offer encrypted DNS to your phones, laptops and routers.

This page is about the *downstream* side, i.e., the encryption between your clients and your Pi-hole. It is unrelated to how Pi-hole talks to its own upstream servers.

<!-- markdownlint-disable code-block-style -->
!!! info "This is not the same as encrypting your upstream traffic"
    If you want the queries Pi-hole forwards to its upstream resolvers to be encrypted, see the guides for [unbound](../guides/dns/unbound.md), [cloudflared](../guides/dns/cloudflared.md) or [dnscrypt-proxy](../guides/dns/dnscrypt-proxy.md). Both directions can be encrypted independently of each other.
<!-- markdownlint-enable code-block-style -->

## What is served where

Protocol | Standard | Transport      | Default port                     | Config option
---------|----------|----------------|----------------------------------|--------------
DoT      | RFC 7858 | TCP            | `853`                            | `dns.dot`
DoQ      | RFC 9250 | UDP (QUIC)     | `853`                            | `dns.doq`
DoH      | RFC 8484 | TCP/UDP (HTTP) | the HTTPS port of the web server | `dns.doh`

All three are enabled by default and all three use the same TLS certificate as the web interface (`webserver.tls.cert`, see [TLS/SSL](../api/tls.md)).

DoT and DoQ share the port number `853` without colliding, as one uses TCP and the other UDP. Both ports are configurable, but we recommend staying with the defaults: `853` is the port assigned by the respective standard, and it is what clients try first (many of them do not even offer a field for a different port). Setting either option to `0` disables that listener.

DoH has no port of its own. It is served at the path `/dns-query` on the web server's HTTPS port, i.e., the first entry in `webserver.port` carrying the `s` flag, so a Pi-hole reachable at `https://pi.hole/admin` answers DoH at `https://pi.hole/dns-query`. If you change the web server's HTTPS port, the DoH endpoint moves with it.

## Enabling and disabling

```bash
sudo pihole-FTL --config dns.dot 853   # DoT on the standard port (default)
sudo pihole-FTL --config dns.doq 853   # DoQ on the standard port (default)
sudo pihole-FTL --config dns.doh true  # DoH on the HTTPS web server port (default)
```

Set `dns.dot` or `dns.doq` to `0`, or `dns.doh` to `false`, to switch the respective listener off. Changing any of the three makes `pihole-FTL` restart itself so the new setting takes effect, which interrupts DNS resolution for a moment - you do not have to restart it yourself.

Who may query these listeners is governed by [`dns.listeningMode`](configfile.md), but the rule is stricter than the one dnsmasq applies on port 53: unless the mode is `ALL`, the client has to sit on a subnet directly attached to your Pi-hole, where loopback and point-to-point peers such as a VPN count as local, and in `SINGLE` or `BIND` it must be on the subnet of the configured `dns.interface`. Plain DNS is more permissive, as `SINGLE` and `BIND` accept any origin that reaches the configured interface, so a routed client that gets an answer on port 53 can still be turned away here. That is deliberate - encrypted resolvers are often reachable from the Internet by design, and Pi-hole does not open itself up just because you enabled DoT.

<!-- markdownlint-disable code-block-style -->
!!! warning "Do not expose your Pi-hole to the Internet"
    An openly reachable resolver will be found and abused for amplification attacks. If you want to use your Pi-hole while away from home, put it behind a VPN, e.g., [WireGuard](../guides/vpn/wireguard/index.md), instead of forwarding port `853` in your router.
<!-- markdownlint-enable code-block-style -->

## Certificates

All three protocols present the certificate configured in `webserver.tls.cert`. With the self-signed certificate Pi-hole generates for itself, clients will refuse the connection unless they trust Pi-hole's certificate authority - see [adding the CA to your browser or device](../api/tls.md#adding-the-ca-to-your-browser). Some clients are stricter than browsers here and accept a manually installed CA for DoT/DoQ only reluctantly or not at all, so a certificate from a public CA for a domain you own is the more comfortable route if you run into trouble.

The certificate is created by the web server, not by these listeners, and only when `webserver.port` contains a TLS port (`443s` by default). If you serve the web interface over plain HTTP only, no certificate is generated and DoT and DoQ wait for one instead of starting - they log `DoT waiting for the webserver TLS certificate` once and retry until the file appears. Point `webserver.tls.cert` at your own certificate in that case.

The name your clients use must match the certificate. If your certificate was created for `pi.hole` but the client is configured with an IP address, validation fails.

## Using it from a client

<!-- markdownlint-disable code-block-style -->
???+ example "Testing from the command line"

    === "DoT"

        ```bash
        kdig +tls @pi.hole example.com
        ```

    === "DoQ"

        ```bash
        kdig +quic @pi.hole example.com
        ```

    === "DoH"

        ```bash
        curl -H 'accept: application/dns-message' \
             'https://pi.hole/dns-query?dns=AAABAAABAAAAAAAAB2V4YW1wbGUDY29tAAABAAE' \
             --output -
        ```

    `kdig` is part of the `knot-dnsutils` package. Add `+tls-ca=/etc/pihole/tls_ca.crt` (or `curl --cacert ...`) if the client machine does not trust Pi-hole's CA yet.
<!-- markdownlint-enable code-block-style -->

Common places to enter these on real devices:

- **Android** (9 and later): *Settings -> Network & internet -> Private DNS*, which speaks DoT and expects a hostname.
- **iOS/macOS**: through a DNS profile, which can carry either a DoT or a DoH server.
- **Firefox**: *Settings -> Privacy & Security -> DNS over HTTPS*, using `https://pi.hole/dns-query` as a custom provider.
- **Routers**: many recent firmwares (OpenWrt, AVM FRITZ!OS, Unifi) can forward to a DoT server.

Queries arriving this way show up in the query log like any other query, attributed to the client that sent them.

## Requests over plain HTTP

`/dns-query` is only served over HTTPS. A plaintext request is answered with `426 Upgrade Required` rather than being resolved, so a misconfigured client cannot silently fall back to sending your DNS traffic in the clear.
