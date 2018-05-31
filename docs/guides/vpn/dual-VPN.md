If you however want to run two VPN servers, one that routes the traffic and one that answers only to DNS requests, you would have to create another instance of OpenVPN.

Why would you want to do this?

Because DNS is restricted to port 53 only, you cannot use it as your own DNS outside your network unless you make it public and making a DNS server a public server, is not always the best idea and it comes with some risks.

So why not use the VPN tunnel to answer to DNS queries only? No traffic goes through it, except for the DNS queries, that are answered (and tracked if you have the Admin interface installed) by your Pi-hole.

You can even use the same .ovpn file, with minor modifications (no need to generate it again).

We're going to use the original configuration file and copy it and then, edit the second file:

sudo cp /etc/openvpn/server.conf /etc/openvpn/server2.conf sudo nano /etc/openvpn/server2.conf

We'll need to change the port to a diferent one from the original, so that it does not conflict with the first instance of OpenVPN

Assuming you used default port configuration, you should have 1194 as the port. You need to change this do a different value (make sure the port is available - 1195 should be) and if needed, port forward it from your router into your device. You also need to assign a different class of IPs that will server for this connection only (server line).

`server 10.9.0.0 255.255.255.0` 

And make sure that the DNS requests go though the instance of OpenVPN: push "dhcp-option DNS 10.9.0.1"

One other setting that we need to change is comment out (the already existing line) `# push "redirect-gateway def1 bypass-dhcp"`.
Save the file and run the second instance of VPN:

`systemctl start openvpn@server2.service`

If your distro doesn’t have “Systemctl” you may use commands like below to start your OpenVPN with your second configuration as a daemon: 
`/usr/sbin/openvpn --daemon --writepid /var/run/openvpn/server2.pid --cd /etc/openvpn --config server2.conf --script-security 2`

The next step is to edit the exisitng .ovpn file that is used for this connection.

When editing the file, update the port from the provious value, to the port you set-up for the second instance of OpenVPN configuration file.

Before testing, make sure you:

1. have the port forwarded to the second instance of VPN
2. ps ax | grep openvpn should show you two instances of openvpn running (with different configs)
3. you modified the ovpn file and loaded it onto the client.

**Note, when connected to your secondary VPN connection (the DNS only one), you will not get a pi-hole splash page when accessing a blocked domain directly. The page will not load or it will load with an error, and that's because we didn't route the traffic through the vpn and we didn't create an iptables rule for masquerading, so the return packets (since they are not part of the same LAN subset as your VPN-CLient-AssignedIps) get lost.
