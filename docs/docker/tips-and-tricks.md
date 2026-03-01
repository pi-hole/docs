## Disable systemd-resolved port 53

Modern releases of Ubuntu (17.10+) and Fedora (33+) include [`systemd-resolved`](http://manpages.ubuntu.com/manpages/bionic/man8/systemd-resolved.service.8.html) which is configured by default to implement a caching DNS stub resolver. This will prevent pi-hole from listening on port 53.

The stub resolver should be disabled with:

```bash
sudo sh -c 'mkdir -p /etc/systemd/resolved.conf.d && printf "[Resolve]\nDNSStubListener=no\n" | tee /etc/systemd/resolved.conf.d/no-stub.conf'
```

This will not change the nameserver settings, which point to the stub resolver thus preventing DNS resolution. Change the `/etc/resolv.conf` symlink to point to `/run/systemd/resolve/resolv.conf`, which is automatically updated to follow the ubuntu system's [`netplan`](https://netplan.io/) or fedora system's [`sysconfig`](https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration):

```bash
sudo sh -c 'rm -f /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
```

After making these changes, you should restart systemd-resolved using:

```bash
systemctl restart systemd-resolved
```

Note that it is also possible to disable `systemd-resolved` entirely. However, this can cause problems with name resolution in VPNs ([see bug report](https://bugs.launchpad.net/network-manager/+bug/1624317)).
It also disables the functionality of netplan since systemd-resolved is used as the default renderer ([see `man netplan`](http://manpages.ubuntu.com/manpages/bionic/man5/netplan.5.html#description)).
If you choose to disable the service, you will need to manually set the nameservers, for example by creating a new `/etc/resolv.conf`.

Users of older Ubuntu releases (circa 17.04) will need to disable `dnsmasq`.

## Set Pi-hole as System DNS Server

Once pi-hole is installed, you'll want to configure your clients to use it ([see here](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245)). If you used the symlink above, your docker host will either use whatever is served by DHCP, or whatever static setting you've configured. If you want to explicitly set your docker host's nameservers you can edit the netplan(s) found at `/etc/netplan`, then run `sudo netplan apply`.

<!-- markdownlint-disable code-block-style -->
!!! warning "**Important: Catch-22 situation**"
    When Pi-hole is used as the host's DNS server and Pi-hole is down, the host will lack DNS resolution. This can lead to situation where you might be unable to spin-up the Pi-hole container.
<!-- markdownlint-enable code-block-style -->
Example netplan:

```yaml
network:
    ethernets:
        ens160:
            dhcp4: true
            dhcp4-overrides:
                use-dns: false
            nameservers:
                addresses: [127.0.0.1]
    version: 2
```

For Fedora users, you can run the following commands to edit the sysconfig(s) found at `/etc/NetworkManager/system-connections` via nmcli.

Example sysconfig nmcli commands:

1. Add Connection:

    ```bash
    nmcli connection add type ethernet ifname ens160 con-name ens160-night autoconnect yes
    ```

2. Configure DNS:

    ```bash
    nmcli connection modify ens160-night ipv4.method auto ipv4.ignore-auto-dns yes ipv4.dns "127.0.0.1"
    ```

3. Activate Connection:

    ```bash
    nmcli connection up ens160-night
    ```

## Common Issues

- A good way to test things are working right is by loading this page: [http://pi.hole/admin/](http://pi.hole/admin/)
- Port conflicts?  Stop your server's existing DNS / Web services.
    - Don't forget to stop your services from auto-starting again after you reboot.
    - Ubuntu users see below for more detailed information.
    - If only ports 80 and/or 443 are in use, you have two options:
        - Change the container's port mapping by adjusting the Docker `-p` flags or the `ports:` section in the compose file. For example, change `- "80:80/tcp"` to `- "8080:80/tcp"` to expose the container’s internal HTTP port 80 as 8080 on the host.
        - Or, when running the container in `network_mode: host`, where port mappings are not available, change the ports used by the Pi-hole web server using the `FTLCONF_webserver_port` environment variable.<br>
          Example:<br>
          `FTLCONF_webserver_port: '8080o,[::]:8080o,8443os,[::]:8443os'`<br>
          This makes the web interface available on HTTP port 8080 and HTTPS port 8443 for both IPv4 and IPv6.
        - **Note:** This only applies to web interface ports (80 and 443). DNS (53), DHCP (67), and NTP (123) ports must still be handled via Docker port mappings or host networking.
- Docker's default network mode `bridge` isolates the container from the host's network. This is a more secure setting, but requires setting the Pi-hole DNS option for _Interface listening behavior_ to "Listen on all interfaces, permit all origins".
- If you're using a Red Hat based distribution with an SELinux Enforcing policy, add `:z` to line with volumes.

## Note on Watchtower

We have noticed that a lot of people use Watchtower to keep their Pi-hole containers up to date. For the same reason we don't provide an auto-update feature on a bare metal install, you _should not_ have a system automatically update your Pi-hole container. Especially unattended. As much as we try to ensure nothing will go wrong, sometimes things do go wrong - and you need to set aside time to _manually_ pull and update to the version of the container you wish to run. The upgrade process should be along the lines of:

- **Important**: Read the release notes. Sometimes you will need to make changes other than just updating the image.
- Pull the new image.
- Stop and _remove_ the running Pi-hole container
    - If you care about your data (logs/customizations), make sure you have it volume-mapped or it will be deleted in this step.
- Recreate the container using the new image.

To exclude the Pi-hole container from Watchtower's auto-update system take a look at [Full Exclude](https://containrrr.dev/watchtower/container-selection/#full_exclude) in Watchtower's docs.

Pi-hole is an integral part of your network, don't let it fall over because of an unattended update in the middle of the night.
