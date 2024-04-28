{!guides/vpn/openvpn/deprecation_notice.md!}

### (optional) Secure the server with firewall rules (`iptables`)

**If you are behind a NAT and not running the Pi-hole on a cloud server, you do not need to issue the IPTABLES commands below as the firewall rules are already handled by the RoadWarrior installer, but you will need to portforward whatever port you chose in the setup from your public ip to your device using your router.**

**This step is optional but recommended if you are running your server in the cloud, such as a droplet made on [Digital Ocean](https://www.digitalocean.com/?refcode=344d234950e1)**. If this is the case, you need to secure the server for your safety as well as others to prevent aiding in DDoS attacks.

In addition to the risk of being an open resolver, your Web interface is also open to the world increasing the risk. So you will want to prevent ports 53 and 80, respectively, from being accessible from the public Internet.

It's recommended that you [clear out your entire firewall](https://serverfault.com/questions/200635/best-way-to-clear-all-iptables-rules) so you have full control over its setup. You have two options for setting up your firewall with your VPN.

#### Option 1: Allow everything from within your VPN

Enter this command, which will allow all traffic through the VPN `tun0` interface.

```bash
iptables -I INPUT -i tun0 -j ACCEPT
```

#### Option 2: Explicitly allow what can be accessed within the VPN

These commands will allow DNS and HTTP needed for name resolution (using Pi-hole as a resolver) and accessing the Web interface, respectively.

```bash
iptables -A INPUT -i tun0 -p tcp --destination-port 53 -j ACCEPT
iptables -A INPUT -i tun0 -p udp --destination-port 53 -j ACCEPT
iptables -A INPUT -i tun0 -p tcp --destination-port 80 -j ACCEPT
```

You will also want to enable SSH and VPN access from anywhere.

```bash
iptables -A INPUT -p tcp --destination-port 22 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 1194 -j ACCEPT
iptables -A INPUT -p udp --destination-port 1194 -j ACCEPT
```

The next crucial setting is to explicitly allow TCP/IP to do "three-way handshakes":

```bash
iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
```

Also, we want to allow any loopback traffic, i.e. the server is allowed to talk to itself without any limitations using 127.0.0.0/8:

```bash
iptables -I INPUT -i lo -j ACCEPT
```

Finally, reject access from anywhere else (i.e. if no rule has matched up to this point):

```bash
iptables -P INPUT DROP
```

##### Blocking HTTPS advertisement assets

Since you're `:head-desk:`ing with `iptables`, you can also use this opportunity to block HTTPS advertisements to [improve blocking ads that are loaded via HTTPS](https://discourse.pi-hole.net/t/why-do-some-sites-take-forever-to-load-when-using-pi-hole-for-versions-v4-0/3654/4) and also deal with QUIC.

> Why doesn't Pi-hole just use a certificate to prevent this?  The answer is [here](https://discourse.pi-hole.net/t/slow-loading-websites/3408/12).

```bash
iptables -A INPUT -p udp --dport 80 -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp --dport 443 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp --dport 443 -j REJECT --reject-with icmp-port-unreachable
```

Depending on the systems you have connecting, you may benefit from appending `--reject-with tcp-reset` to the command above. If you still get slow load times of HTTPS assets, the above may help.

##### IPv6 `iptables`

If your server is reachable via IPv6, you'll need to run the same commands but using `ip6tables`:

```bash
ip6tables -A INPUT -i tun0 -p tcp --destination-port 53 -j ACCEPT
ip6tables -A INPUT -i tun0 -p udp --destination-port 53 -j ACCEPT
ip6tables -A INPUT -i tun0 -p tcp --destination-port 80 -j ACCEPT
ip6tables -A INPUT -p tcp --destination-port 22 -j ACCEPT
ip6tables -A INPUT -p tcp --destination-port 1194 -j ACCEPT
ip6tables -A INPUT -p udp --destination-port 1194 -j ACCEPT
ip6tables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -I INPUT -i lo -j ACCEPT
ip6tables -A INPUT -p udp --dport 80 -j REJECT --reject-with icmp6-port-unreachable
ip6tables -A INPUT -p tcp --dport 443 -j REJECT --reject-with tcp-reset
ip6tables -A INPUT -p udp --dport 443 -j REJECT --reject-with icmp6-port-unreachable
ip6tables -P INPUT DROP
```

View the rules you just created

```bash
iptables -L --line-numbers
```

and they should look something like this:

```text
Chain INPUT (policy DROP)
num  target     prot opt source               destination
1    ACCEPT     all  --  anywhere             anywhere
2    ACCEPT     all  --  anywhere             anywhere             state RELATED,ESTABLISHED
3    ACCEPT     all  --  anywhere             anywhere
4    ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:domain
5    ACCEPT     udp  --  anywhere             anywhere             udp dpt:domain
6    ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
7    ACCEPT     udp  --  anywhere             anywhere             udp dpt:80
8    ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh
9    ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:openvpn
10   ACCEPT     udp  --  anywhere             anywhere             udp dpt:openvpn
11   ACCEPT     tcp  --  10.8.0.0/24          anywhere             tcp dpt:domain
12   ACCEPT     udp  --  10.8.0.0/24          anywhere             udp dpt:domain
13   ACCEPT     tcp  --  10.8.0.0/24          anywhere             tcp dpt:http
14   ACCEPT     udp  --  10.8.0.0/24          anywhere             udp dpt:80
15   ACCEPT     tcp  --  10.8.0.0/24          anywhere             tcp dpt:domain
16   ACCEPT     tcp  --  10.8.0.0/24          anywhere             tcp dpt:http
17   ACCEPT     udp  --  10.8.0.0/24          anywhere             udp dpt:domain
18   ACCEPT     udp  --  10.8.0.0/24          anywhere             udp dpt:80
19   REJECT     tcp  --  anywhere             anywhere             tcp dpt:https reject-with icmp-port-unreachable

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination
```

Similarly, `ip6tables -L --line-numbers` should look like this:

```text
Chain INPUT (policy DROP)
num  target     prot opt source               destination
1    ACCEPT     all      anywhere             anywhere
2    ACCEPT     all      anywhere             anywhere             state RELATED,ESTABLISHED
3    ACCEPT     tcp      anywhere             anywhere             tcp dpt:domain
4    ACCEPT     udp      anywhere             anywhere             udp dpt:domain
5    ACCEPT     tcp      anywhere             anywhere             tcp dpt:http
6    ACCEPT     udp      anywhere             anywhere             udp dpt:80
7    ACCEPT     tcp      anywhere             anywhere             tcp dpt:ssh
8    ACCEPT     tcp      anywhere             anywhere             tcp dpt:openvpn
9    ACCEPT     udp      anywhere             anywhere             udp dpt:openvpn
10   REJECT     tcp      anywhere             anywhere             tcp dpt:https reject-with icmp6-port-unreachable

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination
```

##### Verify the rules are working

Connect to the VPN as a client and verify you can resolve DNS names as well as access the Pi-hole Web interface. These settings are stored in memory until you save them. If it's not working, you can restart your server to start from scratch. Alternatively, you could also go through and delete lines with `iptables -D INPUT <SOME LINE NUMBER>`

#### Save your `iptables`

If things look good, you may want to save your rules so you can revert to them if you ever make changes to the firewall. Save them with these commands:

```bash
iptables-save > /etc/pihole/rules.v4
ip6tables-save > /etc/pihole/rules.v6
```

Similarly, you can restore these rules:

```bash
iptables-restore < /etc/pihole/rules.v4
ip6tables-restore < /etc/pihole/rules.v6
```
