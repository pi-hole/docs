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
