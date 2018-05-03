## Linux capabilites
Capabilities (POSIX 1003.1e, [capabilities(7)](http://man7.org/linux/man-pages/man7/capabilities.7.html)) provide fine-grained control over superuser permissions, allowing use of the `root` user to be avoided.
For the purpose of performing permission checks, traditional UNIX implementations distinguish two categories of processes: *privileged processes* (superuser or `root`), and *unprivileged processes*. Privileged processes bypass all kernel permission checks, while unprivileged processes are subject to full permission checking based on the process's credentials (user and grounp permissions and supplementary process capabilities). Capabilities are implemented on Linux using extended attributes ([xattr(7)](http://man7.org/linux/man-pages/man5/attr.5.html)) in the `security` namespace. Extended attributes are supported by all major Linux file systems, including Ext2, Ext3, Ext4, Btrfs, JFS, XFS, and Reiserfs.

For your safety and comfort, `pihole-FTL` is run by the entirely unpriviledged user `pihole`.
Wheras `dnsmasq` is running as `root` process, we designed `pihole-FTL` to be run by the entirely unpriviledged user `pihole`. As a consequence, `pihole-FTL` will not be able to access the files of any other user on this system or mess around with your system's configuration.

However, this also implies that *FTL*DNS cannot bind to ports 53 (DNS) among some other necessary capabilites related to DHCP services. To establish a strong security model, we explicitly grant the `pihole-FTL` process additional capabilities so that `pihole-FTL` (but no other processes which may be started by `pihole`) can bind to port 53, etc., without giving any additional permissions to the `pihole` user.

We specifically add the following capabilities to `pihole-FTL`:

- `CAP_NET_BIND_SERVICE`: Allows *FTl*DNS binding to TCP/UDP sockets below 1024 (specifically DNS service on port 53)
- `CAP_NET_RAW`: use RAW and PACKET sockets (we need a RAW socket for handling DHCPv6 requests)
- `CAP_NET_ADMIN`: modify routing tables and other network-related operations (to allow for handling DHCP requests)
