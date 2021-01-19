# Conceptual overview

Before we get started with installing a `wireguard` server, we'll quickly give a general conceptual overview of what WireGuard is about. You can skip this section if you already know what is going on under the hood or don't care (and just want to have it running).

WireGuard securely encapsulates IP packets over UDP. You add a WireGuard interface, configure it with your private key and your peers' public keys, and then you send packets across it.

WireGuard works by adding a network interface, like `eth0` or `wlan0`, called `wg0` (or `wg1`,
`wg2`, `wg3`, etc). This interface acts as a tunnel interface. Routes for this network interface will be added automatically based on the configuration file you will learn about below. All aspects of this virtual interface will be configured automatically by the `wg-tools`.

WireGuard associates tunnel IP addresses with public keys and remote endpoints. When the interface
**sends a packet to a peer**, it does the following:

1. This packet is meant for `192.168.30.8`. Is this peer configured?
    1. Yes: peer `adams-laptop`. Continue with step 2.
    2. No: Not for any configured peer, drop the packet and end here.

2. Encrypt the IP packet using peer `adams-laptop`'s public key.
3. What is the remote endpoint of peer `adams-laptop`? Let me look... Okay, the endpoint is host `216.58.211.110:53133` (UDP).
4. Send encrypted data over the Internet to this host.

When the interface **receives a packet from a peer**, this happens:

1. Received a packet from host `98.139.183.24:7361`. Let's decrypt it!
2. It decrypted and authenticated properly for peer `evas-android`. Okay, let's remember that peer
`evas-android`'s most recent Internet endpoint is `98.139.183.24:7361` (UDP).
3. Once decrypted, the plain-text packet is from `192.168.43.89`. Is peer `evas-android` allowed to be sending us packets as 192.168.43.89?
    1. Yes: accept the packet on the interface and process it (forwarding to further local client, into the Internet, etc.)
    2. No: drop it.

Behind the scenes there is much happening to provide proper privacy, authenticity, and perfect forward secrecy, using state-of-the-art cryptography.

If you're interested in the internal inner workings, you might be interested in reading through the various articles on their official website [www.wireguard.com](https://www.wireguard.com) which is also where we took the vast majority of content in this guide from.
