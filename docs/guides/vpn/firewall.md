### Optional: Firewall configuration (using iptables)
If your server is visible to the world, you will want prevent port 53/80 from being accessible from the global Internet. You will want be only able to connect to your Pi-hole from within the VPN.

Using `iptables`: First, verify that there is no rule that explicitly accepts `http` requests
```
sudo iptables -L --line-numbers
```

If you get something like
<pre>
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
<b>1    ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http</b>
2    ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:domain
3    ACCEPT     udp  --  anywhere             anywhere             udp dpt:domain

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination
</pre>
you have to first explicitly delete the first INPUT rule using:
```
sudo iptables -D INPUT 1
```

We recommend that you empty out the firewall so you have full control over its setup.

For setting up your firewall in conjunction with your VPN you have **TWO** options:

Option 1: Allow everything within your VPN:
```
sudo iptables -I INPUT -i tun0 -j ACCEPT
```
or

Option 2: Explicitly allow what can be accessed from within the VPN:
```
sudo iptables -A INPUT -i tun0 -p tcp --destination-port 53 -j ACCEPT
sudo iptables -A INPUT -i tun0 -p udp --destination-port 53 -j ACCEPT
sudo iptables -A INPUT -i tun0 -p tcp --destination-port 80 -j ACCEPT
sudo iptables -A INPUT -i tun0 -p udp --destination-port 80 -j ACCEPT
```

Obviously, it is important to enable SSH and VPN access from anywhere
```
sudo iptables -A INPUT -p tcp --destination-port 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 1194 -j ACCEPT
sudo iptables -A INPUT -p udp --destination-port 1194 -j ACCEPT
```

The next crucial setting is to explicitly allow TCP/IP to do "three way handshakes":
```
sudo iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
```

Also, we want to allow any loopback traffic, i.e. the Pi is allowed to talk to itself without any limitations using `127.0.0.0/8`:
```
sudo iptables -I INPUT -i lo -j ACCEPT
```

Finally, prevent access from anywhere else (i.e. if no rule has matched up to this point):
```
sudo iptables -P INPUT DROP
```

Optional: If you want to allow access to the Pi-hole from within the VPN *and* from the local network, you will have to explicitly allow your local network as well (assuming the local network is within the address space 192.168.**178**.1 - 192.168.**178**.254):
<pre>
sudo iptables -A INPUT -s 192.168.<b>178</b>.0/24 -p tcp --destination-port 53 -j ACCEPT
sudo iptables -A INPUT -s 192.168.<b>178</b>.0/24 -p udp --destination-port 53 -j ACCEPT
sudo iptables -A INPUT -s 192.168.<b>178</b>.0/24 -p tcp --destination-port 80 -j ACCEPT
sudo iptables -A INPUT -s 192.168.<b>178</b>.0/24 -p udp --destination-port 80 -j ACCEPT
</pre>
See also [this](https://discourse.pi-hole.net/t/pihole-vpn-with-iptables/2384) thread on Discourse.

---
### Optional: IPv6

Note that you will have to repeat the firewall setup using `ip6tables` if your server is also reachable via IPv6:

```
sudo ip6tables -A INPUT -i tun0 -p tcp --destination-port 53 -j ACCEPT
sudo ip6tables -A INPUT -i tun0 -p tcp --destination-port 80 -j ACCEPT
sudo ip6tables -A INPUT -i tun0 -p udp --destination-port 53 -j ACCEPT
sudo ip6tables -A INPUT -i tun0 -p udp --destination-port 80 -j ACCEPT
sudo ip6tables -A INPUT -p tcp --destination-port 22 -j ACCEPT
sudo ip6tables -A INPUT -p tcp --destination-port 1194 -j ACCEPT
sudo ip6tables -A INPUT -p udp --destination-port 1194 -j ACCEPT
sudo ip6tables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo ip6tables -I INPUT -i lo -j ACCEPT
sudo ip6tables -P INPUT DROP
```