# Regex Test mode

In order to ease regex development, we added a regex test mode to `pihole-FTL` which can be invoked like

```bash
pihole-FTL regex-test doubleclick.net
```

(test `doubleclick.net` against all regexes in the gravity database), or

```bash
pihole-FTL regex-test doubleclick.net "(^|\.)double"
```

(test `doubleclick.net` against the CLI-provided regex `(^|\.)double`.

You do NOT need to be `sudo` for this, any arbitrary user should be able to run this command. The test returns `0` on match, `1` on errors and `2` on no match, hence, it may be used for scripting.
