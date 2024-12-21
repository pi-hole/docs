### Notes & Warnings

- **This is an unsupported configuration created by the community**

### Basic requirements

1. Run [basic-install](/main/basic-install/) and choose to install the Admin Web Interface.
   lighttpd is the default webserver installed and used by the pi-hole Admin Web Interface.

### Optional configuration

lighttpd config with [BLOCK\_IPV4](/ftldns/configfile/#block_ipv4) or [BLOCK\_IPV6](/ftldns/configfile/#block_ipv6)
(Note this does not work with TLS due to local server not having local TLS certificates for 1.6+ million ad domains)

Option 1: configure lighttpd 404 error handler (compatibility with old pi-hole behavior)
Sample handler: pi-hole used to provide /var/www/html/pihole/[index.php](https://github.com/pi-hole/pi-hole/blob/v5.14.2/advanced/index.php)
Adjust `server.error-handler-404` to be the url-path from the virtual host document root (e.g. `/var/www/html`).
If not already enabled, the global lighttpd.conf must be configured for mod\_fastcgi to handle `.php`.
(Alternatively, `/pihole/index.php` could instead be an empty file `/404.txt`)

Fedora:

   ```bash
   echo 'server.error-handler-404 := "/pihole/index.php"' > /etc/lighttpd/conf.d/pihole-block-ip.conf
   echo 'include "/etc/lighttpd/conf.d/pihole-block-ip*.conf"' >> /etc/lighttpd/lighttpd.conf
   service lighttpd restart
   ```

Debian:

   ```bash
   echo 'server.error-handler-404 := "/pihole/index.php"' > /etc/lighttpd/conf-available2/08-pihole-block-ip.conf
   lighty-enable-mod pihole-block-ip
   service lighttpd restart
   ```

Option 2: configure lighttpd mod\_magnet

Download, review, and copy [pihole-block-ip.lua](https://github.com/gstrauss/pi-hole/blob/lighttpd-lua/advanced/pihole.lua) to `/etc/lighttpd/pihole-block-ip.lua`
(sample lua app created by lighttpd dev, also replacing `pihole-admin.conf`)

Fedora:

   ```bash
   echo 'server.modules += ("mod_magnet")' > /etc/lighttpd/conf.d/pihole-block-ip.conf
   echo 'magnet.attract-physical-path-to += ("/etc/lighttpd/pihole-block-ip.lua")' >> /etc/lighttpd/conf.d/pihole-block-ip.conf
   echo 'include "/etc/lighttpd/conf.d/pihole-block-ip*.conf"' >> /etc/lighttpd/lighttpd.conf
   service lighttpd restart
   ```

Debian:

   ```bash
   echo 'server.modules += ("mod_magnet")' > /etc/lighttpd/conf.d/pihole-block-ip.conf
   echo 'magnet.attract-physical-path-to += ("/etc/lighttpd/pihole-block-ip.lua")' >> /etc/lighttpd/conf.d/pihole-block-ip.conf
   lighty-enable-mod pihole-block-ip
   service lighttpd restart
   ```
