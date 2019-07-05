A regular expression, or RegEx for short, is a pattern that can be used for building arbitrarily complex blocking rules in *FTL*DNS.
We implement the POSIX Extended Regular Expressions similar to the one used by the UNIX `egrep` (or `grep -E`) command.

Our implementation is light and fast as each domain is only checked once for a match (if you query `google.com`, it will be checked against your RegEx. Any subsequent query to the same domain will not be checked again until you restart `pihole-FTL`).

## How to use regular expressions for blocking
*FTL*DNS reads in regular expression filters from the [`regex` database table](../../database/gravity/lists.md#regex-table-regex).
To tell *FTL*DNS to reload the list of regex filters, either:

- Execute the `>recompile-regex` API command (`echo ">recompile-regex" | nc localhost 4711`) or
- Send `SIGHUP` to `pihole-FTL` (`sudo killall -SIGHUP pihole-FTL`) or
- Restart the service (`sudo service pihole-FTL restart`)

## Pi-hole Regex debugging mode
To ease the usage of regular expression filters in *FTL*DNS, we offer a regex debugging mode. Set
```
DEBUG_REGEX=true
```
in your `/etc/pihole/pihole-FTL.conf` and restart `pihole-FTL` to enable or disable this mode.

Once the debugging mode is enabled, each match will be logged to `/var/log/pihole-FTL.log` in the following format:
```
[2018-07-17 17:40:51.304] Regex in line 2 "((^)|(\.))twitter\." matches "whatever.twitter.com"
```
The given line number corresponds to the line in the `regex` database table.

Note that validation is only done on the first occurrence of a domain to increase the computational efficiency of *FTL*DNS.

{!abbreviations.md!}
