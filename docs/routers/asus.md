ASUS was so kind to set up a FAQ how to configure their routers together with Pi-hole.

They offer two kinds of setup depending on your router's firmware version. On newer firmware they recommend setting Pi-hole as DNS server for the `WAN` connection and on older versions for `LAN` connections. However, we recommend to setup Pi-hole always as DNS server for your `LAN`! If you do so, Pi-hole's IP is distributed as DNS server via DHCP to your network clients. Each client will directly send their queries to Pi-hole and will be shown individually in Pi-hole's web interface. Additionally, you can use the group management features.

You can find the FAQ here: [https://www.asus.com/support/FAQ/1046062/](https://www.asus.com/support/FAQ/1046062/)
