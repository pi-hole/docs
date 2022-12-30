This guide was developed using FRITZ!OS 07.21 but should work for others too. It aims to line out a few basic principles to have a seamless DNS experience with Pi-hole and Fritz!Boxes.

!!! note
    There is no single way to do it right. Choose the one best fitting your needs.

### Enable advanced settings

Some of the following settings might be visible only if advanced settings are enabled. Therefore, "View" has to be changed to advanced by clicking on "Standard" in the lower left corner.

![Screenshot der Fritz!Box DHCP Einstellungen](../images/routers/fritzbox-advanced.png)

## Distribute Pi-hole as DNS server via DHCP

Using this configuration, all clients will get Pi-hole's IP offered as DNS server when they request a DHCP lease from your Fritz!Box.
DNS queries take the following path

```bash
Client -> Pi-hole -> Upstream DNS Server
```

!!! note
    The Fritz!Box itself will use whatever is configured in Internet/Account Information/DNS server (see below).
    The Fritz!Box can be Pi-hole's upstream DNS server, as long Pi-hole itself is not the upstream server of the Fritz!Box. This would cause a DNS loop.

To set it up, enter Pi-hole's IP as "Local DNS server" in

```bash
Home Network/Network/Network Settings/IP Addresses/IPv4 Configuration/Home Network
```

![Screenshot of Fritz!Box DHCP Settings](../images/routers/fritzbox-dhcp.png)

!!! warning
    Clients will notice changes in DHCP settings only after they acquired a new DHCP lease. The easiest way to force a renewal is to dis/reconnect the client from the network.

Now you should see individual clients in Pi-hole's web dashboard.


## Pi-hole as upstream DNS server for your Fritz!Box

With this configuration, Pi-hole is also used by the Fritz!Box itself as an upstream DNS server. DNS queries take the following path

```bash
(Clients) -> Fritz!Box -> Pi-hole -> Upstream DNS Server
```

To set it up, enter Pi-hole's IP as "Preferred DNSv4 server" **and** "Alternative DNSv4 server" in

```bash
Internet/Account Information/DNS server
```

![Screenshot of Fritz!Box WAN DNS Configuration](../images/routers/fritzbox-wan-dns.png)

!!! warning
    Don't set the Fritz!Box as upstream DNS server for Pi-hole if using this configuration! This will lead to a DNS loop as the Pi-hole will send the queries to the Fritz!Box which in turn will send them to Pi-hole.

If only this configuration is used, you won't see individual clients in Pi-hole's dashboard. For Pi-hole, all queries will appear as if they are coming from your Fritz!Box. You will therefore miss out on some features, e.g. Group Management. If you want to use them, Pi-hole must (additionally) be distributed to the clients as DNS server via DHCP (see above).

### Using Pi-hole within the Guest Network

There is no option to set the DNS server for the guest network in

```bash
Home Network/Network/Network Settings/IP Addresses/IPv4 Configuration/Guest Network
```

The Fritz!Box always sets its own IP as DNS server for the guest network. To filter its traffic, you have to setup Pi-hole as upstream DNS server for your Fritz!Box. As there is no other option, all DNS requests from your guest network will appear as coming from your Fritz!Box. Individual filtering per client within the guest network is therefore not possible.

## Hostnames instead of IP addresses in Pi-hole's web interface - Conditional forwarding

In case the Fritz!Box is used as DHCP server, client's hostnames are registered only there.  By default, Pi-hole tries to resolve the IP addresses of the clients back into host names. Therefore, the requests must reach the Fritz!Box.
There are two ways to do this:

* The Fritz!Box is the upstream DNS server of the Pi-hole. This means that all queries end up with the Fritz!Box anyway, which can send the host names back to Pi-hole.

!!! warning
    The Fritz!Box may only be the upstream DNS server of the Pi-hole if Pi-hole is not the upstream DNS server of the Fritz!Box. This would lead to a DNS loop.

* Only those queries are sent to the Fritz!Box that attempt to determine hostnames for IP addresses (clients) of the local network. All other requests are sent to the upstream DNS server of the Pi-Hole. The *Conditional forwarding* option is responsible for this.
The following settings must be made:
    * **Local network in CIDR notation:** Standard IP range of the  Fritz!Box is **192.168.178.0/24**
    * **IP address of your DHCP server (router):** IP of the Fritz!Box, standard is **192.168.178.1**
    * **Local domain name (optional):** Fritz!Box uses **fritz.box**

