<!-- markdownlint-disable MD051 MD046 -->
# Configuration

The recommended way to configure the Pi-hole docker container is by utilizing [environment variables](https://docs.docker.com/compose/how-tos/environment-variables/) for a simple and easily reproducible setup.

If you are persisting your `/etc/pihole` directory, you choose instead to set them via the web interface, or by directly editing `pihole.toml`

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
      FTLCONF_webserver_api_password: 'correct horse battery staple'
      FTLCONF_webserver_port: '8082,443s'
      FTLCONF_debug_api: 'true'

      # Array Types can either be delimited by semicolon
      # If you have only a few items this may be more convienient
      FTLCONF_dns_upstreams: '8.8.8.8;8.8.4.4;1.1.1.1;9.9.9.9'
      FTLCONF_misc_dnsmasq_lines: 'address=/example.com/192.168.1.1;address=/example.org/192.168.1.2;address=/example.net/192.168.1.3'
      
      # Or YAML Multiline block style can be used for better redability.
      # https://yaml.org/spec/1.2.2/#literal-style
      FTLCONF_dns_upstreams: |-
        8.8.8.8
        8.8.4.4
        1.1.1.1
        9.9.9.9        
      FTLCONF_misc_dnsmasq_lines: |-
        address=/example.com/192.168.1.1
        address=/example.org/192.168.1.2
        address=/example.net/192.168.1.3      
```

### Recommended Environment Variables

| Variable | Description |
| :--- | :--- |
| `TZ` | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to make sure logs rotate at local midnight instead of at UTC midnight. |
| `FTLCONF_webserver_api_password` | To set a specific password for the web interface (per the quick-start example).<br><br>If this variable is not detected, and you have not already set one previously inside the container via `pihole setpassword` or `pihole-FTL --config webserver.api.password`, then a random password will be assigned on startup, and will be printed to the log.<br><br>You can find this password by running `docker logs pihole` and looking for "random password". See [Setting the Web Interface Password](#setting-the-web-interface-password) below for usage examples. |
| `FTLCONF_dns_upstreams` | Upstream DNS server(s) for Pi-hole to forward queries to, separated by a semicolon<br><br>Supports non-standard ports with #[port number] e.g `127.0.0.1#5053;8.8.8.8;8.8.4.4`<br><br>Supports [Docker service names and links](https://docs.docker.com/compose/networking/) instead of IPs e.g `upstream0;upstream1` where upstream0 and upstream1 are the service names of or links to docker services |


## Setting the Web Interface Password {: #setting-the-web-interface-password }

The web interface password can be set using the `FTLCONF_webserver_api_password` environment variable as documented above or using the `WEBPASSWORD_FILE` environment variable using [Docker Compose Secrets](https://docs.docker.com/compose/how-tos/use-secrets/) or [Docker Swarm secrets](https://docs.docker.com/engine/swarm/secrets/).

!!! note
    To _explicitly_ set no password, set `FTLCONF_webserver_api_password: ''`<br/><br/>
    Using `pihole setpassword` for the purpose of setting an empty password will not persist between container restarts

### Examples

The `FTLCONF_webserver_api_password` variable can be set directly or sourced from files, environment variables, or Docker secrets. Choose the workflow that best matches your deployment.

=== "Docker Compose"
    Provide the password directly inside your Compose file.

    ```yaml
    ...
    environment:
      FTLCONF_webserver_api_password: 'correct horse battery staple'
    ...
    ```

=== "Docker Compose (env var)"
    Reference an [environment variable](https://docs.docker.com/compose/how-tos/environment-variables/) such as `ADMIN_PASSWORD`.

    ```yaml
    ...
    environment:
      FTLCONF_webserver_api_password: ${ADMIN_PASSWORD}
    ...
    ```

    Define it in the shell:

    ```bash
    export ADMIN_PASSWORD=correct horse battery staple
    docker compose -f compose.yaml
    ```

    Or in an `.env` file kept alongside your Compose yaml:

    ```bash
    $ cat .env
    ADMIN_PASSWORD=correct horse battery staple
    $ docker compose -f compose.yaml
    ```

=== "Docker Compose secret"
    Use `WEBPASSWORD_FILE` with Docker secrets to avoid storing the password directly in your Compose file.

    ```bash
    $ cat pihole_password.txt
    correct horse battery staple
    ```

    ```yaml
    ---
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

    secrets:
      pihole_webpasswd:
        file: ./pihole_password.txt
    ...
    ```

=== "Docker run"
    Set the password inline when launching the container.

    ```bash
    docker run --name pihole -p 53:53/tcp -p 53:53/udp -p 80:80/tcp -p 443:443/tcp -e TZ=Europe/London -e FTLCONF_webserver_api_password="correct horse battery staple" -e FTLCONF_dns_listeningMode=all -v ./etc-pihole:/etc/pihole -v ./etc-dnsmasq.d:/etc/dnsmasq.d --cap-add NET_ADMIN --restart unless-stopped pihole/pihole:latest
    ```


## Configuration Reference

### Optional Variables

| Variable | Default | Value | Description |
| :--- | :--- | :--- | :--- |
| `TAIL_FTL_LOG` | `1` | `<0\|1>` | Whether or not to output the FTL log when running the container. Can be disabled by setting the value to 0. |
| `PIHOLE_UID` | `1000` | Number | Overrides image's default pihole user id to match a host user id.<br/>**IMPORTANT**: id must not already be in use inside the container! |
| `PIHOLE_GID` | `1000` | Number | Overrides image's default pihole group id to match a host group id.<br/>**IMPORTANT**: id must not already be in use inside the container! |

### Advanced Variables

| Variable | Default | Value | Description |
| :--- | :--- | :--- | :--- |
| `FTL_CMD` | `no-daemon` | `no-daemon -- <dnsmasq option>` | Customize dnsmasq startup options. e.g. `no-daemon -- --dns-forward-max 300` to increase max. number of concurrent dns queries on high load setups. |
| `DNSMASQ_USER` | unset | `<pihole\|root>` | Allows changing the user that FTLDNS runs as. Default: `pihole`, some systems such as Synology NAS may require you to change this to `root`.<br><br>(See [#963](https://github.com/pi-hole/docker-pi-hole/issues/963)) |
| `ADDITIONAL_PACKAGES` | unset | Space separated list of APKs | HERE BE DRAGONS. Mostly for development purposes, this just makes it easier for those of us that always like to have whatever additional tools we need inside the container for debugging. |

### Docker Arguments

Here is a rundown of other arguments for your docker-compose / docker run.

| Docker Arguments | Description |
| :--- | :--- |
| `-p <port>:<port>` **Recommended** | Ports to expose (53, 80, 443, 67), the bare minimum ports required for Pi-holes HTTP, HTTPS and DNS services. |
| `--restart=unless-stopped`<br/> **Recommended** | Automatically (re)start your Pi-hole on boot or in the event of a crash. |
| `-v $(pwd)/etc-pihole:/etc/pihole`<br/> **Recommended** | Volumes for your Pi-hole configs help persist changes across docker image updates. |
| `--net=host`<br/> _Optional_ | Alternative to `-p <port>:<port>` arguments (Cannot be used at same time as `-p`) if you don't run any other web application. DHCP runs best with `--net=host`, otherwise your router must support dhcp-relay settings. |
| `--cap-add=NET_ADMIN`<br/> _Recommended_ | Commonly added capability for DHCP, see [Note on Capabilities](#note-on-capabilities) below for other capabilities. |
| `--dns=n.n.n.n`<br/> _Optional_ | Explicitly set container's DNS server. It is **_not recommended_** to set this to `localhost`/`127.0.0.1`. |
| `--env-file .env` <br/> _Optional_ | File to store environment variables for docker replacing `-e key=value` settings. Here for convenience. |

## Note on Capabilities {: #note-on-capabilities }

Pi-hole's DNS core (FTL) expects to have the following capabilities available:

- `CAP_NET_BIND_SERVICE`: Allows FTLDNS binding to TCP/UDP sockets below 1024 (specifically DNS service on port 53)
- `CAP_NET_RAW`: use raw and packet sockets (needed for handling DHCPv6 requests, and verifying that an IP is not in use before leasing it)
- `CAP_NET_ADMIN`: modify routing tables and other network-related operations (in particular inserting an entry in the neighbor table to answer DHCP requests using unicast packets)
- `CAP_SYS_NICE`: FTL sets itself as an important process to get some more processing time if the latter is running low
- `CAP_CHOWN`: we need to be able to change ownership of log files and databases in case FTL is started as a different user than `pihole`
- `CAP_SYS_TIME`: FTL needs to be able to set the system time to update it using the Network Time Protocol (NTP) in the background

This image automatically grants those capabilities, if available, to the FTLDNS process, even when run as non-root.\
By default, docker does not include the `NET_ADMIN` capability for non-privileged containers, and it is recommended to explicitly add it to the container using `--cap-add=NET_ADMIN`.\
However, if DHCP and IPv6 Router Advertisements are not in use, it should be safe to skip it. For the most paranoid, it should even be possible to explicitly drop the `NET_RAW` capability to prevent FTLDNS from automatically gaining it.

