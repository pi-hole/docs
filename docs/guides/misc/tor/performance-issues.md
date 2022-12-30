**This is an unsupported configuration created by the community**

You're constantly using new DNS Servers that are located all over the world, so it might happen that sometimes hostname resolving is slow or might not work at all for certain domains. In this case, you have to wait a few minutes until you switch to another Tor circuit or configure Tor to accept control connections and send a command that tells Tor to [switch circuits immediately](https://superuser.com/a/139018).

You could set `ExitNodes` in your torrc to a specific set of Exit nodes that are reliable for you or use only Exit nodes in a [specific country](https://b3rn3d.herokuapp.com/blog/2014/03/05/tor-country-codes/) (on Debian derivatives you need to have the `tor-geoipdb` package installed for that to work) and thus avoid problems with DNS lookups to some extent.

Keep in mind that this approach increases the correlation attack vulnerability if you only have a small amount of `ExitNodes` set or your selected country/s has/have few Exit nodes. If your goal is only to slightly increase security and maintain performance and reliability, this approach might be for you. It is not recommended.

**Ok, but please just tell me how to avoid timeouts**

So you've read about Performance, Reliability and Timeouts and just want a quick solution.

This is not recommended, but here are some things you can do:

##### Solution 1 - Only use Exit Nodes from specific countries

* Install the necessary geoip db for Tor to use, on Debian derivatives (Raspbian, Ubuntu) that means

    ```bash
    sudo apt install tor-geoipdb
    ```

* Pick the Country Codes you want to use as ExitNodes from the "List of country codes for Tor" list on [this page](https://b3rn3d.herokuapp.com/blog/2014/03/05/tor-country-codes).

    Edit `/etc/tor/torrc` as root and, add the following lines to the end and replace `CountryCodeN` (keep the `{` and `}`) with the country code you've chosen (you can also use only one country code; in this case, it would be just `{CountryCode1}` without a comma).

    ```
    ExitNodes {CountryCode1},{CountryCode2},{CountryCode3}
    StrictNodes 1
    ```

* Save the changes, restart Tor

    ```bash
    sudo service tor restart
    ```

!!! note
    Using this approach you put a strain on Tor Relays in the selected countries only and increase your security vulnerability. It's not nice and not recommended. Also, be aware that this change also affects which Exit Nodes are used if you route your browser traffic over the Pi-hole host Tor SocksPort.

##### Solution 2 - Only use specific Exit Nodes

1. Navigate to [metrics.torproject.org Top Relays](https://metrics.torproject.org/rs.html#toprelays).
2. Click on two Relays out of the list.
3. Make sure the relay allows Port `53` in his `IPv4 Exit Policy Summary` (and/or `IPv6 Exit Policy Summary` if you want to resolve IPv6 AAAA queries).
4. As root copy the `Fingerprint` (Top Right under Relay Details) of those two Relays to the end of your `/etc/tor/torrc` file on the Pi-hole host in the following format:

    ```
    ExitNodes Fingerprint1,Fingerprint2
    StrictNodes 1
    ```

5. Save the changes, restart Tor

    ```bash
    sudo service tor restart
    ```

6. If DNS requests stop resolving at all, you might need to repeat this procedure because the Relays you chose might've gone down.

!!! note
    Using this approach you put a strain on single Tor Relays and increase your security vulnerability. It's not nice and not recommended. Also, be aware that this change also affects which Exit Nodes are used if you route your browser traffic over the Pi-hole host Tor SocksPort.

!!! info
    You can combine both Solutions and have country codes and fingerprints as `ExitNodes`.

#### IPv6

DNS over Tor only partially supports IPv6 as of now. This is only a problem if your Router or your ISP don't support IPv4 or you want only IPv6 traffic for another reason - if you have both IPv4 and IPv6 available and you don't plan to visit an IPv6 only service, this is no problem at all.

In general, [if you made sure that you configured your Pi-hole to support IPv6](https://www.reddit.com/r/pihole/comments/7e0jg9/dns_over_tor/dq4wbry/), resolving IPv6 addresses will sometimes work and sometimes not. The reason for this is that Tor Exit nodes only resolve IPv6 queries if they have `IPv6Exit 1` set in their configuration. Tor is [working on a fix](https://trac.torproject.org/projects/tor/ticket/21311) for that - but until that is done and the Tor exit nodes switched to the fixed version, you will run into situations where IPv6 addresses aren't resolvable despite being available in the responsible nameserver. To check whether your current Exit node resolves IPv6 correctly you can run `dig example.com aaaa` (Linux) or `nslookup -q=aaaa example.com` (Windows) on your client.

If you're dependent on IPv6 and can't use IPv4 at all, your only chance is to configure `ExitNodes` in your torrc to only point to Exit nodes that resolve IPv6 correctly. But keep in mind that this approach increases the correlation attack vulnerability if you only have a small amount of `ExitNodes` set.

Also, you can't (AFAIK) change the internal IPv4 Tor DNS address on the Pi-hole host to an IPv6 one since `DNSPort` doesn't support that - so you need at least internal IPv4 on your Pi-hole host, which is the default on most host systems.

#### Exit node fingerprints

To get the fingerprint of your current Exit node, you can configure `SocksPort 0.0.0.0:9050` in your torrc, restart tor, point your browser to use your Pi-hole's IP and port 9050 as Socks5 proxy, visit e.g. [check.torproject.org](https://check.torproject.org/) to get your Exit Node IP, search for that IP on [atlas.torproject.org](https://atlas.torproject.org), click on one of the results and it will show the Fingerprint top right under details.

These fingerprints can be set as a comma-separated value for `ExitNodes`. Don't forget to remove the `SocksPort` option and restart tor if you don't need it anymore. Also, it should be noted that the Exit node you get over `SocksPort` is not necessarily the same as the one you get when issuing DNS requests over the `DNSPort` since Tor internally keeps multiple circuits open. Again, setting `ExitNodes` manually is not recommended.
