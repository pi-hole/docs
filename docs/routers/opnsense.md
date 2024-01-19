This guide was developed using OPNsense 23.7.12, but should work for others too.

!!! note There is no single way to do it right. Choose the one best fitting your needs.

### Using PiHole as a global DNS server

This sets up PiHole as your global DNS server. Unless manually configured otherwise, all devices on your network will use PiHole as their DNS server.

1. In PiHole, navigate to `Settings -> DNS` and ensure you have at least one external upstream DNS server enabled.

   **Do not use your OPNsense IP address as this will cause a circular dependancy.**

2. In OPNsense navigate to `Settings -> General -> Networking`.
3. Under DNS Servers, enter the IPv4 address of your PiHole server, and set the gateway to your WAN interface.
4. Uncheck `Allow DNS server list to the overridden by DHCP/PPP on WAN`.
5. Click Save.

### Using PiHole as a DNS server for a single interface

You can set up custom DNS servers to use per local interface. For instance, you might want to use PiHole on your LAN, but not on your Guest Wifi network.

1. In PiHole, navigate to `Settings -> DNS`. You should either have at least one external DNS server configured, or have your OPNsense IP address set as an external DNS server.
2. In OPNsense, navigate to `Services -> DHCPv4 -> [<YOUR INTERFACE>]`
3. Under DNS servers, remove any other IP addresses and add your PiHole server's IP address to the list.
4. Click Save
5. You will also need to ensure that clients connected to that interface can communicate with PiHole by adding a relevant firewall entry.
