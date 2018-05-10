If you operate your Pi-hole + OpenVPN at home, it is very likely that you are sitting behind a NAT / dynamically changing IP address. In this case, you should set up a dynamic DNS record, which allows you to reach your server. You can exchange the address that has been configured during the setup of OpenVPN like this:

```
vim /etc/openvpn/client-common.txt
```

Look for the `remote` line and adjust it accordingly (remove IP address, add host name), e.g.

```
remote home.mydomain.de 1194
```

This change has to be repeated in each client config file (`*.conf`) that you have been created up till now.

If you have set up a DDNS domain for your IP address, you will likely need to add a host-record to Pi-hole's settings.

```
pihole -a hostrecord home.mydomain.de 192.168.1.10
```

If you don't do this, clients (like the Android OpenVPN client) will not able to connect to the VPN server when *inside the internal network* (while it will work from outside).  Afterwards, the client will be able to connect to the VPN server both from inside and outside you local network.