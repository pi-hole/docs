This guide should work for most recent Debian derivatives (raspbian, Ubuntu). Alternatively you can follow a Tor Installation Guide for your Host System.
```
sudo apt install tor
```

Edit `/etc/tor/torrc` as root, include the following line at the end and save the changes
```
DNSPort 127.0.10.1:53
```

Restart Tor with: `sudo service tor restart`

Change your pihole upstream DNS server to use `127.0.10.1` in the pihole WebGUI (Settings) under "Upstream DNS Servers" and click "Save".

**Note:** It's currently not possible to change the Upstream DNS Server directly in the `/etc/pihole/setupVars.conf` file, the pihole DNS Server won't pick up the change.

If you want a recognizable hostname for the Tor DNS in your pihole GUI statistics, edit `/etc/hosts` as root, include the following line at the end and save the changes
```
127.0.10.1     tor.dns.local
```
 Restart pihole DNS Server for the `/etc/hosts` changes to take effect
```
sudo pihole restartdns
```
## Testing your configuration

 To see which DNS servers you're using, you can use a DNS Server Leak Test. Some of them don't work with DNS over Tor, [this one](https://dns-leak.com/) does work tho. It should show random DNS Servers. Tor rotates the circuit approximately every 10minutes in default configuration, so it might take 10minutes for you to see a new set of random DNS servers in the Leak Test.

 You can also check the "Forward Destinations over Time" Graph (enabled per default) in your pihole WebGUI - the latest Forward Destinations should only include "local" and "tor.dns.local" (if you updated the `/etc/hosts` file).
 
 To absolutely make sure that you always use the pihole as DNS Server and to make sure that it handles IPv4 and/or IPv6 blocking if you configured it to do so, you should check which DNS Servers your client is using: `nmcli device show <interface> | grep .DNS` (Linux) or `ipconfig /all` (Windows, and look for **DNS Servers** on your **LAN Adapter**). You should then issue a IPv4 (A) and/or IPv6 (AAAA) DNS query to every IPv4 and/or IPv6 DNS Server that shows up:

 For Linux:  
 ```dig @<IPv4/6-dns-server-address> api.mixpanel.com <A/AAAA>```

 For Windows:  
```nslookup -server=<IPv4/6-dns-server-address> -q=<A/AAAA> api.mixpanel.com``` 

That should give you the pihole IPv4 and/or IPv6 address as Answer and show up as "Pi-holed" in the WebGUI Query Log (assuming you have the default blocklist, otherwise replace `api.mixpanel.com` with any domain on your blocklist). 

If any of the queries doesn't show up in the Query Log you should make sure to configure your pihole/network setup properly ([this thread might help](https://www.reddit.com/r/pihole/comments/7e0jg9/dns_over_tor/dq4kkvg/)).
 
