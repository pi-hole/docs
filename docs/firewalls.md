### Required Ports

| Port (Protocol) | Reason           |
| --------------- | ---------------- |
| 53 (TCP/UDP)    | DNS Server       |
| 80 (TCP)        | Admin Interface  |
| 67 (UDP)        | DHCP IPv4 Server |
| 547 (UDP)       | DHCP IPv6 Server |
| 4711:4720 (TCP) | FTLDNS Server    |

### IPTables

IPTables uses two sets of tables. One set is for IPv4 chains, and the second is for IPv6 chains. If only IPv4 blocking is used for the Pi-hole installation, only apply the rules for IP4Tables. Full Stack (IPv4 and IPv6) require both sets of rules to be applied. *Note: These examples insert the rules at the front of the chain. Please see your distributions documentation to see the exact proper command to use.*

#### IP4Tables 

```bash
iptables -I INPUT 1 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT 1 -p tcp -m tcp --dport 53 -j ACCEPT
iptables -I INPUT 1 -p udp -m udp --dport 53 -j ACCEPT
iptables -I INPUT 1 -p udp -m tcp --dport 67 -j ACCEPT
iptables -I INPUT 1 -p udp -m udp --dport 67 -j ACCEPT
iptables -I INPUT 1 -p tcp -m tcp --dport 4711:4720 -i lo -j ACCEPT
```

#### IP6Tables

```bash
ip6tables -I INPUT -p udp -m udp --sport 546:547 --dport 546:547 -j ACCEPT
```

### firewallD

<TODO: Explain how to use FTLDNS with firewall-cmd>

```bash
firewall-cmd --permanent --add-service=http --add-service=dns --add-service=dhcp --add-service=dhcpv6
firewall-cmd --reload
```

