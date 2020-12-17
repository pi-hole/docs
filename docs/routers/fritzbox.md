This guide was developed using FRITZ!OS 07.21 but should work for others too. It aims to line out a few basic principles to have a seamless DNS experience with Pi-hole and Fritz!Boxes .

> Note:
There is no single way to do it right. Choose the one best fitting your needs.
This guide is IPv4 only. You need to adjust for IPv6 accordingly

## 1) Using Pi-hole as upstream DNS server for your Fritz!Box

Using this configuration, Pi-hole is used for all devices within your network including the Fritz!Box itself. DNS requests are sent in this order

```bash
Client -> Fritz!Box -> Pi-hole -> Upstream DNS Server
```

To set it up, enter Pi-hole's IP as "Preferred DNS server" **and** "Alternative DNS server" in

```bash
Internet/Account Information/DNS server
```

![Screenshot of Fritz!Box WAN DNS Configuration](../images/fritzbox-wan-dns.png)

!!! warning
    Don't set the Fitz!Box as upstrem DNS server for Pi-hole! This will lead to a DNS loop as the Pi-hole will send the queries to the Fritz!Box which in turn will send the to Pi-hole.

With this configuration, you won't see individual clients in Pi-hole's dashboard. For Pi-hole, all queries will appear as if they are coming from your Fritz!Box. You will therefore miss out on some features, e.g. Group Management. This can be solved using method #2.


## 2) Distribute Pi-hole as DNS server via DHCP

Using this configuration, all clients will get Pi-hole's IP offered as DNS server when they request a DHCP lease from your Fritz!Box.
DNS requests are sent in this order

```bash
Client -> Pi-hole -> Upstream DNS Server
```

> Note:
The Fritz!Box itself will use whatever is configured in Internet/Account Information/DNS server.
The Fritz!Box can be Pi-hole's upstream DNS server, as long Pi-hole itself is not the upstream server for the Fritz!Box. This would  cause a DNS loop.

To set it up, enter Pi-hole's IP as "Local DNS server" in

```bash
Home Network/Network/Network Settings/IP Adresses/IPv4 Configuration/Home Network
```

![Screenshot of Fritz!Box DHCP Settings](../images/fritzbox-dhcp.png)

>Note:
Clients will notice changes in DHCP settings only after they acquire a new DHCP lease. The easiest way to force a renewal is to dis/reconnect the client from the network.

You should see individual clients in Pi-hole's web dashboard.

## 3) Combining 1) and 2)

You can combine 1) and 2) which will let all clients  send DNS requests to your Pi-hole **and** the Fritz!Box itself as well.

```bash
Client (incl. Fritz!Box) -> Pi-hole -> Upstream DNS Server
```

!!! warning
    Don't set the Fritz!Box as upstrem DNS server for Pi-hole! This will lead to a DNS loop as the Pi-hole will send the queries to the Fritz!Box which in turn will send the to Pi-hole

## Using Pi-hole within the Guest Network

You may have noticed, that there is no option to set the DNS server for the guest network in

```bash
Home Network/Network/Network Settings/IP Adresses/IPv4 Configuration/Guest Network
```

The Fritz!Box always sets its own IP as DNS server for  the guest network. To filter its traffic, you have to setup Pi-hole as upstream DNS server for your Fritz!Box (see #1). As there is no other option, all DNS requests from your guest network will appear as coming from your Fritz!Box.
