## Configuring DNS-Over-HTTPS using `dnscrypt-proxy` [^guide]

To utilize DNS-Over-HTTPS (DoH) or other encrypted DNS protocols with Pi-hole, preventing man-in-the-middle attacks between Pi-hole and upstream DNS servers, the following sections explain how to install the flexible and stable [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) tool.

### Installing `dnscrypt-proxy`

Under Debian 13 `Trixie` and Ubuntu 25 `Plucky Puffin` and later, official packages are available and therefore can be installed with the following commands:

```bash
sudo apt update
sudo apt install dnscrypt-proxy
```

However for those using distributions which don't provide an official package, [instructions for installation](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-linux#installation-on-linux-overview) can be found on the official wiki for `dnscrypt-proxy`, which provides agnostic support for installation without using a package manager.

### Configuring `dnscrypt-proxy`

By default, `FTLDNS` listens on the standard DNS port 53.

To avoid conflicts with `FTLDNS`, add a Systemd override file with `sudo systemctl edit dnscrypt-proxy.socket`, ensuring `dnscrypt-proxy` listens on a port that is not in use by other services.

You will be greeted with an empty override file:

```text
### Editing /etc/systemd/system/dnscrypt-proxy.socket.d/override.conf
### Anything between here and the comment below will become the contents of the drop-in file


### Edits below this comment will be discarded
```

In the new Systemd override file, unset the old values first and let `dnscrypt-proxy` listen on localhost on port 5053:

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

Make sure you placed the edits between the second comment line and the third comment line of the Systemd override file.


If you have `cloudflared` installed, you may uninstall it, as `dnscrypt-proxy` will replace it, or choose a unique port for `dnscrypt-proxy`.

Also edit `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`, updating the following settings:

```toml
# Use systemd socket activation:
listen_addresses = []

# Populate `server_names` with desired DoH/DNSCrypt upstream DNS servers listed in https://dnscrypt.info/public-servers/.
# Example for Cloudflare malware-blocking DNS:
server_names = ['cloudflare-security']
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
