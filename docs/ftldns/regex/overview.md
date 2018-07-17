A regular expression, or RegEx for short, is a pattern that can be used for building arbitrarily complex blocking rules in *FTL*DNS.
We implement the ERE flavor similar to the one used by the UNIX `egrep` (or `grep -E`) command.

Our implementation is computationally inexpensive as each domain is only checked once for a match (if you query `google.com`, it will be checked against your RegEx. Any subsequent query to the same domain will not be checked again until you restart `pihole-FTL`).

## How to use regular expressions for blocking
*FTL*DNS reads in regular expression filters from `/etc/pihole/regex.list` (one expression per line, lines starting with `#` will be skipped).
To tell *FTL*DNS to reload the list, either:

- Execute the `>recompile-regex` API command (`echo ">recompile-regex" | nc localhost 4711`)
- Send `SIGHUP` to `pihole-FTL` (`sudo killall -SIGHUP pihole-FTL`)
- Restart the service (`sudo service pihole-FTL restart`)

{!abbreviations.md!}
