# Access internal devices through the WireGuard tunnel

## Enable IP forwarding on the server

Enable IP forwarding on your server by removing the comments in front of

```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

in the file `/etc/sysctl.d/99-sysctl.conf`

Then apply the new option with the command below.

```bash
sudo sysctl -p
```

If you see the options repeated like

```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

they were enabled successfully.

A properly configured firewall is ***highly*** recommended for any Internet-facing device. Configuring a firewall (`iptables`, `ufw`, etc.) is not part of this guide.

## Enable NAT on the server

!!! info "Optional for NAT"
    If the server is behind a router and receives traffic via NAT, these iptables rules are not needed.

On your server, add the following to the `[INTERFACE]` section of your `/etc/wireguard/wg0.conf`:

```bash
PostUp = iptables -w -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -w -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -w -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -w -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

!!! warning "Substitute interface"
    Substitute `eth0` in the preceding lines to match the Internet-facing interface.

??? info "The `PostUp` and `PostDown` options"
    `PostUp` and `PostDown` defines steps to be run after the interface is turned on or off, respectively. In this case, iptables is used to set Linux IP masquerade rules to allow all the clients to share the server’s IPv4 and IPv6 address.
    The rules will then be cleared once the tunnel is down.

## Allow clients to access other devices

In our standard configuration, we have configured the clients in such a way that they can only speak to the server. This has to be changed on both the server and the clients.

### Server side

Change the allowed addresses in your `/etc/wireguard/wg0.conf` from

```bash
[Peer]
AllowedIPs = 10.100.0.1/32, fd08:4711::1/64
```

to

```bash
[Peer]
AllowedIPs = 10.100.0.0/24, fd08:4711::/64, 192.168.2.0/24
```

assuming your internal network is in the IP range `192.168.2.1` - `192.168.2.254`. The change `10.100.0.1/32` to `10.100.0.0/24` also allows your WireGuard peers to see each other.

### Client side

Do the same you did above for the server also in the `[Interface]` section of all clients you want to have this feature:

```bash
[Peer]
AllowedIPs = 10.0.0.0/24, fd08:4711::/64, 192.168.2.0/24
```


It is possible to add this only for a few clients, leaving the others isolated to only the Pi-hole server itself.
