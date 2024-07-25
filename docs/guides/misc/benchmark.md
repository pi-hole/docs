# Realistic benchmarking of your Pi-hole

If you want to know how many queries - using the given hardware - your Pi-hole can handle to, e.g., estimate how many clients could be served, you could mass query domains from your long-term database.
As the domains in the long-term database reflect **your particular** real-life usage, a benchmark on these domains should give you a good feeling for the performance of your Pi-hole.

## 1. Extract the domains from the long-term database

You can extract the domains using, e.g.,

```bash
sqlite3 /etc/pihole/pihole-FTL.db "SELECT domain FROM queries LIMIT 100000;" > domains.list
```

This will generate a list file with up to 100,000 domains. You can increase the upper limit of domains, however, we suggest starting from a small number of domains to get realistic results in a reasonable period of time.

They are extracted into the list file as they are recorded in the database. There will be lots of frequently queried domains (maybe `google.com` or similar) as well as some blocked ad domains. This list will serve you as an individualized testing bench for realistic DNS queries as typically seen in **your particular environment**.

## 2. Optimize Pi-hole setting for benchmarking

### 2.1 Disable logging

We suggest disabling both logging and the long-term database during the benchmark run as both the log file and the database would otherwise unnecessarily grow, several hundred megabytes may be possible. Not only would your statistics be distorted by the artificial mass querying, but the benchmark could also be negatively affected by the writing speed of your SD card.

Logging can be disabled using `sudo pihole logging off`.

The long-term database can be disabled by setting

```
DBFILE=
```

in `/etc/pihole/pihole-FTL.conf` and running `sudo pihole restartdns` (see also [here](../../ftldns/configfile.md/#dbfile)).

### 2.2 Increase DNS cache size

We also suggest increasing the DNS cache for benchmarking. The rather low value is fine for typical use cases. Domains will expire at some point and make room for new domains. As the benchmark will artificially increase the querying rate, there will be no time for the domains to expire naturally. This would dramatically hit the caching performance while you would never see such performance penalties in real use cases.

Set `cache-size` to a rather high value (maybe 25,000 - by guess roughly one-eighth to one-fourth number of the domains you extracted from the database in step 1) in `/etc/dnsmasq.d/01-pihole.conf` and run `sudo pihole restartdns` afterward.

## 3. Query domains from the list

Use

```bash
time dig -f domains.list +noall +answer > /dev/null
```

for mass querying the domains from your list. This will show you how much time it takes to query the number of domains you extracted from the database.
