# Configuration

The recommended way to configure the Pi-hole docker container is by utilizing [environment variables](https://docs.docker.com/compose/how-tos/environment-variables/), however if you are persisting your `/etc/pihole` directory, you choose instead to set them via the web interface, or by directly editing `pihole.toml`

## Environment Variables

### Recommended Variables

#### `TZ` (Default: `UTC`)

Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to make sure logs rotate at local midnight instead of at UTC midnight.

#### `FTLCONF_webserver_api_password` (Default: `unset`)

To set a specific password for the web interface, use the environment variable `FTLCONF_webserver_api_password` (per the quick-start example). If this variable is not detected, and you have not already set one previously inside the container via `pihole setpassword` or `pihole-FTL --config webserver.api.password`, then a random password will be assigned on startup, and will be printed to the log. You can find this password with the command `docker logs pihole | grep random password` on your host to find this password.

#### `FTLCONF_dns_upstreams` (Default: `8.8.8.8;8.8.4.4`)

- Upstream DNS server(s) for Pi-hole to forward queries to, separated by a semicolon
- Supports non-standard ports with #[port number] e.g `127.0.0.1#5053;8.8.8.8;8.8.4.4`
- Supports Docker service names and links instead of IPs e.g `upstream0;upstream1` where upstream0 and upstream1 are the service names of or links to docker services

### Configuring FTL Via The Environment

While FTL's configuration file can be manually edited, set via the CLI (`pihole-FTL --config setting.name=value`), or set via the web interface - the recommended approach is to do this via environment variables

As with the recommended examples above for the web password and DNS upstreams, the syntax is `FTLCONF_[section_][setting]`

Given the below `toml` formatted example from `pihole.toml`, we can translate this to the environment variable `FTLCONF_dns_dnssec`

```toml
[dns]
  dnssec = true
```

Array type configs should be delimited with `;`

!!! note
    All FTL settings that are set via environment variables effectively become read-only, meaning that you will not be able to change them via the web interface or CLI. This is to ensure a "single source of truth" on the config. If you later unset or remove an environment variable, then FTL will revert to the default value for that setting


An example of how some of these variables may look in your compose file

```yaml
    environment:
      TZ: europe/London
      FTLCONF_dns_revServers: 'true,192.168.0.0/16,192.168.0.1,lan'
      FTLCONF_dns_upstreams: '8.8.8.8;8.8.4.4'
      FTLCONF_webserver_api_password: 'correct horse battery staple'
      FTLCONF_webserver_port: '8082,443s'
      FTLCONF_debug_api: 'true'
```

### Other Variables

#### `TAIL_FTL_LOG` (Default: `1`)

Whether or not to output the FTL log when running the container. Can be disabled by setting the value to 0

#### `PIHOLE_UID` (Default: `100`)

Overrides image's default pihole user id to match a host user id

#### `PIHOLE_GID` (Default: `100`)

Overrides image's default pihole group id to match a host group id

!!! Warning
    For the above two settings, the `id` must not already be in use inside the container!

#### `FTL_CMD` (Default: `no-daemon`)

Customize the options with which dnsmasq gets started. e.g. `no-daemon -- --dns-forward-max 300` to increase max. number of concurrent dns queries on high load setups.

#### `DNSMASQ_USER` (Default: `pihole`)

Allows changing the user that FTLDNS runs as. Default: pihole, some systems such as Synology NAS may require you to change this to root (See [pihole/docker-pi-hole#963](https://github.com/pi-hole/docker-pi-hole/issues/963))

#### `ADDITIONAL_PACKAGES` (Default: unset)

Mostly for development purposes, this just makes it easier for those of us that always like to have whatever additional tools we need inside the container for debugging.

Adding packages here is the same as running `apk add <package>` inside the container

#### `PH_VERBOSE` (Default: `0`)

Setting this environment variable to `1` will set `-x`, making the scripts that run on container startup more verbose. Useful for debugging only.
