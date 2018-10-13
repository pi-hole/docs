A lot of the Exit Nodes configure their DNS Server to support DNSSEC. You can [test here](https://dnssec.vs.uni-due.de/) whether DNSSEC is enabled for your current DNS Servers.
   If you want to test again by refreshing the site, please be aware of the notes on the site:
  
  To re-run the above test, you also need to:

1.	Flush the DNS cache of your OS (Windows: ipconfig /flushdns)
2.   Restart browser or clear browser cache

	Note: Flushing Browser/DNS Cache here means restarting pihole (DNS Server), restarting the browser and ideally opening the site in private/incognito mode.

#### Alternatives
 * An alternative would be using [DNSCrypt](https://github.com/pi-hole/pi-hole/wiki/DNSCrypt), but this leaves you in a position where you have to trust the [DNSCrypt resolver](https://dnscrypt.org/dnscrypt-resolvers.html) since your IP is not anonymized - [unless you configure DNSCrypt to route over Tor](https://github.com/jedisct1/dnscrypt-proxy/issues/399#issuecomment-214329222).

