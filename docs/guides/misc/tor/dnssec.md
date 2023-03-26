**This is an unsupported configuration created by the community**

A lot of the Exit Nodes configure their DNS Server to support DNSSEC. You can [test here](https://wander.science/projects/dns/dnssec-resolver-test/) whether DNSSEC is enabled for your current DNS Servers.
If you want to test again by refreshing the site, please be aware of the notes on the site:

To re-run the above test, you also need to:

1. Wait for 60s or flush the DNS cache of your OS manually (Windows: `ipconfig /flushdns`)
2. Restart browser or clear browser cache

    !!! note
        Flushing Browser/DNS Cache here means restarting Pi-hole (DNS Server), restarting the browser and ideally opening the site in private/incognito mode.

#### Alternatives

* An alternative would be using [DNSCrypt](https://github.com/pi-hole/pi-hole/wiki/DNSCrypt), but this leaves you in a position where you have to trust the [DNSCrypt resolver](https://www.dnscrypt.org/dnscrypt-resolvers.html) since your IP is not anonymized - [unless you configure DNSCrypt to route over Tor](https://github.com/DNSCrypt/dnscrypt-proxy/issues/399#issuecomment-214329222).
