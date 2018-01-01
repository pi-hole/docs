###Hardware
Pi-hole is very lightweight, and does not require much processing power

- ~52MB of free space
- 512MB RAM

Despite the name, you are not limited to running Pi-hole on a Raspberry Pi. 
Any hardware that runs one of the supported operating systems will do! 

###Supported Operating Systems

The following operating systems are **officially** supported:

- Raspbian: Jessie / Stretch
- Ubuntu: 16.04 / 16.10
- Fedora: 26 / 27
- Debian: 8 / 9
- CentOS: 7 (not ARM)

###IP Addressing

Pi-hole needs a static IP address to properly function (a DHCP reservation is just fine).  Users may run into issues because **we currently install `dhcpcd5`, which may conflict with other running network managers** such as `dhclient`, `dhcpcd`, `networkmanager`, and `systemd-networkd`.  

As part of our install process, **we append some lines to `/etc/dhcpcd.conf` in order to statically assign an IP address**, so take note of this prior to installing. 

Please be aware of this fact because it [may cause confusion](https://github.com/pi-hole/pi-hole/issues/1713#issue-260746084).  This is not the ideal situation for us to be in, but since a significant portion of our users are running Pi-hole on Raspbian; and because Pi-hole's roots began with the Raspberry Pi, it's a problem that is [difficult problem to get away from](https://github.com/pi-hole/pi-hole/issues/1713#issuecomment-332317532).

Due to the complexity of different ways of setting an IP address across different systems, it's a slow process and [we need help](https://github.com/pi-hole/pi-hole/issues/629).  If you're willing to contribute, please let us know.

###Ports

We need ports _53_, _80_, and _4711_.  Port _80_ is optional if you decide not to install the Web dashboard during installation.

**Port 53 should be used by `dnsmasq`**
If you happen to have another DNS server running, such as BIND, you will need to turn it off in order for Pi-hole to respond to DNS queries.

**Port 80 should be used by `lighttpd`**
If you have another Web server already running, such as Apache, Pi-hole's Web server will not work.  You can either disable the other Web server or change the port on which `lighttpd` listens, which allows you keep both Web servers running.

**Port 4711 should be used by `pihole-FTL`**
FTL is our API engine and by default uses port 4711, but will increment if it's already in use by something else.
