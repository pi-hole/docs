**This is an unsupported configuration created by the community**

To enhance your privacy you might want to route all or part of your Browser Traffic over Tor.

### Tor Browser

The easiest and most reliable solution would be to use the [Tor Browser](https://www.torproject.org/download/). Though that won't use your Pi-hole DNS Server out of the box. You can, however, disable `Proxy DNS when using SOCKS v5` in Tor Browsers Preferences -> Advanced -> Network -> Settings and make sure to point your system to use Pi-hole with DNS over Tor activated.

### Your Browser

Edit `/etc/tor/torrc` on your Pi-hole as root, include the following line at the end and save the changes

```
SocksPort 0.0.0.0:9050
```

!!! note
    You should make sure that only your LAN devices are able to access your Pi-hole on port 9050.

Restart Tor

```bash
sudo service tor restart
```

Point your browser to use your Pi-hole IP or Hostname (e.g. `pi.hole`) and `Port 9050` as Socks5 Proxy. Do not enable `Proxy DNS when using SOCKS v5` and make sure to point your system to use Pi-hole with DNS over Tor activated.

* For Chrome you can either use e.g. the [Proxy SwitchyOmega Extension](https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif) or start Chrome with [command-line parameters](https://www.chromium.org/developers/design-documents/network-stack/socks-proxy).

* For Firefox you can either use e.g. the [FoxyProxy Add-on](https://addons.mozilla.org/en-US/firefox/addon/foxyproxy-standard/) or configure the Socks5 Proxy directly in the Firefox Preferences.
 If you use a Proxy Add-on/Extension you can also e.g. route everything per default over Tor and only whitelist some sites that you need to perform really good.

#### Accessing .onion addresses

If you want to access .onion addresses with this kind of setup you have to activate [Transparent Access to Tor Hidden Services](https://www.grepular.com/Transparent_Access_to_Tor_Hidden_Services) on the Pi-hole host.

---

#### Notes

* Don't define other regular Upstream DNS Servers than the Tor one if you want to avoid that your Pi-hole makes plaintext DNS requests.
* From the [Tor Manual](https://www.torproject.org/docs/tor-manual.html.en) regarding `DNSPort`:

    > This port only handles A, AAAA, and PTR requests
