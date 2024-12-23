### What Domains To Allow or Deny

[This extension for Google Chrome](https://chrome.google.com/webstore/detail/adamone-assistant/fdmpekabnlekabjlimjkfmdjajnddgpc) can help you in finding out which domains you need to allow.

### How to Allow or Deny Domains

There are scripts to aid users in adding or removing domains to the allowlist or denylist from the CLI

Each script accepts the following parameters:

| Parameter  | Description                                                                                      |
|------------|--------------------------------------------------------------------------------------------------|
| `[domain]` | Fully qualified domain name you wish to add or remove. You can pass any number of domains.       |
| `remove`   | Removal mode. Domains will be removed from the list, rather than added          |
| `-q`       | Quiet mode. Console output is minimal. Useful for calling from another script (see `gravity.sh`) |

Domains passed are parsed by the script to ensure they are valid domains. If a domain is invalid it will be ignored.

By default, allowed or denied domains are associated with the Default Group only. If the domain should be associated with other groups, these will need to be selected in **Group Management > Domains** within the Pi-Hole web frontend.

#### Example `pihole allow` usages

* Attempt to add one or more domains to the allowlist and reload pihole-FTL:

    ```bash
    pihole allow domain1 [domain2...]
    ```

To remove domains from the allowlist add `remove` as an additional argument, e.g:

```bash
pihole allow remove domain1 [domain2...]
```

#### Example `pihole deny` usages

* Attempt to add one or more domains to the denylist and reload pihole-FTL:

    ```bash
    pihole deny domain1 [domain2...]
    ```

To remove domains from the denylist add `remove` as an additional argument, e.g:

```bash
pihole deny remove domain1 [domain2...]
```
