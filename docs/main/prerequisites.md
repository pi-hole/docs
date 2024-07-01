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

| Distribution | Release          | Architecture        |
| ------------ | ---------------- | ------------------- |
| Raspberry Pi OS <br>(formerly Raspbian)     | Buster / Bullseye | ARM                 |
| Armbian OS   | Any | ARM / x86_64 / riscv64           |
| Ubuntu       | 20.x / 22.x / 23.x / 24.x   | ARM / x86_64        |
| Debian       | 10 / 11 / 12         | ARM / x86_64 / i386 |
| Fedora       | 39 / 40     | ARM / x86_64        |
| CentOS Stream | 9            | x86_64              |

<!-- markdownlint-disable code-block-style -->
!!! info
    One of the first tasks the install script has is to determine your Operating System's compatibility with Pi-hole

    It is possible that Pi-hole will install and run on variants of the above, but we cannot test them all. If you are using an operating system not on this list you may see the following message:

    ```bash
    [✗] Unsupported OS detected: Debian 16
      If you are seeing this message and you do have a supported OS, please contact support.

      https://docs.pi-hole.net/main/prerequisites/#supported-operating-systems

      If you wish to attempt to continue anyway, you can try one of the following commands to skip this check:

      e.g: If you are seeing this message on a fresh install, you can run:
             curl -sSL https://install.pi-hole.net | sudo PIHOLE_SKIP_OS_CHECK=true bash

           If you are seeing this message after having run pihole -up:
             sudo PIHOLE_SKIP_OS_CHECK=true pihole -r
           (In this case, your previous run of pihole -up will have already updated the local repository)

      It is possible that the installation will still fail at this stage due to an unsupported configuration.
      If that is the case, you can feel free to ask the community on Discourse with the Community Help category:
      https://discourse.pi-hole.net/c/bugs-problems-issues/community-help/
    ```

    You can disable this check by setting an environment variable named `PIHOLE_SKIP_OS_CHECK` to `true`, however Pi-hole may have issues installing.
    If you choose to use this environment variable, please use the [Community Help](https://discourse.pi-hole.net/c/bugs-problems-issues/community-help/36) topic on Discourse to troubleshoot any installation issues you may (or may not!) have.

<!-- markdownlint-enable code-block-style -->

### IP Addressing

Pi-hole needs a static IP address to properly function (a DHCP reservation is just fine).

On systems that have `dhcpcd5` already installed (e.g Raspberry Pi OS) there is an option in the install process to append some lines to `/etc/dhcpcd.conf` in order to statically assign an IP address. This is an entirely optional step, and offered as a way to lower the barrier to entry for those that may not be familiar with linux systems, such as those first starting out on a Raspberry Pi.

### Ports

| Service             | Port         | Protocol | Notes               |
| --------------------|:-------------|:---------| --------------------|
| pihole-FTL             | 53  (DNS)    | TCP/UDP  | If you happen to have another DNS server running, such as BIND, you will need to turn it off in order for Pi-hole to respond to DNS queries. |
| pihole-FTL              | 67  (DHCP)   | IPv4 UDP | The DHCP server is an optional feature that requires additional ports. |
| pihole-FTL              | 547 (DHCPv6) | IPv6 UDP | The DHCP server is an optional feature that requires additional ports. |
| lighttpd            | 80  (HTTP)   | TCP      | If you have another Web server already running, such as Apache, Pi-hole's Web server will not work. You can either disable the other Web server or change the port on which `lighttpd` listens, which allows you keep both Web servers running. |
| pihole-FTL          | 4711    | TCP      | FTL is our API engine and uses port 4711 on the localhost interface. This port should not be accessible from any other interface.|

!!! info
    The use of lighttpd on port _80_ is optional if you decide not to install the Web dashboard during installation.
    The use of pihole-FTL on ports _67_ or _547_ is optional, but required if you use the DHCP functions of Pi-hole.

### Firewalls

Below are some examples of firewall rules that will need to be set on your Pi-hole server in order to use the functions available. These are only shown as guides, the actual commands used will be found with your distribution's documentation.
Because Pi-hole was designed to work inside a local network, the following rules will block the traffic from the Internet for security reasons. `192.168.0.0/16` is the most common local network IP range for home users but it can be different in your case, for example other common local network IPs are `10.0.0.0/8` and `172.16.0.0/12`.

**Check your local network settings before applying these rules.**

#### IPTables

IPTables uses two sets of tables. One set is for IPv4 chains, and the second is for IPv6 chains. If only IPv4 blocking is used for the Pi-hole installation, only apply the rules for IP4Tables. Full Stack (IPv4 and IPv6) require both sets of rules to be applied. _Note: These examples insert the rules at the front of the chain. Please see your distribution's documentation for the exact proper command to use._

IPTables (IPv4)

```bash
iptables -I INPUT 1 -s 192.168.0.0/16 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT 1 -s 127.0.0.0/8 -p tcp -m tcp --dport 53 -j ACCEPT
iptables -I INPUT 1 -s 127.0.0.0/8 -p udp -m udp --dport 53 -j ACCEPT
iptables -I INPUT 1 -s 192.168.0.0/16 -p tcp -m tcp --dport 53 -j ACCEPT
iptables -I INPUT 1 -s 192.168.0.0/16 -p udp -m udp --dport 53 -j ACCEPT
iptables -I INPUT 1 -p udp --dport 67:68 --sport 67:68 -j ACCEPT
iptables -I INPUT 1 -p tcp -m tcp --dport 4711 -i lo -j ACCEPT
iptables -I INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

IP6Tables (IPv6)

```bash
ip6tables -I INPUT -p udp -m udp --sport 546:547 --dport 546:547 -j ACCEPT
ip6tables -I INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

#### FirewallD

Using the `--permanent` argument will ensure the firewall rules persist reboots. If only IPv4 blocking is used for the Pi-hole installation, the `dhcpv6` service can be removed from the commands below. Create a new zone for the local interface (`lo`) for the pihole-FTL ports to ensure the API is only accessible locally. Finally `--reload` to have the new firewall configuration take effect immediately.

```bash
firewall-cmd --permanent --add-service=http --add-service=dns --add-service=dhcp --add-service=dhcpv6
firewall-cmd --permanent --new-zone=ftl
firewall-cmd --permanent --zone=ftl --add-interface=lo
firewall-cmd --permanent --zone=ftl --add-port=4711/tcp
firewall-cmd --reload
```

#### ufw

ufw stores all rules persistent, so you just need to execute the commands below.

IPv4:

```bash
ufw allow 80/tcp
ufw allow 53/tcp
ufw allow 53/udp
ufw allow 67/tcp
ufw allow 67/udp
```

IPv6 (include above IPv4 rules):

```bash
ufw allow 546:547/udp
```
