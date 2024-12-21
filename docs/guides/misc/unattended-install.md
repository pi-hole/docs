## Unattended Installation

Pi-hole can be installed unattended when using the installation script.

The installation script will look for the `/etc/pihole/setupVars.conf` configuration file.
If it finds this file, it will use the variables specified here during the install.
The install script will also update this file during the install process if required.

This is what the `/etc/pihole/setupVars.conf` file looks like with the quad9 dns servers specified:

``` conf
WEBPASSWORD=
PIHOLE_INTERFACE=ens18
IPV4_ADDRESS=
IPV6_ADDRESS=
QUERY_LOGGING=true
INSTALL_WEB=true
DNSMASQ_LISTENING=single
PIHOLE_DNS_1=9.9.9.9
PIHOLE_DNS_2=142.112.112.112
PIHOLE_DNS_3=2620:fe::fe
PIHOLE_DNS_4=2620:fe::9
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSSEC=true
TEMPERATUREUNIT=C
WEBUIBOXEDLAYOUT=traditional
API_EXCLUDE_DOMAINS=
API_EXCLUDE_CLIENTS=
API_QUERY_LOG_SHOW=all
API_PRIVACY_MODE=false
```

If you want to specify the webpassword yourself instead of letting the install process generate one, use a double SHA256 encrypted string like so: `echo -n P@ssw0rd | sha256sum | awk '{printf "%s",$1 }' | sha256sum`.

If you want to specify a port after an IP address use the `#` instead of `:` like so: `127.0.0.1#5353`

After creating the `/etc/pihole/setupVars.conf` file, simply run the install script with the `--unattended` flag specfified.
