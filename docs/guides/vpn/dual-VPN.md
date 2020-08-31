### Dual VPN Setup - Separate DNS and VPN Traffic

In order to separate VPN traffic from DNS queries, you will need to run two VPN servers. One server routes the normal user traffic and the second routes only DNS requests. This can be done with two OpenVPN configurations.

#### Prerequisites and Configuration

You should have an existing OpenVPN server configured and running. We are going to use the original configuration file located at `/etc/openvpn/server/server.conf`.

First, copy the file:

```bash
sudo cp /etc/openvpn/server/server.conf /etc/openvpn/server/server2.conf
```

Next, exit the new copy of the configuration. We use the `nano` editor in this example, but any editor will work. Remember to edit under the root account via `sudo`.

```bash
sudo nano /etc/openvpn/server/server2.conf
```

We will need to change the port to one different from the original so that it does not conflict with the first instance of OpenVPN. Assuming you used the default port configuration, you should have 1194 as the port. You need to change this to a different value, making sure the port is available - 1195 should be.

Next, if needed, port forward the newly configured port from your router to your device. You will also need to assign a different class of IP addresses that will serve this connection only.

Your server line should look like this:

```
server 10.9.0.0 255.255.255.0
```

Make sure that the DNS requests go through the instance of OpenVPN:

```
push "dhcp-option DNS 10.9.0.1"
```

One other setting that we need to change is to comment out the `bypass-dhcp` instruction so that it looks like:

```
# push "redirect-gateway def1 bypass-dhcp"`.
```

Commenting out this line ensures that no traffic is routed via the VPN server.

Save the file and start the second instance of OpenVPN:

```bash
systemctl start openvpn@server2.service
```

*If your distribution does not have `systemctl` you may use the command below to start an OpenVPN daemon with your second configuration:*

```bash
/usr/sbin/openvpn --daemon --writepid /run/openvpn/server2.pid --cd /etc/openvpn --config server2.conf --script-security 2
```

Finally, edit the existing `.ovpn` file used for the client connection. Update the port from the previous value to the port you used for the second instance of OpenVPN.

#### Testing

Before testing, make sure that:

1. Port forwarding is configured for the second instance of OpenVPN.
2. `ps ax | grep openvpn` shows two instances of OpenVPN running (with different configs).
3. The modified ovpn file is loaded on the client.

*Note: when connected to your DNS only VPN connection **you will not get a Pi-hole splash page when accessing a blocked domain directly.** The page will not load or it may load with an error. **This is because the web server traffic is not routed through the VPN.** We did not create an `iptables` rule for masquerading, and the return packets (since they are not part of the same LAN subset as your VPN Client) are prevented.*
