# Configuration

The recommended way to configure the Pi-hole docker container is by utilizing [environment variables](https://docs.docker.com/compose/how-tos/environment-variables/), however if you are persisting your `/etc/pihole` directory, you choose instead to set them via the web interface, or by directly editing `pihole.toml`

## Environment Variables

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

### Recommended Variables

#### `TZ` (Default: `UTC`)

Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to make sure logs rotate at local midnight instead of at UTC midnight.

#### `FTLCONF_webserver_api_password` (Default: `unset`)

To set a specific password for the web interface, use the environment variable `FTLCONF_webserver_api_password` (per the quick-start example). If this variable is not detected, and you have not already set one previously inside the container via `pihole setpassword` or `pihole-FTL --config webserver.api.password`, then a random password will be assigned on startup, and will be printed to the log. You can find this password with the command `docker logs pihole | grep random password` on your host to find this password. See [Notes On Web Interface Password](#notes-on-web-interface-password) below for usage examples.

!!! note
    To _explicitly_ set no password, set `FTLCONF_webserver_api_password: ''`<br/><br/>
    Using `pihole setpassword` for the purpose of setting an empty password will not persist between container restarts

#### `FTLCONF_dns_upstreams` (Default: `8.8.8.8;8.8.4.4`)

- Upstream DNS server(s) for Pi-hole to forward queries to, separated by a semicolon
- Supports non-standard ports with #[port number] e.g `127.0.0.1#5053;8.8.8.8;8.8.4.4`
- Supports Docker service names and links instead of IPs e.g `upstream0;upstream1` where upstream0 and upstream1 are the service names of or links to docker services

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

#### `WEBPASSWORD_FILE` (Default: unset)

Set the web interface password using [Docker Compose Secrets](https://docs.docker.com/compose/how-tos/use-secrets/) if using Compose or [Docker Swarm secrets](https://docs.docker.com/engine/swarm/secrets/) if using Docker Swarm. If `FTLCONF_webserver_api_password` is set, `WEBPASSWORD_FILE` is ignored. If `FTLCONF_webserver_api_password` is empty, and `WEBPASSWORD_FILE` is set to a valid readable file path, then `FTLCONF_webserver_api_password` will be set to the contents of `WEBPASSWORD_FILE`. See [Notes On Web Interface Password](#notes-on-web-interface-password) below for usage examples.

### Variable Formatting

Environment variables may be set in the format given here, or they may be entirely uppercase in the conventional manner.

For example, both `FTLCONF_dns_upstreams` and `FTLCONF_DNS_UPSTREAMS` are functionally equivalent when used as environment variables.

## Notes On Web Interface Password

The web interface password can be set using the `FTLCONF_webserver_api_password` environment variable as documented above or using the `WEBPASSWORD_FILE` environment variable using [Docker Compose Secrets](https://docs.docker.com/compose/how-tos/use-secrets/) or [Docker Swarm secrets](https://docs.docker.com/engine/swarm/secrets/).

### `FTLCONF_webserver_api_password` Examples

The `FTLCONF_webserver_api_password` variable can be set in a `docker run` command or as an environment attribute in a Docker Compose yaml file.

#### Docker run example

```bash
docker run --name pihole -p 53:53/tcp -p 53:53/udp -p 80:80/tcp -p 443:443/tcp -e TZ=Europe/London -e FTLCONF_webserver_api_password="correct horse battery staple" -e FTLCONF_dns_listeningMode=all -v ./etc-pihole:/etc/pihole -v ./etc-dnsmasq.d:/etc/dnsmasq.d --cap-add NET_ADMIN --restart unless-stopped pihole/pihole:latest
```

#### Docker Compose examples

Set using a text value.

```yaml
    ...
    environment:
      FTLCONF_webserver_api_password: 'correct horse battery staple'
    ...
```

Set using an [environment variable](https://docs.docker.com/compose/how-tos/environment-variables/) called, for example, `ADMIN_PASSWORD`. The value of `ADMIN_PASSWORD` can be set in the shell of the `docker compose` command or in an `.env` file. See the link above for detailed information.

```yaml
    ...
    environment:
      FTLCONF_webserver_api_password: ${ADMIN_PASSWORD}
    ...
```

Define ADMIN_PASSWORD in shell.

```bash
export ADMIN_PASSWORD=correct horse battery staple
docker compose -f compose.yaml
```

Or define ADMIN_PASSWORD in `.env` file. The `.env` file is placed in the same directory where the Compose yaml file (e.g. `compose.yaml`) is located.

```bash
$ cat .env
ADMIN_PASSWORD=correct horse battery staple
$ docker compose -f compose.yaml
```

### `WEBPASSWORD_FILE` Example

This example takes advantage of Docker Secrets ([Docker Compose Secrets](https://docs.docker.com/compose/how-tos/use-secrets/)
or [Docker Swarm secrets](https://docs.docker.com/engine/swarm/secrets/)) which sets
strict permissions for the secrets file in the container. The secrets file **must**
share the user and group IDs (UID and GID) that the pihole executables have in the
container. By default, this a UID and GID of 1000 but can be changed with the optional
[PIHOLE_UID and PIHOLE_GID variables](https://github.com/pi-hole/docker-pi-hole/tree/development#optional-variables).

Create a text file called, for example, `pihole_password.txt` containing the
password in the same directory containing the Compose yaml file (e.g `compose.yaml`).

  ```bash
  $ cat pihole_password.txt
  correct horse battery staple
  ```

Set the permissions on the Docker host for `pihole_password.txt` (using the
default UID and GID of 1000 in this example). Note that these permissions
could make this file unreadable on the host. These permissions are used in
the container.

  ```bash
  sudo chown 1000:1000 pihole_password.txt
  sudo chmod 0400 pihole_password.txt
  ```

Amend compose yaml file with Docker Secrets attributes. The `/run/secrets/`
path is automatically prepended to `pihole_password.txt` during the Pi-Hole container
initialization process.

```yaml
---
# define pihole service
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest

    # lines deleted

    environment:
      WEBPASSWORD_FILE: pihole_webpasswd

    # lines deleted

    secrets:
      - pihole_webpasswd
    restart: unless-stopped

# define pihole_webpasswd secret
secrets:
  pihole_webpasswd:
    file: ./pihole_password.txt
...
```
