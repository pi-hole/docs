title: The `setupVars.conf` file Pi-hole documentation

Pi-hole has two configuration files, we will step through the options in the `setupVars.conf` file. The `setupVars.conf` file is used when running [`basic-install.sh`](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh); the following options are buried inside that script, the main [`pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole) script, and the [`install.sh`](https://github.com/pi-hole/docker-pi-hole/blob/master/install.sh) script in the Docker version.

Scripts modify and update `setupVars.conf` while running.


### Config variables

| config value | default | description |
| ------------ | ------- | ----------- |
`BLOCKING_ENABLED` | |
`DNSMASQ_LISTENING_BEHAVIOUR` | |
`DNSMASQ_LISTENING` | |
`HOSTNAME` | |
`INSTALL_WEB_INTERFACE` | true | install html files necessary for pihole web dashboard
`INSTALL_WEB_SERVER` | true | install lighthttpd, the _webserver_ used to display the web interface
`IPV4_ADDRESS` |  | IPv4 address where pihole DNS and (optional) web server listen
`IPV6_ADDRESS` |  | IPv6 address where pihole DNS and (optional) web server listen
`LIGHTTPD_ENABLED` | true |
`PIHOLE_DNS_1` | 8.8.8.8 | upstream DNS server
`PIHOLE_DNS_2` | 8.8.4.4 | upstream DNS server
`PIHOLE_INTERFACE` | |
`PIHOLE_INTERFACE` | | Network interface to listen on for DHCP
`PRIVACY_LEVEL` | true |
`QUERY_LOGGING` | true |
`WEBPASSWORD` | [random value](https://github.com/pi-hole/pi-hole/blob/995ee41d6bc3a405a0402745b24140ca08c148f3/automated%20install/basic-install.sh#L2567) | plaintext password for web interface
`WEB_PORT` | |
`reconfigure` | false |
`runUnattended` | false | allow unattended (scripted) setup; can be enabled with `--unattended`
`skipSpaceCheck` | false | don't check for at least 50MB in free disk space; can be enabled with `--i_do_not_follow_recommendations`

