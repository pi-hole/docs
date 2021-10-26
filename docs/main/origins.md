---
title: Pi-hole Origins
description: Software packages used in Pi-hole
last_updated: Sun Jan 13 18:35:14 2019 UTC
---

Pi-hole being a **advertising-aware DNS/Web server**, makes use of the following technologies:

- [`dnsmasq`](https://www.thekelleys.org.uk/dnsmasq/doc.html) - a lightweight DNS and DHCP server
- [`curl`](https://curl.haxx.se/) - A command-line tool for transferring data with URL syntax
- [`lighttpd`](https://www.lighttpd.net/) - web server designed and optimized for high performance
- [`php`](https://www.php.net/) - a popular general-purpose web scripting language
- [AdminLTE Dashboard](https://github.com/ColorlibHQ/AdminLTE) - premium admin control panel based on Bootstrap 3.x
- [`sqlite3`](https://www.sqlite.org/index.html) - SQL Database engine

While quite outdated at this point, [this original blog post about Pi-hole](https://jacobsalmela.com/2015/06/16/block-millions-ads-network-wide-with-a-raspberry-pi-hole-2-0/) goes into **great detail** about how Pi-hole was originally set up and how it works. Syntactically, it's no longer accurate, but the same basic principles and logic still apply to Pi-hole's current state.

{!abbreviations.md!}
