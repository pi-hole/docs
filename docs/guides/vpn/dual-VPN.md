### Dual VPN setup - separate adblock and traffic 
If you want to run two VPN servers, one that routes the traffic and one that answers only to DNS requests, you will have to create another instance of OpenVPN.

### Prerequisites and Configuration
We're going to use the original configuration file (`/etc/openvpn/server.conf`) and copy it, and then, edit the second file:

```
sudo cp /etc/openvpn/server.conf /etc/openvpn/server2.conf
sudo nano /etc/openvpn/server2.conf
```

We'll need to change the port to a diferent one from the original, so that it does not conflict with the first instance of OpenVPN

Assuming you used the default port configuration, you should have 1194 as the port. You need to change this to a different value (make sure the port is available - 1195 should be) and if needed, port forward it from your router to your device. You also need to assign a different class of IPs that will serve this connection only. 
Your server line should look like this:

```
server 10.9.0.0 255.255.255.0
```

And make sure that the DNS requests go though the instance of OpenVPN: 

```
push "dhcp-option DNS 10.9.0.1"
```

One other setting that we need to change is to comment out `# push "redirect-gateway def1 bypass-dhcp"`.
Save the file and run the second instance of OpenVPN:

```
systemctl start openvpn@server2.service
```

If your distro doesn’t have `systemctl` you may use commands like below to start OpenVPN with your second configuration as a daemon: 

```
/usr/sbin/openvpn --daemon --writepid /var/run/openvpn/server2.pid --cd /etc/openvpn --config server2.conf --script-security 2
```

The next step is to edit the existing .ovpn file that is used for this connection.

When editing the file, update the port from the previous value to the port you used for the second instance of OpenVPN.

### Testing
Before testing, make sure:

1. you have the port forwarded to the second instance of OpenVPN
2. `ps ax | grep openvpn` should show you two instances of openvpn running (with different configs)
3. you modified the ovpn file and loaded it onto the client.

**Note, when connected to your secondary VPN connection (the DNS only one), you will not get a Pi-hole splash page when accessing a blocked domain directly. The page will not load or it will load with an error, and that's because we didn't route the traffic through the VPN and we didn't create an iptables rule for masquerading, so the return packets (since they are not part of the same LAN subset as your VPN CLient) get lost.**
