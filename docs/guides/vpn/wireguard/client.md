# Adding a WireGuard client

Adding clients is really simple and easy. The process for setting up a client is similar to setting up the server. This is expected as WireGuard's concept is more of the type Peer-to-Peer than server-client as mentioned at the very beginning of the [Server configuration](server.md).

For each new client, the following steps must be taken. For the sake of simplicity, we will create the config file on the server itself. This, however, means that you need to transfer the config file *securely* to your server as it contains the private key of your client. An alternative way of doing this is to generate the configuration locally on your client and add the necessary lines to your server's configuration.

<!-- markdownlint-disable code-block-style -->
??? info "Script to generate clients automatically"
    Script content:

    ```bash
    #! /usr/bin/env bash
    umask 077

    ipv4="$1$4"
    ipv6="$2$4"
    serv4="${1}1"
    serv6="${2}1"
    target="$3"
    name="$5"

    wg genkey | tee "${name}.key" | wg pubkey > "${name}.pub"
    wg genpsk > "${name}.psk"

    echo "# $name" >> /etc/wireguard/wg0.conf
    echo "[Peer]" >> /etc/wireguard/wg0.conf
    echo "PublicKey = $(cat "${name}.pub")" >> /etc/wireguard/wg0.conf
    echo "PresharedKey = $(cat "${name}.psk")" >> /etc/wireguard/wg0.conf
    echo "AllowedIPs = $ipv4/32, $ipv6/128" >> /etc/wireguard/wg0.conf
    echo "" >> /etc/wireguard/wg0.conf

    echo "[Interface]" > "${name}.conf"
    echo "Address = $ipv4/32, $ipv6/128" >> "${name}.conf"
    echo "DNS = ${serv4}, ${serv6}" >> "${name}.conf" #Specifying DNS Server
    echo "PrivateKey = $(cat "${name}.key")" >> "${name}.conf"
    echo "" >> "${name}.conf"
    echo "[Peer]" >> "${name}.conf"
    echo "PublicKey = $(cat server.pub)" >> "${name}.conf"
    echo "PresharedKey = $(cat "${name}.psk")" >> "${name}.conf"
    echo "Endpoint = $target" >> "${name}.conf"
    echo "AllowedIPs = ${serv4}/32, ${serv6}/128" >> "${name}.conf" # clients isolated from one another
    # echo "AllowedIPs = ${1}0/24, ${2}/64" >> "${name}.conf" # clients can see each other
    echo "PersistentKeepalive = 25" >> "${name}.conf"

    # Print QR code scanable by the Wireguard mobile app on screen
    qrencode -t ansiutf8 < "${name}.conf"

    wg syncconf wg0 <(wg-quick strip wg0)
    ```

    Run the script like

    ```bash
    chmod +x /path/to/script.sh
    sudo -i
    cd /etc/wireguard

    /path/to/script.sh "10.100.0." "fd08:4711::" "my_server_domain:47111" 2 "annas-android"
    /path/to/script.sh "10.100.0." "fd08:4711::" "my_server_domain:47111" 3 "peters-laptop"

    exit
    ```

    to generate two clients:

    - `annas-android` with addresses `10.100.0.2` and `fd08:4711::2`
    - `peters-laptop` with addresses `10.100.0.3` and `fd08:4711::3`

    connecting to the server running at `my_server_domain:47111`
<!-- markdownlint-disable code-block-style -->

## Key generation

We generate a key-pair for the client `NAME` (replace accordingly everywhere below):

```bash
sudo -i
cd /etc/wireguard
umask 077
name="client_name"
wg genkey | tee "${name}.key" | wg pubkey > "${name}.pub"
```

## PSK Key generation

We furthermore recommend generating a pre-shared key (PSK) in addition to the keys above. This adds an additional layer of symmetric-key cryptography to be mixed into the already existing public-key cryptography and is mainly for post-quantum resistance. A pre-shared key should be generated for each peer pair and *should not be reused*.

```bash
wg genpsk > "${name}.psk"
```

## Add client to server configuration

Add the new client by running the command:

```bash
echo "[Peer]" >> /etc/wireguard/wg0.conf
echo "PublicKey = $(cat "${name}.pub")" >> /etc/wireguard/wg0.conf
echo "PresharedKey = $(cat "${name}.psk")" >> /etc/wireguard/wg0.conf
echo "AllowedIPs = 10.100.0.2/32, fd08:4711::2/128" >> /etc/wireguard/wg0.conf
```

<!-- markdownlint-disable code-block-style -->
!!! info "Client IP address"
    Make sure to increment the IP address for any further client! We add the first client with the IP addresses `10.100.0.2` and `fd08:4711::2/128` in this example (`10.100.0.1` and `fd08:4711::1/128` are the server)
<!-- markdownlint-disable code-block-style -->

Reload your server config to add the new client:

```bash
wg syncconf wg0 <(wg-quick strip wg0)
```

