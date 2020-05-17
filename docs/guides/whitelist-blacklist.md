### What to Whitelist or Blacklist

[This extension for Google Chrome](https://chrome.google.com/webstore/detail/adamone-assistant/fdmpekabnlekabjlimjkfmdjajnddgpc) can help you in finding out which domains you need to whitelist.

### How to Whitelist or Blacklist

There are scripts to aid users in adding or removing domains to the whitelist or blacklist.

The scripts will first parse `whitelist.txt` or `blacklist.txt` for any changes, and if any additions or deletions are detected, it will reload `dnsmasq` so that they are effective immediately.

Each script accepts the following parameters:

| Parameter  | Description                                                                                      |
|------------|--------------------------------------------------------------------------------------------------|
| `[domain]` | Fully qualified domain name you wish to add or remove. You can pass any number of domains.       |
| `-d`       | Removal mode. Domains will be removed from the list, rather than added                           |
| `-nr`      | Update blacklist without refreshing pihole-FTL                                                   |
| `-f`       | Force delete cached blocklist content                                                            |
| `-q`       | Quiet mode. Console output is minimal. Useful for calling from another script (see `gravity.sh`) |

Domains passed are parsed by the script to ensure they are valid domains. If a domain is invalid it will be ignored.

#### Example `pihole -w` usages

* Attempt to add one or more domains to the whitelist and reload dnsmasq:

    ```bash
    pihole -w domain1 [domain2...]
    ```

* Attempt to add one or more domains to the whitelist, but do not reload dnsmasq:

    ```bash
    pihole -w -nr domain1 [domain2...]
    ```

* Attempt to add one or more domains to the whitelist and force dnsmasq to reload:

    ```bash
    pihole -w -f domain1 [domain2...]
    ```

To remove domains from the whitelist add `-d` as an additional argument, e.g:

```bash
pihole -w -d domain1 [domain2...]
```

#### Example `pihole -b` usages

* Attempt to add one or more domains to the blacklist and reload dnsmasq:

    ```bash
    pihole -b domain1 [domain2...]
    ```

* Attempt to add one or more domains to the blacklist, but do not reload dnsmasq:

    ```bash
    pihole -b -nr domain1 [domain2...]
    ```

* Attempt to add one or more domains to the blacklist and force dnsmasq to reload:

    ```bash
    pihole -b -f domain1 [domain2...]
    ```

To remove domains from the blacklist add `-d` as an additional argument, e.g:

```bash
pihole -b -d domain1 [domain2...]
```
