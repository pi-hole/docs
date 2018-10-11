title: The pihole command - Pi-hole documentation

Pi-hole makes use of many commands, and here we will break down those required to administer the program via the Command Line Interface.

| Index | Invocation |
 -------------- | --------------
[Core Script](#pi-hole-core) | `pihole`
[Web Script](#pi-hole-web) | `pihole -a`

---

## Pi-hole Core

| Feature | Invocation |
 -------------- | --------------
[Core](#core-script) | `pihole`
[Whitelisting, Blacklisting and Regex](#whitelisting-blacklisting-and-regex) | `pihole -w`, `pihole -b`, `pihole -regex`, `pihole -wild`
[Debugger](#debugger) | `pihole debug`
[Log Flush](#log-flush) | `pihole flush`
[Reconfigure](#reconfigure) | `pihole reconfigure`
[Tail](#tail) | `pihole tail`
[Admin](#admin) | `pihole -a`
[Chronometer](#chronometer) | `pihole chronometer`
[Gravity](#gravity) | `pihole updateGravity`
[Logging](#logging) | `pihole logging`
[Query](#query) | `pihole query`
[Update](#update) | `pihole updatePihole`
[Version](#version) | `pihole version`
[Uninstall](#uninstall) | `pihole uninstall`
[Status](#status) | `pihole status`
[Enable & Disable](#enable-disable) | `pihole enable`
[Restart DNS](#restart-dns) | `pihole restartdns`
[Checkout](#checkout) | `pihole checkout`

### Core Script
| | |
 -------------- | --------------
Help Command    | `pihole --help`
Script Location | [`/usr/local/bin/pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole)
Example Usage   | `pihole -b advertiser.example.com`

The core script of Pi-hole provides the ability to tie many DNS related functions into a simple and user friendly management system, so that one may easily block unwanted content such as advertisements. For both the Command Line Interface (CLI) and Web Interface, we achieve this through the `pihole` command (this helps minimise code duplication, and allows users to read exactly what's happening using `bash` scripting). This "wrapper" elevates the current user (whether it be your own user account, or `www-data`) using `sudo`, but restricts the elevation to solely what can be called through the wrapper.

### Whitelisting, Blacklisting and Regex
| | |
 -------------- | --------------
Help Command    | `pihole -w --help`, `pihole -b --help`, `pihole -regex --help`, `pihole -wild --help`
Script Location | [`/opt/pihole/list.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/list.sh)
Example Usage   | [`pihole -regex '^example.com$' '.*\.example2.net'`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#white-black-list)

Administrators need to be able to manually add and remove domains for various purposes, and these commands serve that purpose.

See [Regex Blocking](/ftldns/regex/overview/) for more information about using Regex.

**Basic Script Process**:

* Each domain is validated using regex (except when using `-regex`), to ensure invalid domains and IDNs are not added
* A whitelisted domain gets added or removed from `/etc/pihole/whitelist.txt`
* A blacklisted domain gets added or removed from `/etc/pihole/blacklist.txt`
  * On either list type, `gravity.sh` is then called to consolidate an updated copy of `gravity.list`, and the DNS server is reloaded
* A regex blacklisted domain gets added or removed from `/etc/pihole/regex.list`
* A wildcard domain gets converted into regex and added or removed from `/etc/pihole/regex.list`
  * For both regex-based commands, `gravity.sh` is then called to restart the DNS server

### Debugger
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/opt/pihole/piholeDebug.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/piholeDebug.sh)
Example Usage   | [`pihole debug`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#debug)

The Pi-hole debugger will attempt to diagnose any issues, and link to an FAQ with instructions as to how an admin can rectify the issue. Once the debugger has finished, the admin has the option to upload the generated log to the [Pi-hole developers](https://github.com/orgs/pi-hole/teams/debug/members), who can help with diagnosing and rectifying persistent issues.

### Log Flush
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/opt/pihole/piholeLogFlush.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/piholeLogFlush.sh)
Example Usage   | [`pihole flush`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#flushing-the-log)

When invoked manually, this command will allow you to empty Pi-hole's log, which is located at `/var/log/pihole.log`. The command also serves to rotate the log daily, if the `logrotate` application is installed.

### Reconfigure
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/etc/.pihole/automated install/basic-install.sh`](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh)
Example Usage   | `pihole reconfigure`

There are times where the administrator will need to repair or reconfigure the Pi-hole installation, which is performed via this command.

**Basic Script Process**:

* [`basic-install.sh`](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh) will be run
  * **Reconfigure** will run through the first-time installation prompts, asking for upstream DNS provider, IP protocols, etc
  * **Repair** will retain your existing settings, and will attempt to repair any scripts or dependencies as necessary
* The rest of `basic-install.sh` will then run as appropriate

### Tail
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/usr/local/bin/pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole)
Example Usage   | [`pihole tail`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#tailing-the-log)

Since Pi-hole will log DNS queries by default, using this command to watch the log in real-time can be useful for debugging a problematic site, or even just for sheer curiosities sake.

### Admin
| | |
 -------------- | --------------
Help Command    | `pihole -a --help`
Script Location | [`/opt/pihole/webpage.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/webpage.sh)
Example Usage   | `pihole -a -p secretpassword`

Detailed information on this is [found here](#web-script).

### Chronometer
| | |
 -------------- | --------------
Help Command    | `pihole -c --help`
Script Location | [`/opt/pihole/chronometer.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/chronometer.sh)
Example Usage   | [`pihole -c -e`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#chronometer)

Chronometer is a console dashboard of real-time stats, which can be displayed via `ssh` or on an LCD screen attached directly to your hardware. The script is capable of detecting the size of your screen, and adjusting output to try and best suit it.

<a href="https://i.imgur.com/NC9C4fT.jpg"><img src="https://i.imgur.com/NC9C4fT.jpg" width="450" height="600"/></a>
<br/><sub><a href="https://www.reddit.com/r/pihole/comments/6ldjna/pihole_setup_went_so_well_at_home_for_the_1st/">Image courtesy of /u/super_nicktendo22</a></sub>

### Gravity
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/opt/pihole/gravity.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/gravity.sh)
Example Usage   | [`pihole -g`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#gravity)

Gravity is one of the most important scripts of Pi-hole. Its main purpose is to retrieve blocklists, and then consolidate them into one unique list for the built-in DNS server to use, but it also serves to complete the process of manual whitelisting, blacklisting and wildcard update. It is run automatically each week, but it can be invoked manually at any time.

**Basic Script Process**:

* It will determine Internet connectivity, and give time for `dnsmasq` to be resolvable on low-end systems if has just been restarted
* It extracts all URLs and domains from `/etc/pihole/adlists.list`
* It runs through each URL, downloading it if necessary
  * `curl` checks the servers `Last-Modified` header to ensure it is getting a newer version
* It will attempt to parse the file into a domains-only format if necessary
* Lists are merged, comments removed, sorted uniquely and stored as `list.preEventHorizon`
* Whitelisted entries within `/etc/pihole/whitelist.txt` are removed from `list.preEventHorizon` and saved into a temporary file
* Blacklisted, "localhost" and temporary file entries are added as seperate `.list` files
* Gravity cleans up temporary content and reloads the DNS server

### Logging
| | |
 -------------- | --------------
Help Command    | `pihole logging --help`
Script Location | [`/usr/local/bin/pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole) 
Example Usage   | [`pihole logging off`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#logging)

This command specifies whether the Pi-hole log should be used, by commenting out `log-queries` within `/etc/dnsmasq.d/01-pihole.conf` and flushing the log.
 
### Query
| | |
 --------------- | ---------------
Help Command    | `pihole query --help`
Script Location | [`/usr/local/bin/pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole) 
Example Usage   | [`pihole -q -exact -adlist example.domain.com`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#adlist-query)

This command will query your whitelist, blacklist, wildcards and adlists for a specified domain.

**Basic Script Process**:

* User-specified options are handled
* Using `idn`, it will convert [Internationalized domain names](https://en.wikipedia.org/wiki/Internationalized_domain_name) into [punycode](https://en.wikipedia.org/wiki/Punycode)
* The whitelist and the blacklist are searched (`/etc/pihole/*list`)
* The possible wildcard matches are then searched  (`/etc/dnsmasq.d/03-pihole-wildcard.conf`)
* The adlists are then searched (`/etc/pihole/list.*.domains`)
* Output is determined by the specified options, ensuring that a file name is only printed once

### Update
| | |
 -------------- | --------------
Help Command    | `pihole update`
Script Location | [`/opt/pihole/update.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/update.sh)
Example Usage   | `pihole -up`

Check Pi-hole Core, Web Interface and FTL repositories to determine what upgrade (if any) is required. It will then automatically update and reinstall if necessary.

**Basic Script Process**:

* Script determines if updates are available by querying GitHub
* Updated files are downloaded to the local filesystem using `git`
* [`basic-install.sh`](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh) is run

### Version
| | |
 --------------- | ---------------
Help Command    | `pihole version`
Script Location | [`/opt/pihole/version.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/version.sh)
Example Usage   | `pihole -v -c`

Shows installed versions of Pi-hole, Web Interface & FTL. Also provides options to configure which details will be printed, such as current version, latest version, hash and subsystem.

### Uninstall
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/etc/.pihole/automated install/uninstall.sh`](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/uninstall.sh)
Example Usage   | [`pihole uninstall`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#uninstall)

Uninstall Pi-hole from your system, giving the option to remove each dependency individually.

### Status
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/usr/local/bin/pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole)
Example Usage   | [`pihole status`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#status)

Display the running status of Pi-hole's DNS and blocking services.

### Enable & Disable
| | |
 -------------- | --------------
Help Command    | `pihole disable --help`
Script Location | [`/usr/local/bin/pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole)
Example Usage   | [`pihole disable 5m`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#toggle)

Toggle Pi-hole's ability to block unwanted domains. The disable option has the option to set a specified time before blocking is automatically re-enabled.

### Restart DNS
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/usr/local/bin/pihole`](https://github.com/pi-hole/pi-hole/blob/master/pihole)
Example Usage   | [`pihole restartdns`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#restartdns)

Restart Pi-hole's DNS service.

### Checkout
| | |
 -------------- | --------------
Help Command    | `pihole checkout --help`
Script Location | [`/opt/pihole/piholeCheckout.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/piholeCheckout.sh) 
Example Usage   | [`pihole checkout dev`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#checkout)

Switch Pi-hole subsystems to a different GitHub branch. An admin can specify repositories as well as branches.

---

## Pi-hole Web

| Feature | Invocation |
 -------------- | --------------
[Web Script](#web-script) | `pihole -a`
[Password](#password) | `pihole -a password`
[Temperature Unit](#temperature-unit) | `pihole -a celsius`, `pihole -a fahrenheit`, `pihole -a kelvin`
[Host Record](#host-record) | `pihole -a hostrecord`
[Email Address](#email-address) | `pihole -a email`
[Interface](#interface) | `pihole -a interface`

### Web Script
| | |
 -------------- | --------------
Help Command    | `pihole -a --help`
Script Location | [`/opt/pihole/webpage.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/webpage.sh)
Example Usage   | `pihole -a -p secretpassword`

Set options for the Web Interface. This script is used to tie in all Web Interface features which are not already covered by the [Core Script](#core-script).

### Password
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/opt/pihole/webpage.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/webpage.sh)
Example Usage   | [`pihole -a -p secretpassword`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#web-password)

Set Web Interface password. Password can be entered as an option (e.g: `pihole -a -p secretpassword`), or seperately as to not display on screen (e.g: `pihole -a -p`).

### Temperature Unit
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/opt/pihole/webpage.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/webpage.sh)
Example Usage   | [`pihole -a -c`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#temp-unit)

Set specified temperature unit as preferred type. This preference will affect the Web Interface, as well as Chronometer.

### Host Record
| | |
 -------------- | --------------
Help Command    | `pihole -a hostrecord --help`
Script Location | [`/opt/pihole/webpage.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/webpage.sh)
Example Usage   | `pihole -a hostrecord home.domain.com 192.168.1.1`

Add A & AAAA records to the DNS, to be associated with an IPv4/IPv6 address.

### Email Address
| | |
 -------------- | --------------
Help Command    | N/A
Script Location | [`/opt/pihole/webpage.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/webpage.sh)
Example Usage   | `pihole -a email admin@domain.com`

Set an administrative contact address for the Block Page. This will create a hyperlink on the Block Page to the specified email address.

### Interface
| | |
 -------------- | --------------
Help Command    | `pihole -a interface --help`
Script Location | [`/opt/pihole/webpage.sh`](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/webpage.sh)
Example Usage   | [`pihole -a interface local`](https://discourse.pi-hole.net/t/the-pihole-command-with-examples/738#interface)

Specify interface listening behavior for `dnsmasq`. When using `pihole -a interface all`, please ensure you use a firewall to prevent your Pi-hole from becoming an unwitting host to [DNS amplification attackers](https://duckduckgo.com/?q=dns+amplification+attack). You may want to consider running [OpenVPN](https://github.com/pi-hole/pi-hole/wiki/Pi-hole---OpenVPN-server) to grant your mobile devices access to the Pi-hole.
