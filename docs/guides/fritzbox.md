**This is an unsupported configuration created by the community**

This guide was developed using a FritzBox 7530 but should work for others too. It aims to line out a few basic prinicples to have a seemless DNS experience with Pihole and Fritzboxes .

> Note:
There is no single way to do it right. Choose the one best fitting your needs.
This guide is IPv4 only. You need to adjust for IPv6 accordingly

## 1) Using Pihole as upstream DNS server for your Fritzbox

Using this configuration, Pihole is used for all devices within your network including the FritzBox itself. DNS requests are send in this order

```bash
Client -> FritzBox -> Pihole -> Upstream DNS Server
```

To set it up, enter Pihole's IP as "Bevorzugter DNS-Server" **and** "Alternativer DNS-Server" in

```bash
Internet/Zugangsdaten/DNS-Server
```

!!! warning
    Don't set the FitzBox as upstrem DNS server for pihole! This will lead to a DNS loop as the Pihole will send the queries to the Fritzbox which in turn will send the to Pihole.

With this configuration, you won't see individual clients in pihole's dashboard. For pihole, all queries will appear as if they are comming from your FitzBox. You will therefore miss out some features, e.g. Group Management. This can be solved using method #2.


## 2) Distribute Pihole as DNS server via DHCP

Using this configuration, all clients will get Pihole's IP offered as DNS server when they request a DHCP lease from your FritzBox.
DNS requests are send in this order

```bash
Client -> Pihole -> Upstream DNS Server
```

> Note:
The FritzBox itself will use whatever is configured under Internet/Zugangsdaten/DNS-Server.
The FritzBox can be Pihole's upstream DNS server, as long Pihole itself is not the the upstream server for the Fritzbox. This would  cause a DNS loop.

To set it up, enter Pihole's IP as "Lokaler DNS-Server" in

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration
```

You should see individual clients in Pihole's web dashboard.

## 3) Combining 1) and 2)

You can combine 1) and 2) which will let all clients  send DNS requests to your Pihole **and** the Fritzbox itself as well.

```bash
Client (incl. FritzBox) -> Pihole -> Upstream DNS Server
```

!!! warning
    Don't set the FitzBox as upstrem DNS server for pihole! This will lead to a DNS loop as the Pihole will send the queries to the Fritzbox which in turn will send the to Pihole

## Using Pihole within the Guest Network

You may have noticed, that there is no option to set the DNS server for the guest network in

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration
```

The FritzBox always set its own IP as DNS server for  the guest network. To filter its traffic, you have to setup Pihole as upstream DNS server for your FitzBox (see #1). As there is no other option, all DNS requests from your guest network will appear as coming from your FritzBox.
