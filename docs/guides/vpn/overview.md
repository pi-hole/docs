>This tutorial is tailored for setting up OpenVPN on a cloud-hosted virtual server (such as [Digital Ocean](http://www.digitalocean.com/?refcode=344d234950e1)). If you wish to have this working on your home network, you will need to tailor Pi-hole to listen on `eth0` (or similar), which we explain in [this section of the tutorial](dual-operation.md).

# High-level Overview
Using a VPN is a responsible, respectful, and safe way to access your Pi-hole's capabilities remotely.  Setting up a DNS server has become a simple task with Pi-hole's automated installer, which has resulted in many people knowingly--or unknowingly--creating an open resolver, which aids in DNS Amplification Attacks.

We do not encourage open resolvers but there are always people wanting access to their ad-blocking capabilities outside of their home network, whether it's on their cellular network or on an unsecured wireless network.  This article aims to provide a step-by-step walk-through on setting up a server running Pi-hole and OpenVPN so you can connect to your Pi-hole's DNS from anywhere.  This guide should work for a private server installed on your private network, but it will also work for cloud servers, such as those created on [Digital Ocean](http://www.digitalocean.com/?refcode=344d234950e1).

**This tutorial walks you through the installation of Pi-hole combined with an VPN server for secure access from remote clients**.  Via this VPN, you can:

- use the DNS server and full filtering capabilities of your Pi-hole from everywhere around the globe
- access your admin interface remotely
- encrypt your Internet traffic

If you don't want a full-tunnel, we provide a wiki of how to [set up your server to exclusively route DNS traffic, but nothing else via the VPN](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Only-route-DNS-via-VPN).  On another optional page, we describe how to set up Pi-hole + VPN in such a way that it is [usable both locally (no VPN) and from remote (through VPN)](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Dual-operation:-LAN-&-VPN-at-the-same-time), while preserving full functionality.

## End Result

You will have access to a VPN that uses Pi-hole for DNS and tunnels some or all of your network traffic

1. [Install OpenVPN + Pi-hole](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Installation)
2. [Configure OpenVPN to use Pi-hole for DNS queries](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Setup-OpenVPN-server)
3. [Configure your client devices](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Connect-from-a-client)
4. [(optional) Secure the server with firewall rules (`iptables`)](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Firewall-configuration-(using-iptables))
5. [(optional) Route _only_ DNS via the VPN](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Only-route-DNS-via-VPN)
6. [(optional) Dual operation: simultaneous LAN and VPN](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Dual-operation:-LAN-&-VPN-at-the-same-time)
7. [(optional) Set up Dynamic DNS host name](https://github.com/pi-hole/pi-hole/wiki/Set-up-a-dynamic-DNS-host-name)

---
>Note that this manual is partially based on this [HowTo](https://discourse.pi-hole.net/t/pi-hole-with-openvpn-vps-debian/861) on [Discourse](https://discourse.pi-hole.net).
