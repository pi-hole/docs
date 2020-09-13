# Installing the WireGuard server

<!-- markdownlint-disable code-block-style -->
!!! info "The terms "server" and "client""
    Usage of the terms `server` and `client` were purposefully chosen in this guide specifically to help both new users and existing OpenVPN users become familiar with the construction of WireGuard's configuration files.

    WireGuard itself simply refers to all connected devices as `peers`. It consitutes a connection between computers.
<!-- markdownlint-enable code-block-style -->

## Installing the server components

Installing everything we will need for a `wireguard` connections is as simple as running:

``` bash
sudo apt-get install wireguard wireguard-tools wireguard-dkms
```

For Ubuntu 18.04 and lower, you need to do some extra steps:

``` bash
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt update
sudo apt install wireguard wireguard-tools wireguard-dkms
```

## Initial configuration

Each network interface has a private key and a list of peers. Each peer has a public key. Public keys are short and simple, and are used by peers to authenticate each other. They can be passed around for use in configuration files by any out-of-band method, similar to how one might send their SSH public key to a friend for access to a shell server.

First, we create the folder containing our `wireguard` configuration:

``` bash
sudo -i
cd /etc/wireguard
umask 077
```

### Key generation

Inhere, we generate a key-pair for the server:

``` bash
wg genkey | tee server.key | wg pubkey > server.pub
```

### Creating the WireGuard configuration

Create a config file

``` bash
sudo nano /etc/wireguard/wg0.conf
```

and put the following into it:

``` toml
[Interface]
Address = 10.100.0.1/24
ListenPort = 44711
SaveConfig = true
```

Then run

``` bash
echo "PrivateKey = $(cat server.key)" >> /etc/wireguard/wg0.conf
```

to copy the server's private key into your config file.

## Forward port

If the server is behind NAT, be sure to forward the specified port on which WireGuard will be running (for this example, `44711/UDP`) from the router to the WireGuard server.

## Start the server

Register your server `wg0` as:

``` bash
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0
```

If successful, you should not see any output.

<!-- markdownlint-disable code-block-style -->
??? warning "Error: RTNETLINK answers: Operation not supported"
    In case you get an error like

    ``` plain
    RTNETLINK answers: Operation not supported
    Unable to access interface: Protocol not supported
    ```

    you should check that the WireGuard kernel module is loaded with the command below:

    ```bash
    sudo modprobe wireguard
    ```

    If you get an error saying the module is missing, try reinstalling WireGuard or restart your server and try again. This may happen when the WireGuard server is installed for a more recent kernel than you are currently running. This typically happens when you have neither updated nor restarted your system for a long time.
<!-- markdownlint-enable code-block-style -->

## Check everything is running

With the following command, you can check if your `wireguard` server is running:

``` bash
wg
```

The output should look like the following:

``` plain
interface: wg0
  public key: XYZ123456ABC=   ⬅ Your public key will be different
  private key: (hidden)
  listening port: 44711
```

Your public key will be different to ours. This is expected (you just created your own key above).

## Set your Pi-hole to listen on all interfaces

On your [Settings page (tab DNS)](http://pi.hole/admin/settings.php?tab=dns), ensure you set the listing mode of your Pi-hole to one of the `Listen of all interfaces` settings. The top one is perferred as it adds a bit of additional safety. Your WireGuard peers/clients will be correctly recognized as being only one hop away.

You can now continue to add clients.

{!abbreviations.md!}
