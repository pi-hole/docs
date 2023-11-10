## Frequently Asked Questions

This is a collection of questions that were asked repeatedly on discourse or github.

### Odd random character queries in Pi-hole's query logs

You see three queries containing only random strings, sometimes with the local domain suffix, like

```bash
yfjmdpisrvyrnq
attxnwheeeuiad
nskywzjbpj
```

**Solution:**

This happens when using Chrome-based browsers. Chrome tries to find out if someone is messing up with the DNS (i.e. wildcard DNS servers to catch all domains). Chrome does this by issuing DNS requests to randomly generated domain names with between 7 and 15 characters

In a normal setup this results in a “No such name” response from your DNS server. If the DNS server you use has a wildcard setup, each of these requests will result in a response (which is normally even the same) so Chrome knows that there is someone messing around with DNS responses.

Link to [Chromium's source code](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/chrome/browser/intranet_redirect_detector.cc#132) explaining the function.

### Pi-hole update fails due to repository changed it's 'Suite' value

This happens after a manual OS upgrade to the next major version on deb based systems. A typical message is

```bash
Repository 'http://archive.raspberrypi.org/debian buster InRelease' changed its 'Suite' value from 'stable' to 'oldstable'
```

**Solution:**

```bash
sudo apt-get update --allow-releaseinfo-change
```

### Pi-hole's gravity complains about invalid IDN domains

During a gravity update, Pi-hole complains about some invalid Internationalized Domain Names (IDN) domains

```bash
Sample of invalid domains:
- test.中国
- test.рф
- test.भारत
- e-geräteundhaus.com
- rëddït.com
```

**Solution:**

Ask the list maintainer to convert the IDNs to their punycode representation.

Internationalizing Domain Names in Applications (IDNA) was conceived to allow client-side use of language-specific characters in domain names without requiring any existing infrastructure (DNS servers, mall servers, etc., including associated protocols) to change. Accordingly, the corresponding original [RFC 3490](https://tools.ietf.org/html/rfc3490) clearly states that IDNA is employed at application level, not on the server side.
Hence, DNS servers never see any IDN domain name, which means DNS records do not store IDN domain names at all, only their [Punycode](https://en.wikipedia.org/wiki/Punycode)  representations.

### Error while loading data from the long-term database

If requesting a lot of data from the long-term database you get this error

```code
An unknown error occurred while loading the data.

Check the server's log files (/var/log/lighttpd/error-pihole.log) for details.

You may need to increase PHP memory limit.

You can find more info in pi-hole's FAQ:
https://docs.pi-hole.net/main/faq/#error-while-loading-data-from-the-long-term-database
```

**Solution:**

You need to increase PHP's memory and restart the server.

The amount of memory needed depends on many factors:

- available system RAM,
- other processes running on your device,
- the amount of data you want to process.

One approach would be to increase the limit by 128M and check if it was enough to retrieve the data.
If not, add another 128M, check again. If not, add another 128M, check again, until you find the best value.

_Note:_
Do not assign all available memory as this can freeze your system.
Please consider the possibility that your system does not have enough memory at all to load all the needed data.

_Steps to increase `memory_limit`:_

Open or create `.user.ini` file:

```bash
sudo nano /var/www/html/.user.ini
```

Add (or change) the memory limit (common abbreviation M=megabyte, G=gigabyte):

```ini
memory_limit = 256M
```

Restart the web server:

```bash
sudo service lighttpd restart
```

### In which order are locally defined DNS records used?

**Answer:**

The order of locally defined DNS records is:

1. The device's host name and `pi.hole`
2. Configured in a config file in `/etc/dnsmasq.d/`
3. Read from `/etc/hosts`
4. Read from the "Local (custom) DNS" list (stored in `/etc/pihole/custom.list`)

Only the first record will trigger an address-to-name association.
