# Adding a WireGuard client

Adding clients is really simple and easy. The process for setting up a client is similar to setting up the server. This is expected as WireGuard's concept is more of the type Peer-to-Peer than server-client as mentioned at the very beginning of the [Server configuration](server.md).

For each new client, the following steps must be taken. For the sake of simplicity, we will create the config file on the server itself. This, however, means that you need to transfer the config file *securely* to your server as it contains the private key of your client. An alternative way of doing this is to generate the configuration locally on your client and add the necessary lines to your server's configuration.

## Key generation

We generate a key-pair for the client `NAME` (replace accordingly everywhere below):

``` bash
sudo -i
cd /etc/wireguard
umask 077
wg genkey | tee NAME.key | wg pubkey > NAME.pub
```

## PSK Key generation

We furthermore recommend generating a pre-shared key (PSK) in addition to the keys above. This adds an additional layer of symmetric-key cryptography to be mixed into the already existing public-key cryptography and is mainly for post-quantum resistance. A pre-shared key should be generated for each peer pair and *should not be reused*.

``` bash
wg genpsk > NAME.psk
```

## Add client to server configuration

Add the new client by running the command:

``` bash
echo "[Peer]" >> /etc/wireguard/wg0.conf
echo "PublicKey = $(cat NAME.pub)" >> /etc/wireguard/wg0.conf
echo "PresharedKey = $(cat NAME.psk)" >> /etc/wireguard/wg0.conf
echo "AllowedIPs = 10.100.0.2/32" >> /etc/wireguard/wg0.conf
```

<!-- markdownlint-disable code-block-style -->
!!! info "Client IP address"
    Make sure to increment the IP address for any further client! We add the first client with the IP address `10.100.0.2` in this example (`10.100.0.1` is the server)
<!-- markdownlint-disable code-block-style -->

Restart your server to load the new client config:

``` bash
sudo service wg-quick@wg0 restart
```

After a restart, the server file should look like:

``` toml
[Interface]
Address = 10.100.0.1/24
ListenPort = 47111
SaveConfig = true
PrivateKey = XYZ123456ABC=                   # PrivateKey will be different

[Peer]
PublicKey = F+80gbmHVlOrU+es13S18oMEX2g=     # PublicKey will be different
PresharedKey = 8cLaY8Bkd7PiUs0izYBQYVTEFlA=  # PresharedKey will be different
AllowedIPs = 10.100.0.2/32

# Possibly further [Peer] lines
```

The command

``` bash
wg
```

should tell you about your new client:

``` plain
interface: wg0
  public key: XYZ123456ABC=          ⬅ Your server's public key will be different
  private key: (hidden)
  listening port: 47111

peer: F+80gbmHVlOrU+es13S18oMEX2g=   ⬅ Your peer's public key will be different
  preshared key: (hidden)
  allowed ips: 10.100.0.2/32
```

## Create client configuration

Create a dedicated config file for your new client:

``` bash
nano NAME.conf
```

with the content

``` toml
[Interface]
Address = 10.100.0.2/32 # Replace this IP address for subsequent clients
DNS = 10.100.0.1        # IP address of your server (Pi-hole)
```

and add the private key of this client

``` bash
echo "PrivateKey = $(cat NAME.key)" >> NAME.conf
```

Next, add your server as peer for this client:

``` toml
[Peer]
AllowedIPs = 10.100.0.0/24
Endpoint = [your public IP or domain]:47111
PersistentKeepalive = 25
```

Then add the public key of the server as well as the PSK for this connection:

``` bash
echo "PublicKey = $(cat server.pub)" >> NAME.conf
echo "PresharedKey = $(cat NAME.psk)" >> NAME.conf
```

That's it.

<!-- markdownlint-disable code-block-style -->
??? info "About the `PersistentKeepalive` setting"
    By default WireGuard peers remain silent while they do not need to communicate, so peers located behind a NAT and/or firewall may be unreachable from other peers until they reach out to other peers themselves (or the connection may time out).

    When a peer is behind NAT or a firewall, it typically wants to be able to receive incoming packets even when it is not sending any packets itself. Because NAT and stateful firewalls keep track of "connections", if a peer behind NAT or a firewall wishes to receive incoming packets, he must keep the NAT/firewall mapping valid, by periodically sending keepalive packets. This is called *persistent keepalives*.

    When this option is enabled, a keepalive packet is sent to the server endpoint once every interval seconds. A sensible interval that works with a wide variety of firewalls is `25` seconds. Setting it to 0 turns the feature off, which is the default.

    Handshakes are not the same as keep-alives. A handshake establishes a limited-time session of about 3 minutes. So, for about 3 minutes your client is able to send its keep-alive packets without requireing a new session. Then, when the session expires, sending a new keep-alive requires a new session for which you should see a new handshake. In practice, the client initiates a handshake earlier.
    
    **TL;DR** If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent, this option will keep the "connection" open in the eyes of NAT.
<!-- markdownlint-disable code-block-style -->

## Copy config file to client

You can now copy the configuration file to your client (if you created the config on the server). If the client is a mobile device such as a phone, `qrencode` can be used to generate a scanable QR code:

``` bash
qrencode -t ansiutf8 -r NAME.conf
```

(you may need to install `qrencode` using `sudo apt-get install qrencode`)

You can directly scan this QR code with the official WireGuard app after clicking on the blue plus symbol in the lower right corner.

## Connect to your WireGuard VPN

After creating/copying the connection information over to your client, you may use the client you prefer to connect to your system. Mind that setting up auto-start of the WireGuard connection may lead to issues if you are doing this too early (when the system cannot resolve DNS). See our [FAQ](faq.md) for further hints.

You can check if your client successfully connected by, once again, running

``` plain
wg
```

on the server. It should show some traffic for your client if everything works:

``` plain
interface: wg0
  public key: XYZ123456ABC=          ⬅ Your server's public key will be different
  private key: (hidden)
  listening port: 47111

peer: F+80gbmHVlOrU+es13S18oMEX2g=   ⬅ Your peer's public key will be different
  preshared key: (hidden)
  allowed ips: 10.100.0.2/32
  latest handshake: 32 seconds ago
  transfer: 3.43 KiB received, 188 B sent
```

## Test for DNS leaks

You should run a DNS leak test on [www.dnsleaktest.com](https://www.dnsleaktest.com) to ensure your WireGuard tunnel does not leak DNS requests (so all are processed by your Pi-hole). The expected outcome is that you should only see DNS servers belonging to the upstream DNS destination you selected in Pi-hole. If you configured [Pi-hole as All-Around DNS Solution](../unbound.md), you should only see the public IP address of your WireGuard server and no other DNS server.

See also [What is a DNS leak and why should I care?](https://www.dnsleaktest.com/what-is-a-dns-leak.html) (external link).

{!abbreviations.md!}
