## Configuring DNS-Over-HTTPS using `dnscrypt-proxy` [^guide]

To utilize DNS-Over-HTTPS (DoH) or other encrypted DNS protocols with Pi-hole, preventing man-in-the-middle attacks between Pi-hole and upstream DNS servers, the following sections explain how to install the flexible and stable [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) tool.

### Installing `dnscrypt-proxy`

If you have `cloudflared` installed, you may uninstall it, as `dnscrypt-proxy` will replace it, or choose a unique port for `dnscrypt-proxy`.

Under Debian 13 `Trixie` and Ubuntu 25 `Plucky Puffin` and later, official packages are available and therefore can be installed with the following commands:

```bash
sudo apt update
sudo apt install dnscrypt-proxy
```

However for those using distributions which don't provide an official package, [instructions for installation](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-linux#installation-on-linux-overview) can be found on the official wiki for `dnscrypt-proxy`, which provides agnostic support for installation without using a package manager.

### Configuring `dnscrypt-proxy`

By default, `FTLDNS` listens on the standard DNS port 53.

To avoid conflicts with `FTLDNS`, edit `dnscrypt-proxy.socket` ensuring dnscrypt-proxy listens on a port that is not in use by other services.

```bash
sudo systemctl edit dnscrypt-proxy.socket
```
Add the following between the two commented sections:

```text
### Editing /etc/systemd/system/dnscrypt-proxy.socket.d/override.conf
### Anything between here and the comment below will become the contents of the drop-in file

[Socket]
ListenStream=
ListenDatagram=
ListenStream=127.0.0.1:5053
ListenDatagram=127.0.0.1:5053

### Edits below this comment will be discarded
```

Update `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` and choose a pre-configured server to connect to:

```toml
# Populate `server_names` with desired DoH/DNSCrypt upstream DNS servers listed in https://dnscrypt.info/public-servers/.
# Example for Cloudflare malware-blocking DNS:
server_names = ['cloudflare-security']
```

or create a new host, using a `DNS Stamp Calculator` to generate your own static entry, which is required to use services such as Cloudflare Gateway.

```toml
server_names = ['myhost-custom']
[static]
  [static.'myhost-custom']
  stamp='sdns://AgAAAAAAAAAAAAAaaHR0cHM6Ly90aGlzLmlzLmFuLmV4YW1wbGUKL2Rucy1xdWVyeQ'
```

### Configuring Pi-hole Upstream DNS Servers

Run the following command to set the upstream DNS server of Pi-hole to your local `dnscrypt-proxy` instance:

```bash
sudo pihole-FTL --config dns.upstreams '["127.0.0.1#5053"]'
```

### Restarting Services

Run the following commands to restart `dnscrypt-proxy` and `FTLDNS`:

```bash
sudo systemctl restart dnscrypt-proxy.socket
sudo systemctl restart dnscrypt-proxy.service
sudo systemctl restart pihole-FTL.service
```

### Reviewing Service Status

Run the following commands to review the status of each restarted service:

```bash
sudo systemctl status dnscrypt-proxy.socket
sudo systemctl status dnscrypt-proxy.service
sudo systemctl status pihole-FTL.service
```

Each service is expected to be in active (running) state.
Review the log files shown if a service didn't restart successfully.

### Configuring Pi-hole

Optionally, confirm in the Pi-hole admin web interface that upstream DNS servers are configured correctly:

* Log into the Pi-hole admin web interface.
* Navigate to "Settings" and from there to "DNS".
* Under "Upstream DNS Servers", uncheck all boxes for public DNS servers.
* Under "Upstream DNS Servers", ensure the box is filled with the IP address and port combination `dnscrypt-proxy` listens on, such as `127.0.0.1#5053`.
* Click on `Save` at the bottom.

### (Optional) Configuring Pihole to use itself for system DNS, and integrating it into `systemd-resolved`

Pihole and systemd-resolved can function together in order to provide the system with a way to log its own queries and have failover if a pihole update should not succeed.  You *must* have a properly configured firewall, or risk your pihole responding to external requests.  Systemd-resolved usage is required due to the three nameserver limit in `/etc/resolve.conf`, and resolve.conf only using the default port.

#### Pihole bind restrictions

Pihole must not bind to `0.0.0.0:53` so that `dnscrypt-proxy.socket` may also bind on port 53, as systemd-resolved is unable to use DNS servers with non-standard ports and `/etc/resolv.conf` has this restriction as well.  Configure `pihole-FTL` to bind to a specific interface.  The interface is the identifier given by the network manager.  For netplan, you may use `sudo netplan status` to view all the connections and the names. 

```bash
sudo pihole-FTL --config dns.interface 'enp0s31f6'
sudo pihole-FTL --config dns.listeningMode 'BIND'
```

Restart pihole-FTL for changes to take effect, and validate it is not binding to 0.0.0.0:53 but specific and correct interface ip addresses.

```bash
sudo systemctl restart pihole-FTL.service
sudo netstat -lvnp | grep pihole-FTL | grep :53
```

