**See bottom of this page for how to generate additional client certificates**

### Connect from a client
There are various tutorials available for all operating systems for how to connect to an OpenVPN server.

### Android

See special page [here](https://github.com/pi-hole/pi-hole/wiki/OpenVPN-server:-Connect-from-a-client-(Android)).

### Linux
I'll demonstrate the procedure here for Ubuntu Linux (which trivially extends to Linux Mint, etc.)

1. Install the necessary network-manager plugins
```
sudo apt-get install network-manager-openvpn network-manager-openvpn-gnome
sudo service network-manager restart
```

2. Securely copy the necessary certificates from your OpenVPN server to your client (e.g. using `sftp`). They are located in `/etc/openvpn/easy-rsa/pki`

You will need:

* User Certificate: `/etc/openvpn/easy-rsa/pki/issued/client.crt`
* CA Certificate: `/etc/openvpn/easy-rsa/pki/ca.crt`
* Private Key: `/etc/openvpn/easy-rsa/pki/private/client.key`
* Private Key Password: Depending on your settings (might even be empty)
* TA Key: `/etc/openvpn/ta.key`

Further details can be found in the screenshots provided below:
![](http://www.dl6er.de/pi-hole/openVPN/conn_type.png)
![](http://www.dl6er.de/pi-hole/openVPN/keys.png)
![](http://www.dl6er.de/pi-hole/openVPN/general.png)
![](http://www.dl6er.de/pi-hole/openVPN/security.png)
![](http://www.dl6er.de/pi-hole/openVPN/tls.png)

Your whole network traffic will now securely be transferred to your Pi-hole.
![](http://www.dl6er.de/pi-hole/openVPN/VPNclients.png)

### Windows

You will have to install additional software. See https://openvpn.net/index.php/open-source/downloads.html

---

### Optional: Add more client certificates

You have to generate an individual certificate for each client. This can be done very conveniently like shown below:
<pre>
<b>sudo bash openvpn-install.sh</b>

Looks like OpenVPN is already installed

What do you want to do?
   <b>1) Add a new user</b>
   2) Revoke an existing user
   3) Remove OpenVPN
   4) Exit
Select an option [1-4]: <b>1</b>

Tell me a name for the client certificate
Please, use one word only, no special characters
Client name: thinkpad2
Generating a 2048 bit RSA private key
.......................+++
....+++
writing new private key to '/etc/openvpn/easy-rsa/pki/private/thinkpad2.key.kHwbBkvK9b'
-----
Using configuration from /etc/openvpn/easy-rsa/openssl-1.0.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'thinkpad2'
Certificate is to be certified until Feb 28 10:24:26 2027 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

<b>Client thinkpad2 added, configuration is available at /root/thinkpad2.ovpn</b>
</pre>
Copy the file `/root/thinkpad2.ovpn` to your new client.

**WARNING** Anyone who gets his hands on this configuration/certificate file can obtain full access to your VPN. Make sure that you use only trusted paths for transferring the file (e.g. *never* send it via an un-encrypted channel, e.g. email or FTP). Best strategy is to use an USB thumbdrive to avoid any network transport at all. Make sure to delete the certificate on the USB drive afterwards.

**NOTICE** If one of your certificates has been compromised, remove it using option `2` (see above) and generate a new certificate. This will effectively lock out anyone who might have gotten access to the certificate.