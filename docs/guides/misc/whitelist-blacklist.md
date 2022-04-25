### What to Whitelist or Blacklist

[This extension for Google Chrome](https://chrome.google.com/webstore/detail/adamone-assistant/fdmpekabnlekabjlimjkfmdjajnddgpc) can help you in finding out which domains you need to whitelist.

### How to Whitelist or Blacklist

There are scripts to aid users in adding or removing domains to the whitelist or blacklist from the CLI

Each script accepts the following parameters:

| Parameter  | Description                                                                                      |
|------------|--------------------------------------------------------------------------------------------------|
| `[domain]` | Fully qualified domain name you wish to add or remove. You can pass any number of domains.       |
| `-d`       | Removal mode. Domains will be removed from the list, rather than added                           |
| `-nr`      | Update blacklist without refreshing pihole-FTL                                                   |
| `-f`       | Force delete cached blocklist content                                                            |
| `-q`       | Quiet mode. Console output is minimal. Useful for calling from another script (see `gravity.sh`) |

Domains passed are parsed by the script to ensure they are valid domains. If a domain is invalid it will be ignored.

By default, Whitelisted/Blacklisted domains are associated with the Default Group only. If the domain should be associated with other groups, these will need to be selected in **Group Management > Domains** within the Pi-Hole web frontend.

#### Example `pihole -w` usages

* Attempt to add one or more domains to the whitelist and reload pihole-FTL:

    ```bash
    pihole -w domain1 [domain2...]
    ```

* Attempt to add one or more domains to the whitelist, but do not reload pihole-FTL:

    ```bash
    pihole -w -nr domain1 [domain2...]
    ```

* Attempt to add one or more domains to the whitelist and force pihole-FTL to reload:

    ```bash
    pihole -w -f domain1 [domain2...]
    ```

To remove domains from the whitelist add `-d` as an additional argument, e.g:

```bash
pihole -w -d domain1 [domain2...]
```

#### Example `pihole -b` usages

* Attempt to add one or more domains to the blacklist and reload pihole-FTL:

    ```bash
    pihole -b domain1 [domain2...]
    ```

* Attempt to add one or more domains to the blacklist, but do not reload pihole-FTL:

    ```bash
    pihole -b -nr domain1 [domain2...]
    ```

* Attempt to add one or more domains to the blacklist and force pihole-FTL to reload:

    ```bash
    pihole -b -f domain1 [domain2...]
    ```

To remove domains from the blacklist add `-d` as an additional argument, e.g:

```bash
pihole -b -d domain1 [domain2...]
```
