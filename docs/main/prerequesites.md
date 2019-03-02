### Hardware
Pi-hole is very lightweight, and does not require much processing power

- ~52MB of free space
- 512MB RAM

Despite the name, you are not limited to running Pi-hole on a Raspberry Pi.
Any hardware that runs one of the supported operating systems will do!

### Supported Operating Systems

The following operating systems are **officially** supported:

- Raspbian: Jessie / Stretch
- Ubuntu: 16.04 / 16.10
- Fedora: 28 / 29
- Debian: 8 / 9
- CentOS: 7 (not ARM)

### IP Addressing

Pi-hole needs a static IP address to properly function (a DHCP reservation is just fine).  Users may run into issues because **we currently install `dhcpcd5`, which may conflict with other running network managers** such as `dhclient`, `dhcpcd`, `networkmanager`, and `systemd-networkd`.

As part of our install process, **we append some lines to `/etc/dhcpcd.conf` in order to statically assign an IP address**, so take note of this prior to installing.

Please be aware of this fact because it [may cause confusion](https://github.com/pi-hole/pi-hole/issues/1713#issue-260746084).  This is not the ideal situation for us to be in, but since a significant portion of our users are running Pi-hole on Raspbian; and because Pi-hole's roots began with the Raspberry Pi, it's a problem that is [difficult problem to get away from](https://github.com/pi-hole/pi-hole/issues/1713#issuecomment-332317532).

Due to the complexity of different ways of setting an IP address across different systems, it's a slow process and [we need help](https://github.com/pi-hole/pi-hole/issues/629).  If you're willing to contribute, please let us know.

### Ports

| Service             | Port         | Protocol | Notes               |
| --------------------|:-------------|:---------| --------------------|
| dnsmasq             | 53  (DNS)    | TCP/UDP  | If you happen to have another DNS server running, such as BIND, you will need to turn it off in order for Pi-hole to respond to DNS queries. |
| dnsmasq             | 67  (DHCP)   | IPv4 UDP | The DHCP server is an optional feature that requires additional ports. |
| dnsmasq             | 547 (DHCPv6) | IPv6 UDP | The DHCP server is an optional feature that requires additional ports. |
| lighttpd            | 80  (HTTP)   | TCP      | If you have another Web server already running, such as Apache, Pi-hole's Web server will not work.  You can either disable the other Web server or change the port on which `lighttpd` listens, which allows you keep both Web servers running. |
| pihole-FTL          | 4711    | TCP      | FTL is our API engine and uses port 4711 on the localhost interface.  This port should not be accessible from any other interface.|

!!! info
    The use of lighttpd on port _80_ is optional if you decide not to install the Web dashboard during installation.
    The use of dnsmasq on ports _67_ or _547_ is optional, but required if you use the DHCP functions of Pi-hole.

### Firewalls

Below are some examples of firewall rules that will need to be set on your Pi-hole server in order to use the functions available. These are only shown as guides, the actual commands used will be found with your distributions documentation.

#### IPTables

IPTables uses two sets of tables. One set is for IPv4 chains, and the second is for IPv6 chains. If only IPv4 blocking is used for the Pi-hole installation, only apply the rules for IP4Tables. Full Stack (IPv4 and IPv6) require both sets of rules to be applied. *Note: These examples insert the rules at the front of the chain. Please see your distributions documentation to see the exact proper command to use.*

IPTables (IPv4)

```bash
iptables -I INPUT 1 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT 1 -p tcp -m tcp --dport 53 -j ACCEPT
iptables -I INPUT 1 -p udp -m udp --dport 53 -j ACCEPT
iptables -I INPUT 1 -p udp -m tcp --dport 67 -j ACCEPT
iptables -I INPUT 1 -p udp -m udp --dport 67 -j ACCEPT
iptables -I INPUT 1 -p tcp -m tcp --dport 4711 -i lo -j ACCEPT
```
IP6Tables (IPv6)

```bash
ip6tables -I INPUT -p udp -m udp --sport 546:547 --dport 546:547 -j ACCEPT
```
#### FirewallD

Using the `--permanent` argument will ensure the firewall rules persist reboots. If only IPv4 blocking is used for the Pi-hole installation, the `dhcpv6` service can be removed the the commands below. Create a new zone for the local interface (`lo`) for the pihole-FTL ports to ensure the API is only accessible locally. Finally `--reload` to have the new firewall configuration take effect immediately.

```bash
firewall-cmd --permanent --add-service=http --add-service=dns --add-service=dhcp --add-service=dhcpv6
firewall-cmd --permanent --new-zone=ftl
firewall-cmd --permanent --zone=ftl --add-interface=lo
firewall-cmd --permanent --zone=ftl --add-port=4711/tcp
firewall-cmd --reload
```
{!abbreviations.md!}
