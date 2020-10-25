# Frequently asked questions

## Issues with dynamic server IP

Hostnames cannot be resolved during startup. This may lead to a five minutes delay during boot. A solution to this is to disable the automatic start of the `wg` interface during start and connect only later (manually) when you are sure that you can resolve hostnames.

1. Disable `auto wg0` in `/etc/network/interfaces` (put `#` in front, like `#auto wg0`)
2. Start `wireguard` manually using `sudo ifup wg0`

If the IP changes while the connection is running, resolving the new IP address fails often. Reconnect using

```bash
sudo ifdown wg0 && sudo ifup wg0
```

To achieve a permanent solution, one can install a `cron` job which restarts the connection automatically whenever a change is detected. This avoids excessive restarts of the interface. Example script (taken from [Ubuntuusers Wiki](https://wiki.ubuntuusers.de/WireGuard)):

```bash
#!/bin/bash
# Check state of wg0 interface
wgstatus=$(wg)
if [ "$wgstatus" == "interface: wg0" ]; then
    ip link delete wg0 && ifup wg0
elif [ "$wgstatus" == "interface: wg0" ]; then
    ifup wg0
else
    file="/tmp/digIP.txt"
    digIP=$(dig +short beispiel2.domain.de) # Change this to your domain !
    if [ -e "$file" ]; then
        fileTXT=$(cat "$file")
        if [ "$digIP" != "$fileTXT" ]; then
            #echo "Daten sind gleich"
            /sbin/ifdown wg0
            /sbin/ifup wg0
            echo "$digIP" > "$file"
        fi
    else
        echo "$digIP" > "$file"
    fi
fi
```

Store this file as `/home/[user name]/wg-restart.sh` and add it to your `crontab`:

```bash
sudo crontab -e
```

```plain
*/10 * * * * bash /home/[user name]/wg-restart.sh    # Runs the script every 10 minutes
```

## Routes are periodically reset

Users of NetworkManager should make sure that it is not managing the WireGuard interface(s). For example, create the configuration file `/etc/NetworkManager/conf.d/unmanaged.conf` with content

```bash
[keyfile]
unmanaged-devices=interface-name:wg*
```

[source](https://wiki.archlinux.org/index.php/WireGuard)

## Broken DNS resolution

When tunneling all traffic through a WireGuard interface, the connection can become seemingly lost after a while or upon a new connection. This could be caused by a network manager or DHCP client overwriting `/etc/resolv.conf`.
By default, `wg-quick` uses `resolvconf` to register new DNS entries (from the DNS keyword in the configuration file). This will cause issues with network managers and DHCP clients that do not use `resolvconf`, as they will overwrite `/etc/resolv.conf` thus removing the DNS servers added by `wg-quick`.

The solution is to use networking software that supports `resolvconf`.

!!! info "Hint for Ubuntu users"
    Users of `systemd-resolved` should make sure that `systemd-resolvconf` is installed.

[source](https://wiki.archlinux.org/index.php/WireGuard)

## Low MTU

Due to too low MTU (lower than 1280), `wg-quick` may fail to create the WireGuard interface. This can be solved by setting the MTU value in WireGuard configuration in the Interface section on the client:

```bash
[Interface]
MTU = 1500
```

[source](https://wiki.archlinux.org/index.php/WireGuard)
