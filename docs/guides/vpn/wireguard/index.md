### Remote accessing Pi-hole using WireGuard

WireGuard is an ***extremely simple yet fast and modern VPN*** that utilizes state-of-the-art cryptography. Comparing to other solutions, such as OpenVPN or IPsec, it aims to be **faster, simpler, and leaner** while avoiding the massive overhead involved with other VPN solutions.
A combination of extremely high-speed cryptographic primitives and the fact that WireGuard lives
inside the Linux kernel means that secure networking can be very high-speed.
It intends to be considerably more performant than OpenVPN.

WireGuard is designed as a general-purpose VPN for running on embedded interfaces and super computers alike, fit for many circumstances.

There is no need to manage connections, be concerned about state, manage daemons, or worry about what's under the hood. WireGuard presents an extremely basic yet powerful interface.

Using WireGuard is a modern and safe way to access your Pi-hole's capabilities remotely. Setting up a DNS server has become a simple task with Pi-hole's automated installer, which has resulted in many people knowingly--or unknowingly--creating an open resolver, which aids in DNS Amplification Attacks.

WireGuard has been designed with ease-of-implementation and simplicity in mind. It is meant to be
easily implemented in very few lines of code, and easily auditable for security vulnerabilities.

This article aims to provide a step-by-step walk-through on setting up a server running Pi-hole and WireGuard so you can securely connect to your Pi-hole's DNS (and *optionally* your entire internal network) from anywhere.

**This tutorial walks you through the installation of a WireGuard server on your Pi-hole**.

Via this VPN, you can:

- use the full filtering capabilities of your Pi-hole
- access your Pi-hole dashboard remotely
- access all your internal devices (*optional*)
- reroute your entire Internet traffic through your Pi-hole (*optional*)

from everywhere around the globe.
