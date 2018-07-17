# Pi-hole Regex debugging mode
To ease the usage of regular expression filters in *FTL*DNS, we offer a regex debugging mode. Set
```
REGEX_DEBUGMODE=true
```
in your `/etc/pihole/pihole-FTL.conf` and restart `pihole-FTL` to enable or disable this mode.

Once the debugging mode is enabled, each match will be logged to `/var/log/pihole-FTL.log` in the following format:
```
[2018-07-17 17:40:51.304] DEBUG: Regex in line 2 ("((^)|(\.))twitter\.") matches "whatever.twitter.com"
```
The given line number corresponds to the line in the file `/etc/pihole/regex.list`.

Note that validation is only done on the first occurrence of a domain to increase the computational efficiency of *FTL*DNS.

{!abbreviations.md!}
