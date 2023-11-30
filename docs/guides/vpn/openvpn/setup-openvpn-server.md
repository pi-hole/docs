{!guides/vpn/openvpn/deprecation_notice.md!}

### Change OpenVPN's resolvers

First, find the IP of your `tun0` interface:

On Jessie

```bash
ifconfig tun0 | grep 'inet addr'
```

On Stretch

```bash
ip a
```

Edit the OpenVPN config file:

```bash
vim /etc/openvpn/server/server.conf
```

Set this line to use your Pi-hole's IP address, which you determined from the `ifconfig` command and comment out or remove the other line (if it exists):

```
push "dhcp-option DNS 10.8.0.1"
#push "dhcp-option DNS 8.8.8.8"
```

This `push` directive is setting a [DHCP option](https://www.incognito.com/tutorials/dhcp-options-in-plain-english/), which tells clients connecting to the VPN that they should use Pi-hole as their primary DNS server.

It's [suggested to have Pi-hole be the only resolver](https://discourse.pi-hole.net/t/why-should-pi-hole-be-my-only-dns-server/3376) as it defines the upstream servers. Setting a non-Pi-hole resolver here [may have adverse effects on ad blocking](https://discourse.pi-hole.net/t/why-should-pi-hole-be-my-only-dns-server/3376) but it _can_ provide failover connectivity in the case of Pi-hole not working if that is something you are concerned about.

Furthermore, you might want to enable logging for your OpenVPN server. In this case, add the following lines to your server's config file:

```
log /var/log/openvpn.log
verb 3
```

### Restart OpenVPN to apply the changes

Depending on your operating system, one of these commands should work to restart the service.

```bash
systemctl restart openvpn-server@server
service openvpn-server@server restart
```

## Create a client config file (`.ovpn`)

Now that the server is configured, you'll want to connect some clients so you can make use of your Pi-hole wherever you are. Doing so requires the use of a certificate. You generate these and the resulting `.ovpn` file by running the installer and choosing `1) Add a new user` for each client that will connect to the VPN.

You can repeat this process for as many clients as you need. In this example, we'll "Add a new user" by naming the `.ovpn` file the same as the client's hostname but you may want to adopt your own naming strategy.

Run the OpenVPN installer again

```bash
./openvpn-install.sh
```

Choose `1) Add a new user` and enter a client name

```text
Looks like OpenVPN is already installed

What do you want to do?
   1) Add a new user
   2) Revoke an existing user
   3) Remove OpenVPN
   4) Exit
Select an option [1-4]: 1

Tell me a name for the client certificate
Please, use one word only, no special characters
Client name: iphone7
```

This will generate a `.ovpn` file, which needs to be copied to your client machine (oftentimes using the OpenVPN app). This process also generates a few other files found in `/etc/openvpn/server/easy-rsa/pki/`, which make public key authentication possible; you only need to worry about the `.ovpn` file, though.
