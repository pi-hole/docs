## Available interfaces

Pi-hole stats can be accessed via a standard Unix socket (`/run/pihole/FTL.sock`), a telnet-like connection (TCP socket on port `4711`) as well as indirectly via the Web API (`admin/api.php`), and the command line (`pihole -c -j`). You can out find more details below.

## Command-line arguments

- `debug` - Don't go into daemon mode (stay in foreground) + more verbose logging
- `test` - Start `FTL` and process everything, but shut down immediately afterward
- `version` - Don't start `FTL`, only show the version
- `tag` - Don't start `FTL`, show only git tag
- `branch` - Don't start `FTL`, show only git branch `FTL` was compiled from
- `no-daemon` or `-f` - Don't go into background (daemon mode)
- `help` or `-h` - Don't start `FTL`, show help
- `dnsmasq-test` - Test resolver config file syntax
- `--` everything behind `--` will be passed as options to the internal resolver

Command-line arguments can be arbitrarily combined, e.g. `pihole-FTL debug test`

## File locations

- `/var/log/pihole-FTL.log` log file
- `/run/pihole-FTL.pid` PID file
- `/run/pihole-FTL.port` file containing port on which `FTL` is listening
- `/run/pihole/FTL.sock` Unix socket

## Linux capabilities

Capabilities (POSIX 1003.1e, [capabilities(7)](http://man7.org/linux/man-pages/man7/capabilities.7.html)) provide fine-grained control over superuser permissions, allowing the use of the `root` user to be avoided.
To perform permission checks, traditional UNIX implementations distinguish two categories of processes: *privileged processes* (superuser or `root`), and *unprivileged processes*. Privileged processes bypass all kernel permission checks, while unprivileged processes are subject to full permission checking based on the process's credentials (user and group permissions and supplementary process capabilities). Capabilities are implemented on Linux using extended attributes ([xattr(7)](http://man7.org/linux/man-pages/man5/attr.5.html)) in the `security` namespace. Extended attributes are supported by all major Linux file systems, including Ext2, Ext3, Ext4, Btrfs, JFS, XFS, and ReiserFS.

For your safety and comfort, `pihole-FTL` is run by the entirely unprivileged user `pihole`.
Whereas `dnsmasq` is running as `root` process, we designed `pihole-FTL` to be run by the entirely unprivileged user `pihole`. As a consequence, `pihole-FTL` will not be able to access the files of any other user on this system or mess around with your system's configuration.

However, this also implies that *FTL*DNS cannot bind to ports 53 (DNS) among some other necessary capabilities related to DHCP services. To establish a strong security model, we explicitly grant the `pihole-FTL` process additional capabilities so that `pihole-FTL` (but no other processes which may be started by `pihole`) can bind to port 53, etc., without giving any additional permissions to the `pihole` user.

We specifically add the following capabilities to `pihole-FTL`:

- `CAP_NET_BIND_SERVICE`: Allows *FTL*DNS binding to TCP/UDP sockets below 1024 (specifically DNS service on port 53)
- `CAP_NET_RAW`: use raw and packet sockets (we need a RAW socket for handling DHCPv6 requests)
- `CAP_NET_ADMIN`: modify routing tables and other network-related operations (to allow for handling DHCP requests)

Users that cannot use Linux capabilities for various reasons (lacking kernel or file system support) can modify the startup scripts of `pihole-FTL` to ensure the daemon is started as `root`. However, be aware that you do so on your own risk (although we don't expect problems to arise).

{!abbreviations.md!}
