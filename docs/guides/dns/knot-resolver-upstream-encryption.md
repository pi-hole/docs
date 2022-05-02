## Knot-resolver forward queries with DNS over TLS easy way

This guide is based on the from the official `knot-resolver` documentation and setup is on Debian.

This guide is to setup the `knot-resolver` as a DNS forwarder and send queries to upstream DNS server only.


### Installation

```bash
wget https://secure.nic.cz/files/knot-resolver/knot-resolver-release.deb
$ sudo dpkg -i knot-resolver-release.deb
$ sudo apt update
$ sudo apt install -y knot-resolver
```

## edit configuration file

- Set `knot-resolver` to listen for incoming queries from localhost only and on a different port.
- Uncomment to disable IPv6 queries only if no ipv6 connectivity.
- Cache size for small networks do need to be change.
- Change the IP and hostname to your desire DNS server oc choice, check the upstream DNS providers in the guides. `knot-resolver` automatically use the system's certificates.
- for more advance configuration and information check the check `knot-resolver` documentation.

`/etc/knot-resolver/kresd.conf`:

```bash
-- SPDX-License-Identifier: CC0-1.0
-- vim:syntax=lua:set ts=4 sw=4:
-- Refer to manual: https://knot-resolver.readthedocs.org/en/stable/

-- Network interface configuration
net.listen('127.0.0.1', 5335, { kind = 'dns' })
--net.listen('127.0.0.1', 853, { kind = 'tls' })
--net.listen('127.0.0.1', 443, { kind = 'doh2' })
net.listen('::1', 5335, { kind = 'dns', freebind = true })
--net.listen('::1', 853, { kind = 'tls', freebind = true })
--net.listen('::1', 443, { kind = 'doh2' })

-- Disable IPv6
--net.ipv6 = false

-- Cache size
cache.size = 100 * MB

-- Forwarding over TLS protocol (DNS-over-TLS) with no fallback.
policy.add(policy.all(policy.TLS_FORWARD({
        {'185.228.168.9', hostname='security-filter-dns.cleanbrowsing.org'},
        {'185.228.169.9', hostname='security-filter-dns.cleanbrowsing.org'}
})))
```

### Startup the systemd service

knot-resolver service won't run on and enabled on reboot by default.  
Run the service:

```bash
sudo systemctl start kresd@1.service
```

enable the service to startup on boot

```bash
sudo systemctl enable kresd@1.service
```

### Install `kdig` and check for dns qureies

```bash
sudo apt install knot-dnsutils
```

```bash
kdig google.com @127.0.0.1 -p 5335 cat.com
;; ->>HEADER<<- opcode: QUERY; status: NOERROR; id: 13471
;; Flags: qr rd ra; QUERY: 1; ANSWER: 2; AUTHORITY: 0; ADDITIONAL: 0

;; QUESTION SECTION:
;; cat.com.                     IN      A

;; ANSWER SECTION:
cat.com.                90      IN      A       3.140.91.82
cat.com.                90      IN      A       18.118.230.25

;; Received 57 B
;; Time 2022-05-02 14:10:03 AEST
;; From 127.0.0.1@5348(UDP) in 1360.5 ms
```

### setup Pi-hole to use `knot-resolver`

Select settings menu sidebar, select DNS tab, enter `127.0.0.1#5335` into Upstream DNS Server, check the box and click on save.

![Upstream DNS Servers Configuration](/images/RecursiveResolver.png)

### Uninstallation of knot-resolver

```bash
sudo systemctl stop kresd@1.service
sudo systemctl disable kresd@1.service
sudo apt remove knot-resolver
```

### Check the official knot-resolver documentation

[knot-resolver.readthedocs.io](https://knot-resolver.readthedocs.org/en/stable/)
