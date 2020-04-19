The Pi-hole setup offers 8 options for an upstream DNS provider during the initial setup.

```text
Google
OpenDNS
Level3
Comodo
DNS.WATCH
Quad9
CloudFlare DNS
Custom
```

During the pi-hole installation, you select 1 of the 7 preset providers or enter one of your own. Below you can find more information on each of the DNS providers, along with some additional providers which have different kinds of extra filtering options (spam, phishing, adult content, etc).

### Google

Default upstream DNS provider on the Pi-hole.

- 8.8.8.8
- 8.8.4.4

[More information on Google Public DNS](https://developers.google.com/speed/public-dns/)

### OpenDNS Home (owned by Cisco)

Built-in features include a phishing filter, this is the OpenDNS version the Pi-hole would use if you select it during setup.

- 208.67.222.222
- 208.67.220.220
- 208.67.222.220
- 208.67.220.222
- 2620:119:35::35 (IPv6)
- 2620:119:53::53 (IPv6)

[More information on OpenDNS Home](https://use.opendns.com/) + [OpenDNS Wikipedia Page](https://en.wikipedia.org/wiki/OpenDNS)

OpenDNS also provides the OpenDNS FamilyShield (free)- option. The service blocks pornographic content, including our “Pornography,” “Tasteless,” and “Sexuality” categories, in addition to proxies and anonymizers (which can render filtering useless). It also blocks phishing and some malware.

- 208.67.222.123
- 208.67.220.123

[More information on OpenDNS FamilyShield](https://www.opendns.com/setupguide/#familyshield) + [OpenDNS FamilyShield introduction Blog](https://umbrella.cisco.com/blog/2010/06/23/introducing-familyshield-parental-controls/)

### Level3 DNS

This DNS service does no filtering of itself, but redirects mistyped URL to Level 3 Web Search.

- 4.2.2.1
- 4.2.2.2

### Comodo Secure DNS

SecureDNS references a real-time block list (RBL) of harmful websites (i.e. phishing sites, malware sites, spyware sites, and parked domains that may contain excessive advertising including pop-up and/or pop-under advertisements, etc.) and will warn you whenever you attempt to access a site containing potentially threatening content.

- 8.26.56.26
- 8.20.247.20

[More information on Comodo Secure DNS](https://www.comodo.com/secure-dns/)

### DNS.WATCH

DNS.WATCH offers Fast, free and uncensored DNS resolution.

- 84.200.69.80
- 84.200.70.40
- 2001:1608:10:25::1c04:b12f (IPv6)
- 2001:1608:10:25::9249:d69b (IPv6)

[More information on DNS.WATCH](https://dns.watch/)

### Quad9

Quad9 is a free, recursive, anycast DNS platform that provides end users robust security protections, high-performance, and privacy.

- 9.9.9.9
- 149.112.112.112
- 2620:fe::fe (IPv6)
- 2620:fe::9 (IPv6)

[More information on Quad9](https://www.quad9.net/about/)

### CloudFlare DNS

CloudFlare will never log your IP address (the way other companies identify you). The independent DNS monitor [DNSPerf](https://www.dnsperf.com/) ranks Cloudflare's DNS the fastest DNS service in the world.

- 1.1.1.1
- 1.0.0.1
- 2606:4700:4700::1111 (IPv6)
- 2606:4700:4700::1001 (IPv6)

[More information on Cloudflare DNS](https://cloudflare-dns.com/dns/#explanation)

Cloudflare also provides 1.1.1.1 for Families, a set of resolvers that can block malware only, or malware and adult content.

Malware Blocking Only

- 1.1.1.2
- 1.0.0.2
- 2606:4700:4700::1112 (IPv6)
- 2606:4700:4700::1002 (IPv6)

Malware and Adult Content

- 1.1.1.3
- 1.0.0.3
- 2606:4700:4700::1113 (IPv6)
- 2606:4700:4700::1003 (IPv6)

[More info on 1.1.1.1 for Families](https://blog.cloudflare.com/introducing-1-1-1-1-for-families/)

### Custom

With custom, you'll choose your favorite DNS provider. If you care about Internet independence and privacy, we suggest having a look at the [OpenNIC DNS Project](https://servers.opennic.org/).

### More information

There are even more public DNS server, you can find many (with some extra information) on [this](https://www.lifewire.com/free-and-public-dns-servers-2626062) Lifewire page. A benchmark of these DNS servers (by Gibson Research Center) is available [here](https://www.grc.com/dns/Benchmark.htm).
