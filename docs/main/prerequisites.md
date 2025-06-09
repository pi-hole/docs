---
title: Prerequisites
description: Operating system and network requirements
last_updated: May 25 2020
---

### Hardware

Pi-hole is very lightweight and does not require much processing power

- Min. 2GB free space, 4GB recommended
- 512MB RAM

!!! info
    A Pi-hole branded kit, including everything you need to get started, can be purchased from The Pi Hut, [here](https://thepihut.com/products/official-pi-hole-raspberry-pi-4-kit).

Despite the name, you are not limited to running Pi-hole on a Raspberry Pi.
Any hardware that runs one of the supported operating systems will do!

### Software

Pi-hole is supported on distributions utilizing [systemd](https://systemd.io/) or [sysvinit](https://www.nongnu.org/sysvinit/)!

#### Supported Operating Systems

The following operating systems are **officially** supported:

- Raspberry Pi OS (formerly Raspbian)
- Armbian OS
- Ubuntu
- Debian
- Fedora
- CentOS Stream

Pi-hole only supports actively maintained versions of these systems.

<!-- markdownlint-disable code-block-style -->
!!! info
    Pi-hole may be able to install and run on variants of the above, but we cannot test all of them.
    It's possible that that the installation may still fail due to an unsupported configuration or specific OS version.

    Also, if you are using an operating system not on this list Pi-hole may not work.

<!-- markdownlint-enable code-block-style -->

### IP Addressing

Pi-hole needs a static IP address to properly function (a DHCP reservation is just fine).

### Ports

| Service             | Port         | Protocol | Notes               |
| --------------------|:-------------|:---------| --------------------|
| pihole-FTL          | 53  (DNS)    | TCP/UDP  | If you happen to have another DNS server running, such as BIND, you will need to turn it off in order for Pi-hole to respond to DNS queries. |
| pihole-FTL          | 67  (DHCP)   | IPv4 UDP | The DHCP server is an optional feature that requires additional ports. |
| pihole-FTL          | 547 (DHCPv6) | IPv6 UDP | The DHCP server is an optional feature that requires additional ports. |
| pihole-FTL          | 80  (HTTP)<br/>443   (HTTPS)    | TCP      | If you have another webserver already listening on port `80`/`443`, then `pihole-FTL` will attempt to bind to `8080`/`8443` instead. If neither of these ports are available, `pihole-FTL`'s webserver will be unavailable until ports are configured manually (see configuration option `webserver.port`)  |
| pihole-FTL          | 123 (NTP)    | UDP      | The NTP server is an optional feature that requires an additional port. |

!!! info
    The use of pihole-FTL on ports _67_ or _547_ is optional, but required if you use the DHCP functions of Pi-hole.
    The use of port _123_ is required when using pihole-FTL as NTP-Server.

### Firewalls

Below are some examples of firewall rules that will need to be set on your Pi-hole server in order to use the functions available. These are only shown as guides, the actual commands used will be found with your distribution's documentation.
Because Pi-hole was designed to work inside a local network, the following rules will block the traffic from the Internet for security reasons. `192.168.0.0/16` is the most common local network IP range for home users but it can be different in your case, for example other common local network IPs are `10.0.0.0/8` and `172.16.0.0/12`.

**Check your local network settings before applying these rules.**

#### IPTables

IPTables uses two sets of tables. One set is for IPv4 chains, and the second is for IPv6 chains. If only IPv4 blocking is used for the Pi-hole installation, only apply the rules for IP4Tables. Full Stack (IPv4 and IPv6) require both sets of rules to be applied. _Note: These examples insert the rules at the front of the chain. Please see your distribution's documentation for the exact proper command to use._

IPTables (IPv4)

```bash
iptables -I INPUT 1 -s 192.168.0.0/16 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT 1 -s 192.168.0.0/16 -p tcp -m tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -s 127.0.0.0/8 -p tcp -m tcp --dport 53 -j ACCEPT
iptables -I INPUT 1 -s 127.0.0.0/8 -p udp -m udp --dport 53 -j ACCEPT
iptables -I INPUT 1 -s 192.168.0.0/16 -p tcp -m tcp --dport 53 -j ACCEPT
iptables -I INPUT 1 -s 192.168.0.0/16 -p udp -m udp --dport 53 -j ACCEPT
iptables -I INPUT 1 -p udp --dport 67:68 --sport 67:68 -j ACCEPT
iptables -I INPUT 1 -p udp --dport 123 -j ACCEPT
iptables -I INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

IP6Tables (IPv6)

```bash
ip6tables -I INPUT -p udp -m udp --sport 546:547 --dport 546:547 -j ACCEPT
ip6tables -I INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

#### FirewallD

Using the `--permanent` argument will ensure the firewall rules persist reboots. If only IPv4 blocking is used for the Pi-hole installation, the `dhcpv6` service can be removed from the commands below. Finally `--reload` to have the new firewall configuration take effect immediately.

```bash
firewall-cmd --permanent --add-service=http --add-service=https --add-service=dns --add-service=dhcp --add-service=dhcpv6 --add-service=ntp
firewall-cmd --reload
```

#### ufw

ufw stores all rules persistent, so you just need to execute the commands below.

IPv4:

```bash
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 53/tcp
ufw allow 53/udp
ufw allow 67/tcp
ufw allow 67/udp
ufw allow 123/udp
```

IPv6 (include above IPv4 rules):

```bash
ufw allow 546:547/udp
```