### Further modify `dnscrypt-proxy.socket`
`dnscrypt-proxy.socket` must be used to bind to a *well known* or *privileged port*, and we will be binding `127.0.2.1:53` explitly so that a dnscrypt-proxy update will not impact the configuration.  Any additonal interfaces that bind to non-standard ports may be set in `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`.

```bash
sudo systemctl edit dnscrypt-proxy.socket
```

Re-configure the default `127.0.2.1:53` configuration explicitly in the systemctl override:

```text
### Editing /etc/systemd/system/dnscrypt-proxy.socket.d/override.conf
### Anything between here and the comment below will become the contents of the drop-in file

[Socket]
ListenStream=
ListenDatagram=
ListenStream=127.0.0.1:5053
ListenDatagram=127.0.0.1:5053
ListenStream=127.0.2.1:53
ListenDatagram=127.0.2.1:53
```

Restart dnscrypt-proxy for changes to take effect.

```bash
sudo systemctl restart dnscrypt-proxy.socket
sudo systemctl restart dnscrypt-proxy.service
```

#### `systemd-resolved` configuration
Create a new systemd-resolved configuration file in `/etc/systemd/resolved.conf.d/`, and configure the DNS servers to fit your needs. Note, this is used by the local pihole and only used if `FTLDNS` is not serving.  FallbackDNS in this context is only used when nothing else is configured, and is *not* a fallback if all other DNS entries fail.

```bash
sudo cat <<EOF > /etc/systemd/resolved.conf.d/1-pihole-dns-failover.conf
[Resolve]
# Some examples of DNS servers which may be used for DNS= and FallbackDNS=:
# Cloudflare: 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
# Google:     8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
# Quad9:      9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net
DNS=127.0.0.1 127.0.2.1 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
FallbackDNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
# Configure the systemd-resolved DNS Stub Listener to bind to 127.0.0.2
DNSStubListenerExtra=127.0.0.2
EOF
sudo chmod 644 /etc/systemd/resolved.conf.d/1-pihole-dns-failover.conf
```

Restart systemd-resolved for changes to take effect.

```bash
systemctl restart systemd-resolved.service
```

Verify the configuration with the following command.  Note that your DHCP/static DNS settings for each interface may be used before our configurations so set DHCP to be the pihole or explicitly configure the pihole without nameservers in the network configuration.  Verify the DNS servers, Fallback DNS Servers, and the DNS Servers listed under each Link are as configured as expected above.

```bash
sudo resolvectl status
```

#### Configure the system DNS via `resolv.conf`

`/etc/resolv.conf` is being automatically generated by systemd or by netplan, depending on your configuration.  Being that this is a DNS server, we need tighter control over the configuration and systemd-resolved will follow the DNS servers set by netplan or network manager and choose the 'right one' anyway.  By default, `resolv.conf` will always process in-order so we will not have to worry about bleeding DNS queries out unless the service is down/unresponsive, which systemd-resolved will decide which the best server is and may not process them in-order.

Remove the /etc/resolv.conf symlink and replace it with a file, stopping the updates.  Changes are immediate.

```bash
sudo unlink /etc/resolv.conf
sudo cat <<EOF > /etc/resolv.conf
# Use local pihole
nameserver 127.0.0.1
# If using IPv6, configure with your Static Local Address and uncomment
#nameserver fc00::2
# Use systemd-resolved
nameserver 127.0.0.2
# First two are local services, we can fail them fast and only need to attempt once, reducing the impact of down services. Increase the timeout or omit these lines if your internet service is not reliable or higher latency.
options timeout:1
options attempts:1
EOF
sudo chmod 644 /etc/resolv.conf
```

Note: If using selinux, you must repair the security contexts of /etc/resolv.conf after creating a new one.

```bash
restorecon -v /etc/resolv.conf
```

### Testing the configuratoin

Stop each service in turn and verify `/etc/resolv.conf` is followed.  Once systemd-resolved is called, you cannot control the order or which DNS server it decides to use, but the system is not in a deadlock state.

```bash
sudo systemctl stop pihole-FTL.service
nslookup google.com
## Should receive a connection refused on 127.0.0.1 and a return on 127.0.0.2
sudo resolvectl status
## `Current DNS Server:` should show which server systemd-resolved decided to use
sudo systemctl start pihole-FTL.service
```

```bash
sudo systemctl stop dnscrypt-proxy.socket
sudo systemctl stop dnscrypt-proxy.service
nslookup bing.com
## Should receive a connection timed out on 127.0.0.1 and a return from server 127.0.0.2
sudo systemctl start dnscrypt-proxy.service
```


## Maintenance


### Updating `dnscrypt-proxy`

Since you installed `dnscrypt-proxy` via APT, updating `dnscrypt-proxy` is a matter of running the following commands:

```bash
sudo apt update
sudo apt upgrade
```

### Uninstalling `dnscrypt-proxy`

To uninstall `dnscrypt-proxy`, run the command `sudo apt remove dnscrypt-proxy`.
Update the Pi-hole DNS settings to use another upstream DNS server.

[^guide]: Guide based on [this guide by Fabian Foerg | ffoerg.de](https://ffoerg.de/posts/2024-01-28.shtml)
