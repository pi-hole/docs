# Access internal devices through the WireGuard tunnel

## Enable IP forwarding on the server

Enable IP forwarding on your server by removing the comments in front of

```plain
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

in the file `/etc/sysctl.d/99-sysctl.conf`

Then apply the new option with the command below.

```bash
sudo sysctl -p
```

If you see the options repeated like

```plain
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

they were enabled successfully.

A properly configured firewall is ***highly*** recommended for any Internet-facing device. Configuring a firewall (`iptables`, `ufw`, etc.) is not part of this guide.

## Enable NAT on the server

On your server, add the following to the `[INTERFACE]` section of your `/etc/wireguard/wg0.conf`:

```bash
PostUp = iptables -w -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -w -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -w -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -w -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

<!-- markdownlint-disable code-block-style -->
!!! warning "**Important:** Substitute interface"
    **Without the correct interface name, this will not work!**

    Substitute `eth0` in the preceding lines to match the Internet-facing interface. This may be `enp2s0` or similar on more recent Ubuntu versions (check, e.g., `ip a` for details about your local interfaces).
<!-- markdownlint-enable code-block-style -->

<!-- markdownlint-disable code-block-style -->
!!! warning "**Important:** Debian Bullseye (Debian 11) and Raspian 11"
    Debian Bullseye doesn't include iptables per default and uses nftables.

    We have to set following rules for PostUP and PostDown:
    ```bash
    PostUp = nft add table ip wireguard; nft add chain ip wireguard wireguard_chain {type nat hook postrouting priority srcnat\; policy accept\;}; nft add rule ip wireguard wireguard_chain oifname "eth0" counter packets 0 bytes 0 masquerade; nft add table ip6 wireguard; nft add chain ip6 wireguard wireguard_chain {type nat hook postrouting priority srcnat\; policy accept\;}; nft add rule ip6 wireguard wireguard_chain oifname "eth0" counter packets 0 bytes 0 masquerade
    PostDown = nft delete table ip wireguard; nft delete table ip6 wireguard
    ```
<!-- markdownlint-enable code-block-style -->

`PostUp` and `PostDown` defines steps to be run after the interface is turned on or off, respectively. In this case, iptables is used to set Linux IP masquerade rules to allow all the clients to share the server’s IPv4 and IPv6 address.
The rules will then be cleared once the tunnel is down.

<!-- markdownlint-disable code-block-style -->
??? info "Exemplary server config file with this change"
    ```plain
    [Interface]
    PrivateKey = [your server's private key]
    Address = [Wireguard-internal IPs of the server, e.g. 10.100.0.1/24, fd08:4711::1/64]
    ListenPort = 47111

    PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o enp2s0 -j MASQUERADE
    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o enp2s0 -j MASQUERADE

    # Android phone
    [Peer]
    PublicKey = [public key of this client]
    PresharedKey = [pre-shared key of this client]
    AllowedIPs = [Wireguard-internal IP of this client, e.g., 10.100.0.2/32, fd08:4711::2/128]

    # maybe more [Peer] sections for more clients
    ```

    The important change is the extra `PostUp` and `PostDown` in the `[Interface]` section.
<!-- markdownlint-enable code-block-style -->
## Allow clients to access other devices

In our standard configuration, we have configured the clients in such a way that they can only speak to the server. Add the network range of your local network in CIDR notation (e.g., `192.168.2.1 - 192.168.2.254` -> `192.168.2.0/24`) in the `[Peers]` section of all clients you want to have this feature:

```plain
[Peer]
AllowedIPs = 10.0.0.0/24, fd08:4711::/64, 192.168.2.0/24
```

It is possible to add this only for a few clients, leaving the others isolated to only the Pi-hole server itself.

<!-- markdownlint-disable code-block-style -->
??? info "Exemplary client config file with this change"
    ```plain
    [Interface]
    PrivateKey = [your client's private key]
    Address = [Wireguard-internal IPs of your client, e.g. 10.100.0.2/32, fd08:4711::2/128]
    DNS = 10.100.0.1

    [Peer]
    AllowedIPs = 10.100.0.0/24, fd08::/64, 192.168.2.0/24
    Endpoint = [your server's public IP or domain]:47111
    PublicKey = [public key of the server]
    PresharedKey = [pre-shared key of this client]
    PersistentKeepalive = 25
    ```

    The important change is the extra `192.168.2.0/24` at the end of the `[Peer] -> AllowedIPs` entry.
<!-- markdownlint-enable code-block-style -->
