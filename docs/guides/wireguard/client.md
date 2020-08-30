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

Add the following to your `/etc/wireguard/wg0.conf`:

``` toml
[Peer]
Address = 10.100.0.2/24      # Replace this IP address for subsequent clients
AllowedIPs = 10.100.0.1/32   # This client is only allowed to talk to the server
```

Then run

``` bash
echo "PublicKey = $(cat NAME.pub)" >> /etc/wireguard/wg0.conf
echo "PresharedKey = $(cat NAME.psk)" >> /etc/wireguard/wg0.conf
```

to copy the clients's public and pre-shared keys into the server's config file.

## Create client configuration

Create a dedicated config file for your new client:

``` bash
nano NAME.conf
```

with the content

``` toml
[Interface]
Address = 10.100.0.2/24 # Replace this IP address for subsequent clients
DNS = 10.100.0.1        # IP address of your Pi-hole
Domains = ~.            # Enforce all DNS over the WireGuard connection
```

``` bash
echo "PrivateKey = $(cat NAME.key)" >> NAME.conf
```

Then add your server as the only peer for this client:

``` toml
[Peer]
AllowedIPs = 10.0.0.1/24
Endpoint = [your public IP or domain]:44711
PersistentKeepalive = 25
```

Make sure that each IP is used only once.

<!-- markdownlint-disable code-block-style -->
??? info "About the `PersistentKeepalive` setting"
    By default WireGuard peers remain silent while they do not need to communicate, so peers located behind a NAT and/or firewall may be unreachable from other peers until they reach out to other peers themselves (or the connection may time out).

    When a peer is behind NAT or a firewall, it typically wants to be able to receive incoming packets even when it is not sending any packets itself. Because NAT and stateful firewalls keep track of "connections", if a peer behind NAT or a firewall wishes to receive incoming packets, he must keep the NAT/firewall mapping valid, by periodically sending keepalive packets. This is called *persistent keepalives*.

    When this option is enabled, a keepalive packet is sent to the server endpoint once every interval seconds. A sensible interval that works with a wide variety of firewalls is `25` seconds. Setting it to 0 turns the feature off, which is the default.
    
    **TL;DR** If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent, this option will keep the "connection" open in the eyes of NAT.
<!-- markdownlint-disable code-block-style -->

Then add the public key of the server as well as the PSK for this connection:

``` bash
echo "PublicKey = $(cat server.pub)" >> NAME.conf
echo "PresharedKey = $(cat NAME.psk)" >> NAME.conf
```

That's it.

## Copy config file to client

You can now copy the configuration file to your client (if you created the config on the server). If the client is a mobile device such as a phone, `qrencode` can be used to generate a scanable QR code:

``` bash
qrencode -t ansiutf8 -r NAME.conf
```

(you may need to install `qrencode` using `sudo apt-get install qrencode`)

## Connect to your WireGuard VPN

After creating/copying the connection information over to your client, you may use the client you prefer to connect to your system. Mind that setting up auto-start of the WireGuard connection may lead to issues if you are doing this too early (when the system cannot resolve DNS). See our [FAQ](faq.md) for further hints.

{!abbreviations.md!}
