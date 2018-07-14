### Dual VPN Setup - Separate DNS and VPN Traffic 
In order to separate VPN traffic from DNS queries you will need to run two VPN servers, one that routes the traffic and one that answers only to DNS requests. This configuration requires a second instance of OpenVPN.

#### Prerequisites and Configuration
We are going to use the original configuration file (`/etc/openvpn/server.conf`). You will copy it then edit the second file:

```
sudo cp /etc/openvpn/server.conf /etc/openvpn/server2.conf
sudo nano /etc/openvpn/server2.conf
```

We will need to change the port to one different from the original, so that it does not conflict with the first instance of OpenVPN

Assuming you used the default port configuration, you should have 1194 as the port. You need to change this to a different value (make sure the port is available - 1195 should be) and if needed, port forward it from your router to your device. You will also need to assign a different class of IP addresses that will serve this connection only. 

Your server line should look like this:

```
server 10.9.0.0 255.255.255.0
```

Make sure that the DNS requests go though the instance of OpenVPN: 

```
push "dhcp-option DNS 10.9.0.1"
```

One other setting that we need to change is to comment out `# push "redirect-gateway def1 bypass-dhcp"`.

Save the file and run the second instance of OpenVPN:

```
systemctl start openvpn@server2.service
```

*If your distribution does not have `systemctl` you may use commands like below to start OpenVPN with your second configuration as a daemon:* 

```
/usr/sbin/openvpn --daemon --writepid /var/run/openvpn/server2.pid --cd /etc/openvpn --config server2.conf --script-security 2
```

The next step is to edit the existing .ovpn file that is used for this connection.

When editing the file, update the port from the previous value to the port you used for the second instance of OpenVPN.

#### Testing
Before testing, make sure that:

1. Port forwarding is configured for the second instance of OpenVPN.
2. `ps ax | grep openvpn` shows two instances of OpenVPN running (with different configs).
3. The modified ovpn file is loaded on the client.

**Note: when connected to your secondary VPN connection (the DNS only one), you will not get a Pi-hole splash page when accessing a blocked domain directly. The page will not load or it will load with an error, because we did not route the traffic through the VPN. We did not create an `iptables` rule for masquerading and the return packets (since they are not part of the same LAN subset as your VPN CLient) get lost.**
