# Installing the WireGuard server

<!-- markdownlint-disable code-block-style -->
!!! info "The terms "server" and "client""
    Usage of the terms `server` and `client` were purposefully chosen in this guide specifically to help both new users and existing OpenVPN users become familiar with the construction of WireGuard's configuration files.

    WireGuard itself simply refers to all connected devices as `peers`. It constitutes a connection between computers.
<!-- markdownlint-enable code-block-style -->

## Installing the server components

Installing everything we will need for a `wireguard` connections is as simple as running:

```bash
sudo apt-get install wireguard wireguard-tools
```

For Ubuntu 18.04 and before, you need to do some extra steps:

```bash
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt update
sudo apt install wireguard wireguard-tools
```

If you're running a kernel older than 5.6 (check with `uname -r`), you will also need to install `wireguard-dkms`

If there is no `wireguard` package available for your system, you can follow the instructions below to compile WireGuard from source.

<!-- markdownlint-disable code-block-style -->
??? info "Compile WireGuard from source"

    With the following commands, you can install WireGuard from source as a backport of the WireGuard kernel module for Linux to 3.10 ≤ kernel ≤ 5.5 as an out-of-tree module. More recent kernels already include WireGuard themselves and you only need to install the `wireguard` tools.

    ### Update your local system

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

    ### Install the toolchain

    === "Raspberry Pi"

        ```bash
        sudo apt install -y raspberrypi-kernel-headers libelf-dev build-essential pkg-config git
        ```

    === "Linux"

        ```bash
        sudo apt install -y linux-headers-$(uname -r) libelf-dev build-essential libmnl-dev git
        ```

    ## Download and compile the `wireguard` module

    ```bash
    git clone https://git.zx2c4.com/wireguard-linux-compat
    make -C wireguard-linux-compat/src -j$(nproc)
    sudo make -C wireguard-linux-compat/src install
    ```

    You can ignore messages like

    ```plain
    Warning: modules_install: missing 'System.map' file. Skipping depmod.
    ```

    !!! info "Check the module installation was successful"

        Run

        ```bash
        sudo modprobe wireguard
        ```

        If there is no output, `wireguard` was loaded correctly. Note that it may be necessary to re-install the `wireguard` module when you update your system's kernel.

    ## Download and compile the `wireguard` tools (`wg`, etc.)

    ```bash
    git clone https://git.zx2c4.com/wireguard-tools
    make -C wireguard-tools/src -j$(nproc)
    sudo make -C wireguard-tools/src install
    ```

    The ZX2C4 git repository is the official source for `wireguard-linux`, see [WireGuard#Repositories](https://www.wireguard.com/repositories/) (external link)
<!-- markdownlint-enable code-block-style -->

## Initial configuration

Each network interface has a private key and a list of peers. Each peer has a public key. Public keys are short and simple, and are used by peers to authenticate each other. They can be passed around for use in configuration files by any out-of-band method, similar to how one might send their SSH public key to a friend for access to a shell server.

First, we create the folder containing our `wireguard` configuration:

```bash
sudo -i
cd /etc/wireguard
umask 077
```

### Key generation

Inhere, we generate a key-pair for the server:

```bash
wg genkey | tee server.key | wg pubkey > server.pub
```

### Creating the WireGuard configuration

Create a config file

```bash
sudo nano /etc/wireguard/wg0.conf
```

and put the following into it:

```plain
[Interface]
Address = 10.100.0.1/24, fd08:4711::1/64
ListenPort = 47111
```

Then run

```bash
echo "PrivateKey = $(cat server.key)" >> /etc/wireguard/wg0.conf
exit # Exit the sudo session
```

to copy the server's private key into your config file.

## Forward port on your router

If the server is behind a device, e.g., a router that is doing NAT, be sure to forward the specified port on which WireGuard will be running (for this example, `47111/UDP`) from the router to the WireGuard server.

??? info "NAT: Network address translation"
    Network address translation modifies network packages. Incoming connection requests have their destination address rewritten to a different one.
    NAT involves more than just changing the IP addresses. For instance, when mapping address `1.2.3.4` to `5.6.7.8`, there is no need to add a rule to do the reverse translation. A `netfilter` system called `conntrack` recognizes packets that are replies to an existing connection. Each connection has its own NAT state attached to it. The reverse translation is done automatically.

## Set up a domain name for your router

When connecting from outside your network, you'll need to know the public IP address of your router to connect. However, as most households are getting dynamically-assigned public IP addresses (these addresses change periodically), you need to note down the address every day before leaving the house. Since this is *very* uncomfortable, we strongly suggest registering a *dynamic host record* (often called "[DynDNS](https://en.wikipedia.org/wiki/Dynamic_DNS)" record).

The public IP address is checked at regular intervals. As soon as it changes, the router (or a DynDNS tool) sends a corresponding message to a URL of the service provider, who then updates the record.

There are many excellent guides and a lot of services offer this for free (with more or less comfort). We suggest a few providers below, however, this list is neither absolute nor exhaustive:

<!-- markdownlint-disable code-block-style -->
??? info "DynDNS providers"
    - [Strato.de](https://www.strato.de/hosting/dynamic-dns-free/) (Guides: [EN](https://www.strato.com/faq/en_us/domain/this-is-how-easy-it-is-to-set-up-dyndns-for-your-domains/) / [DE](https://www.strato.de/faq/domains/so-einfach-richten-sie-dyndns-fuer-ihre-domains-ein/))

        If you already have a hosting package at Strato, you can easily set up a subdomain to be used as a DynDNS record. This is entirely free for members.

    - [DNSHome.de](https://DNSHome.de)

        This provider offers you several free subdomains under different domain names. SSL and also IPv6 are possible. DNSSEC is activated by default. They offer configuration guides for the Fritz!Box and also `ddclient` (update tool for Windows and Linux) on the website.

    - [GoIP.de](https://www.goip.de/)

        Go IP is a German DynDNS provider. The service is completely free and allows the registration of one domain and up to 15 subdomains per person. The website is characterized by extensive help with setting up the router.

    - [noip.com](https://www.noip.com/support/knowledgebase/getting-started-with-no-ip-com/)

        You can up to three hostnames like `myname.no-ip.org` for free. A disadvantage is that you have to confirm the domains at least every 30 days, otherwise they will be deleted.

    - [Dyn.com](https://account.dyn.com/)

        One of the first providers to offer DynDNS was the American company Dyn, whose product "DynDNS" gave its name to an entire service branch. In the meantime, numerous successors whose services are often free of charge came up. DynDNS service is especially easy to use is if it is directly supported by the router.
<!-- markdownlint-enable code-block-style -->

You can either use the methods the corresponding providers recommend or use existing DynDNS solutions inbuilt in your router (if available). Most providers are compatible with, e.g., the popular Fritz!Box routers ([EN](https://en.avm.de/service/fritzbox/fritzbox-4040/knowledge-base/publication/show/30_Setting-up-dynamic-DNS-in-the-FRITZ-Box/) / [DE](https://avm.de/service/fritzbox/fritzbox-7590/wissensdatenbank/publication/show/30_Dynamic-DNS-in-FRITZ-Box-einrichten/)).

## Start the server

Register your server `wg0` as:

```bash
sudo systemctl enable wg-quick@wg0.service
sudo systemctl daemon-reload
sudo systemctl start wg-quick@wg0
```

If successful, you should not see any output.

<!-- markdownlint-disable code-block-style -->
??? warning "Error: RTNETLINK answers: Operation not supported"
    In case you get an error like

    ```plain
    RTNETLINK answers: Operation not supported
    Unable to access interface: Protocol not supported
    ```

    you should check that the WireGuard kernel module is loaded with the command below:

    ```bash
    sudo modprobe wireguard
    ```

    If you get an error saying the module is missing, try reinstalling WireGuard or restart your server and try again. This may happen when the WireGuard server is installed for a more recent kernel than you are currently running. This typically happens when you have neither updated nor restarted your system for a long time.

??? warning "Error: RTNETLINK answers: File exists"
    In case you get an error like

    ```plain
    RTNETLINK answers: File exists
    ```

    you need to check the configured IP addresses (check the CIDR notation). Overlapping IP address ranges cause this error when trying to register a router for an address where a a route already exists. This is meaningful and always an error in your configuration. However, the error message could be more clear about this.

<!-- markdownlint-enable code-block-style -->

## Check everything is running

With the following command, you can check if your `wireguard` server is running:

```bash
sudo wg
```

The output should look like the following:

```plain
interface: wg0
  public key: XYZ123456ABC=   ⬅ Your public key will be different
  private key: (hidden)
  listening port: 47111
```

Your public key will be different from ours. This is expected (you just created your own key above).

## Set your Pi-hole to allow only local requests

On your [Settings page (tab DNS)](http://pi.hole/admin/settings.php?tab=dns), ensure you select the appropriate listening mode of your Pi-hole. `Allow only local requests` is preferred as it adds a bit of additional safety. Your WireGuard peers/clients will be correctly recognized as being only one hop away.

You can now continue to [add clients](client.md).