![Screenshot der Conditional Forwarding Einstellungen](../images/routers/conditional-forwarding.png)

## Distribute Pi-hole as DNS server via IPv6

Using this configuration, your Fritz!Box will offer Pi-hole's IPv6 as local DNS server to its clients via DHCPv6 as well as Router Advertisement (RA/RDNSS, SLAAC).

### Stable IPv6 address for your Pi-hole

The following section will help you picking a suitable IPv6 address of your Pi-hole.
To show all IPv6 addresses currently in use by your main network interface, open a terminal, substitute `eth0` with your main interface name (or omit) and execute the command

```bash
ip -6 address show eth0
```

The output should look like this but with different addresses

```bash
$ ip -6 address show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet6 fd6f:95dc:3a80:e9b1:503e:b05a:21dc:cf0c/64 scope global temporary dynamic
       valid_lft 7159sec preferred_lft 3559sec
    inet6 fd6f:95dc:3a80:e9b1:4bc3:7bff:fe67:c175/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 7159sec preferred_lft 3559sec
    inet6 2001:db8::1c5e:22fe:490c:1c31/64 scope global temporary dynamic
       valid_lft 7159sec preferred_lft 3559sec
    inet6 2001:db8::4bc3:7bff:fe67:c175/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 7159sec preferred_lft 3559sec
    inet6 fe80::4bc3:7bff:fe67:c175/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

When picking an IPv6 address from that list:

* avoid global unicast addresses (GUA) (range `2000::/3`)  
  Your ISP controls your GUA IPv6 prefix it, so it may change, either regularly or on router restarts.
  In this example, don't use the third and fourth address, starting with `2001:`
* avoid Privacy Extension (RFC 4941) addresses which are marked with `temporary`  
  The interface identifier portion of an IPv6 address is designed to change regularly, on some systems as often as every hour.
  In this example, avoid the first and the third address.
* prefer unique local addresses (ULA) (range `fd00::/8`) over the link-local address (range `fe80::/10`)  
  You can control the ULA prefix and it is static. The later is only valid on a link and cannot be routed.
  This can be fine for simple home networks, but will break once packets are routed (like Docker, some WiFi access points, L3 switches, ...).

In this example, these two addresses are usable; `fd6f:95dc:3a80:e9b1:4bc3:7bff:fe67:c175` and `fe80::4bc3:7bff:fe67:c175` (with care).

If your FritzBox doesn't issue an IPv6 ULA prefix yet, refer to the following step which helps you configure an ULA prefix.

### (Optional) Enable ULA addresses

Unique local addresses (ULA) are local IPv6 addresses which are not routed on the internet. They are comparable to the IPv4 private network ranges.

To enable ULA addresses, select "Always assign unique local addresses (ULA)" in

```bash
Home Network/Network/Network Settings/IP Addresses/IPv6 Addresses/Unique Local Addresses
```

> Note:
It is recommended to change the ULA prefix in order to prevent collisions with other networks.
You should generate the first 40 bits according to RFC4193 or use a simple online generator, like [unique-local-ipv6.com](https://www.unique-local-ipv6.com/).
The remaining 16 bits are the subnet id and are free to choose.  
Select "Set ULA prefix manually" and enter a custom prefix.

![Screenshot of Fritz!Box IPv6 Addresses Settings](../images/routers/fritzbox-ipv6-1.png)

To obtain the new address, reconnect or reboot your Pi-hole server.
Go back to the [previous step](#stable-ipv6-address-for-your-pi-hole) to display your newly created ULA address.

### Distribute Pi-hole as DNS server

It is now possible to enter Pi-hole's stable IPv6 address as "Local DNSv6 server" in

```bash
Home Network/Network/Network Settings/IP Addresses/IPv6 Addresses/DNSv6 Server in the Home Network
```

> Note:
It is recommended to select "Also announce DNSv6 server via router advertisement (RFC 5006)".

![Screenshot of Fritz!Box IPv6 Addresses Settings](../images/routers/fritzbox-ipv6-2.png)
