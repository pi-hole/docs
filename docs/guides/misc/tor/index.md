**This is an unsupported configuration created by the community**

If you want to protect your - unencrypted by default - DNS requests from easily being collected by your ISP or another Adversary between you and your DNS server, you can easily set up Pi-hole to use [Tor](https://www.torproject.org) for hostname resolving. Using DNS over Tor anonymizes your IP by using [Onion-Routing](https://en.wikipedia.org/wiki/Onion_routing).

#### Contribute to the Tor project

If you got spare resources, consider [running a Tor Relay](https://community.torproject.org/relay/) (or [Exit](https://blog.torproject.org/tips-running-exit-node)) Node to contribute back to the Tor Network. The default installation doesn't do either of these. And/Or consider [donating](https://donate.torproject.org).

---

### ⚠️ Warnings & Considerations

#### Tracking

Please be aware that **your ISP or an Adversary still can collect what Websites you visit by capturing HTTP (plaintext) or HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)) packets or by trying to [reverse lookup](https://en.wikipedia.org/wiki/Reverse_DNS_lookup) or [whois](https://en.wikipedia.org/wiki/WHOIS) the IPs you're connecting to**. To avoid that you might want to consider to additionally route your browser traffic over Tor.

Also keep in mind that even Tor can't provide 100% anonymity, for example [correlation](https://www.extremetech.com/extreme/211169-mit-researchers-figure-out-how-to-break-tor-anonymity-without-cracking-encryption) [attacks](https://nakedsecurity.sophos.com/2016/10/05/unmasking-tor-users-with-dns/) are possible. Although it's almost impossible to execute such an attack for e.g. your ISP or a random service on the internet - you might need to change some of your habits to get the most out of Tor.

#### Bad Relays, Phishing, Scam

Tor has the concept of [Bad Relays](https://trac.torproject.org/projects/tor/wiki/doc/ReportingBadRelays) and tries to avoid that Tor Relays become Bad Exit Nodes (which are a form of Relay) by monitoring their behavior before declaring them as Exit Node. But it still can happen and since anyone can run a Tor Relay as Exit Node on the Tor Network, this means that an Exit Node owner could fake the answer to a DNS request and redirect you to a malicious website/IP.

If you're in a recent Browser and only visit encrypted (HTTPS) sites, that isn't too bad, since the Browser would warn you with an invalid certificate warning (unless someone would hack a [Certificate authority](https://en.wikipedia.org/wiki/Certificate_authority) or get a CA to issue a certificate without validation - which is both [highly unlikely](https://www.reddit.com/r/TOR/comments/5b416x/malicious_tor_exit_node_can_provide_fakephishing/d9lskni/)). But other apps on your network that resolve DNS queries via DNS over Tor might either communicate unencrypted or don't validate certificates properly.

Such apps could get malicious data injected and/or phish your data without your knowledge.

**So, ideally, only use DNS over Tor if you know for a fact that the apps in your network communicate over a secure connection and properly validate certificates.**

That being said, if you use DNS over Tor in the default configuration (meaning no custom `ExitNodes` in the torrc), this kind of attack requires a big portion of luck for the attacker (owner of a Bad Exit Node), because you would have to get a circuit routing over the Bad Exit Node in the same moment when using an insecure app (Tor switches the circuit at least every 10minutes in the default configuration). On top of that, an attacker must first find an app that has this kind of vulnerability and has valuable data or attack vectors. This is unlikely since most apps out there that handle sensitive data at least communicate over encrypted connections that validate certificates based on system or manual root certs.

To lower the chances of Bad Exit Nodes you could restrict `ExitNodes` to trusted ones (country and/or specific). Choosing specific Exit Nodes would basically be the same as e.g. trusting specific DNSCrypt resolvers or [alternative DNS servers](https://wikileaks.org/wiki/Alternative_DNS/). They might be good, they might be bad, you can't know for sure (unless the DNS answers are [DNSSEC](https://docs.pi-hole.net/guides/misc/tor/dnssec/) signed - but that's most likely not the case for the kinds of app that might get affected by this).

So, in the end, it boils down to one of the following use cases.

- Encrypt your DNS traffic using Tor so your ISP can't collect it (but still is able to [collect what Websites/IPs you visit](#tracking) unless you route that traffic also over Tor) and the DNS Server won't see your real IP for the price of maybe getting a Bad Exit Node that fakes answers to DNS queries.

- Use DNSCrypt so your ISP can't collect DNS traffic (but still can collect the websites/IPs you visit unless you route that traffic over Tor), but you have to accept that the DNSCrypt resolver you've chosen might store your DNS queries together with your IP (unless you [modify DNSCrypt to route over Tor](https://github.com/DNSCrypt/dnscrypt-proxy/blob/7b7107902bd7eb2298ff66d8690ab4b0b96595c8/dnscrypt-proxy/example-dnscrypt-proxy.toml#L95)) and could also turn out to send faked answers to DNS queries. I guess you would call that a Bad DNSCrypt resolver then.

- Use an unencrypted alternative DNS server (there are a lot of lists out there). In this case, your ISP easily can record your DNS traffic *and* the alternative DNS server can store your DNS queries together with your IP. On top of that, your ISP or the alternative DNS could also fake the answer to the DNS queries. That would be a Bad Alternative DNS Server then.

- Use your ISP DNS server. In this case, your ISP gets your DNS traffic for free. On top of that, the ISP could also fake answers to DNS queries. Bad ISP DNS Server. The bottom line is that you have to weigh up who you trust the most and which risks you are willing to take.