This command reads back the existing configuration first and only makes changes that are explicitly different between the configuration file and the current configuration of the interface. This is somewhat less efficient than simply restarting the interface (`systemctl restart wg-quick@wg0`) but has the benefit of *not disrupting currently connected peers*.

After a restart, the server file should look like:

```plain
[Interface]
Address = 10.100.0.1/24, fd08:4711::1/128
ListenPort = 47111
PrivateKey = XYZ123456ABC=                   # PrivateKey will be different

[Peer]
PublicKey = F+80gbmHVlOrU+es13S18oMEX2g=     # PublicKey will be different
PresharedKey = 8cLaY8Bkd7PiUs0izYBQYVTEFlA=  # PresharedKey will be different
AllowedIPs = 10.100.0.2/32, fd08:4711::2/128

# Possibly further [Peer] lines
```

The command

```bash
wg
```

should tell you about your new client:

```plain
interface: wg0
  public key: XYZ123456ABC=          ⬅ Your server's public key will be different
  private key: (hidden)
  listening port: 47111

peer: F+80gbmHVlOrU+es13S18oMEX2g=   ⬅ Your peer's public key will be different
  preshared key: (hidden)
  allowed ips: 10.100.0.2/32, fd08:4711::2/128
```

## Create client configuration

Create a dedicated config file for your new client:

```bash
echo "[Interface]" > "${name}.conf"
echo "Address = 10.100.0.2/32, fd08:4711::2/128" >> "${name}.conf" # May need editing
echo "DNS = 10.100.0.1" >> "${name}.conf"                          # Your Pi-hole's IP
```

and add the private key of this client

```bash
echo "PrivateKey = $(cat "${name}.key")" >> "${name}.conf"
```

Next, add your server as peer for this client:

```plain
[Peer]
AllowedIPs = 10.100.0.1/32, fd08:4711::1/128
Endpoint = [your public IP or domain]:47111
PersistentKeepalive = 25
```

Then add the public key of the server as well as the PSK for this connection:

```bash
echo "PublicKey = $(cat server.pub)" >> "${name}.conf"
echo "PresharedKey = $(cat "${name}.psk")" >> "${name}.conf"
exit
```

That's it.

<!-- markdownlint-disable code-block-style -->
??? info "About the `PersistentKeepalive` setting"
    By default WireGuard peers remain silent while they do not need to communicate, so peers located behind a NAT and/or firewall may be unreachable from other peers until they reach out to other peers themselves (or the connection may time out).

    When a peer is behind NAT or a firewall, it typically wants to be able to receive incoming packets even when it is not sending any packets itself. Because NAT and stateful firewalls keep track of "connections", if a peer behind NAT or a firewall wishes to receive incoming packets, he must keep the NAT/firewall mapping valid, by periodically sending keepalive packets. This is called *persistent keepalives*.

    When this option is enabled, a keepalive packet is sent to the server endpoint once every interval seconds. A sensible interval that works with a wide variety of firewalls is `25` seconds. Setting it to 0 turns the feature off, which is the default.

    Handshakes are not the same as keep-alives. A handshake establishes a limited-time session of about 3 minutes. So, for about 3 minutes your client is able to send its keep-alive packets without requiring a new session. Then, when the session expires, sending a new keep-alive requires a new session for which you should see a new handshake. In practice, the client initiates a handshake earlier.

    **TL;DR** If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent, this option will keep the "connection" open in the eyes of NAT.
<!-- markdownlint-disable code-block-style -->

## Copy config file to client

You can now copy the configuration file to your client (if you created the config on the server). If the client is a mobile device such as a phone, `qrencode` can be used to generate a scanable QR code:

```bash
sudo qrencode -t ansiutf8 < "/etc/wireguard/${name}.conf"
```

(you may need to install `qrencode` using `sudo apt-get install qrencode`)

You can directly scan this QR code with the official WireGuard app after clicking on the blue plus symbol in the lower right corner.

## Connect to your WireGuard VPN

After creating/copying the connection information over to your client, you may use the client you prefer to connect to your system. Mind that setting up auto-start of the WireGuard connection may lead to issues if you are doing this too early (when the system cannot resolve DNS). See our [FAQ](faq.md) for further hints.

You can check if your client successfully connected by, once again, running

```bash
sudo wg
```

on the server. It should show some traffic for your client if everything works:

```plain
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

You should run a DNS leak test on [www.dnsleaktest.com](https://www.dnsleaktest.com) to ensure your WireGuard tunnel does not leak DNS requests (so all are processed by your Pi-hole). The expected outcome is that you should only see DNS servers belonging to the upstream DNS destination you selected in Pi-hole. If you configured [Pi-hole as All-Around DNS Solution](../../dns/unbound.md), you should only see the public IP address of your WireGuard server and no other DNS server.

See also [What is a DNS leak and why should I care?](https://www.dnsleaktest.com/what-is-a-dns-leak.html) (external link).
