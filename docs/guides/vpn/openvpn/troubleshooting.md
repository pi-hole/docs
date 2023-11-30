{!guides/vpn/openvpn/deprecation_notice.md!}

### CRL expired

OpenVPN 2.4 and newer check the validity of the Certificate Revocation List (CRL). This can result in a sudden malfunction of `openvpn` after an update even though no configuration files have changed. This error manifests in the following, not very helpful, error on the client's side:

```
Wed Apr 24 11:19:07 2019 VERIFY OK: depth=0, CN=server
Wed Apr 24 11:19:07 2019 Connection reset, restarting [0]
Wed Apr 24 11:19:07 2019 SIGUSR1[soft,connection-reset] received, process restarting
Wed Apr 24 11:19:07 2019 Restart pause, 5 second(s)
```

Android clients simply report: "Transport error, trying to reconnect..."

> ![](Android-Transport-Error.png)

On the OpenVPN server, the following messages are logged:

```
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp TLS: Initial packet from [AF_INET]aaa.bbb.ccc.ddd:pppp, sid=57719cb8 77945ae9
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp VERIFY ERROR: depth=0, error=CRL has expired: CN=client1
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp OpenSSL: error:11089086:SSL routines:ssl3_get_client_certificate:certificate verify failed
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp TLS_ERROR: BIO read tls_read_plaintext error
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp TLS Error: TLS object -> incoming plaintext read error
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp TLS Error: TLS handshake failed
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp Fatal TLS error (check_tls_errors_co), restarting
Wed Apr 24 11:19:07 2019 aaa.bbb.ccc.ddd:pppp SIGUSR1[soft,tls-error] received, client-instance restarting
```

The error is `CRL has expired` and can be solved using the following commands:

```
sudo -s
cd /etc/openvpn
mv crl.pem crl.pem_old
cd easy-rsa
./easyrsa gen-crl
cp pki/crl.pem ../
service openvpn restart
exit
```
