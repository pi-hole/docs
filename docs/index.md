<p align="center">
<a href="https://pi-hole.net"><img src="https://pi-hole.github.io/graphics/Vortex/Vortex_with_text.png" width="150" height="255" alt="Pi-hole"></a><br/>
<b>Network-wide ad blocking via your own Linux hardware</b><br/>
</p>

The Pi-hole[®](https://pi-hole.net/trademark-rules-and-brand-guidelines/) is a [DNS sinkhole](https://en.wikipedia.org/wiki/DNS_Sinkhole) that protects your devices from unwanted content, without installing any client-side software.

- **Easy-to-install**: our versatile installer walks you through the process, and [takes less than ten minutes](https://www.youtube.com/watch?v=vKWjx1AQYgs)
- **Resolute**: content is blocked in _non-browser locations_, such as ad-laden mobile apps and smart TVs
- **Responsive**: seamlessly speeds up the feel of everyday browsing by caching DNS queries
- **Lightweight**: runs smoothly with [minimal hardware and software requirements](main/prerequesites.md)
- **Robust**: a command line interface that is quality assured for interoperability
- **Insightful**: a beautiful responsive Web Interface dashboard to view and control your Pi-hole
- **Versatile**: can optionally function as a [DHCP server](https://discourse.pi-hole.net/t/how-do-i-use-pi-holes-built-in-dhcp-server-and-why-would-i-want-to/3026), ensuring *all* your devices are protected automatically
- **Scalable**: [capable of handling hundreds of millions of queries](https://pi-hole.net/2017/05/24/how-much-traffic-can-pi-hole-handle/) when installed on server-grade hardware
- **Modern**: blocks ads over both IPv4 and IPv6
- **Free**: open source software which helps ensure _you_ are the sole person in control of your privacy

-----

## Pi-hole is free, but powered by your support
There are many reoccurring costs involved with maintaining free, open source, and privacy respecting software; expenses which [our volunteer developers](https://github.com/orgs/pi-hole/people) pitch in to cover out-of-pocket. This is just one example of how strongly we feel about our software, as well as the importance of keeping it maintained.

Make no mistake: **your support is absolutely vital to help keep us innovating!**

### Donations
Sending a donation using our links below is **extremely helpful** in offsetting a portion of our monthly expenses:

- <a href="https://pi-hole.net/donate/">Donate via PayPal or Stripe</a>
- [Bitcoin](https://commerce.coinbase.com/checkout/fb7facaf-bebd-46be-bb77-b358f4546763): <code>3MDPzjXu2hjw5sGLJvKUi1uXbvQPzVrbpF</code>
- [Bitcoin Cash](https://commerce.coinbase.com/checkout/fb7facaf-bebd-46be-bb77-b358f4546763): <code>qzqsz4aju2eecc6uhs7tus4vlwhhela24sdruf4qp5</code>
- [Ethereum](https://commerce.coinbase.com/checkout/fb7facaf-bebd-46be-bb77-b358f4546763): <code>0x79d4e90A4a0C732819526c93e21A3F1356A2FAe1</code>

### Alternative support
If you'd rather not donate (_which is okay!_), there are other ways you can help support us:

- [Pi-hole Swag Store](https://pi-hole.net/shop/)
- [Digital Ocean](http://www.digitalocean.com/?refcode=344d234950e1) _new account credits with our affiliate link_
- [UNIXstickers.com](http://unixstickers.refr.cc/jacobs) _save $5 when you spend $9 using our affiliate link_
- [Amazon](http://www.amazon.com/exec/obidos/redirect-home/pihole09-20) _affiliate link_
- [Vultr](http://www.vultr.com/?ref=7190426) _affiliate link_
- Spreading the word about our software, and how you have benefited from it

### Contributing via GitHub
We welcome _everyone_ to contribute to issue reports, suggest new features, and create pull requests.

If you have something to add - anything from a typo through to a whole new feature, we're happy to check it out! Just make sure to fill out our template when submitting your request; the questions that it asks will help the volunteers quickly understand what you're aiming to achieve.

You'll find that the [install script](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh) and the [debug script](https://github.com/pi-hole/pi-hole/blob/master/advanced/Scripts/piholeDebug.sh) have an abundance of comments, which will help you better understand how Pi-hole works. They're also a valuable resource to those who want to learn how to write scripts or code a program! We encourage anyone who likes to tinker to read through it, and submit a pull request for us to review.

### Presentations about Pi-hole
Word-of-mouth continues to help our project grow immensely, and so we are helping make this easier for people.

If you are going to be presenting Pi-hole at a conference, meetup or even a school project, [get in touch with us](https://pi-hole.net/2017/05/17/giving-a-presentation-on-pi-hole-contact-us-first-for-some-goodies-and-support/) so we can hook you up with free swag to hand out to your audience!

-----

## Getting in touch with us
While we are primarily reachable on our <a href="https://discourse.pi-hole.net/">Discourse User Forum</a>, we can also be found on a variety of social media outlets. **Please be sure to check the FAQ's** before starting a new discussion, as we do not have the spare time to reply to every request for assistance.

- [Frequently Asked Questions](https://discourse.pi-hole.net/c/faqs)
- [Feature Requests](https://discourse.pi-hole.net/c/feature-requests?order=votes)

<br/>

- [Reddit](https://www.reddit.com/r/pihole/)
- [Twitter](https://twitter.com/The_Pi_Hole)
- [Gitter](https://gitter.im/pi-hole/pi-hole)
- [YouTube](https://www.youtube.com/channel/UCT5kq9w0wSjogzJb81C9U0w)
- [Facebook](https://www.facebook.com/ThePiHole/)

-----

## The Origin Of Pi-hole
Pi-hole being a **advertising-aware DNS/Web server**, makes use of the following technologies:

* [`dnsmasq`](http://www.thekelleys.org.uk/dnsmasq/doc.html) - a lightweight DNS and DHCP server
* [`curl`](https://curl.haxx.se) - A command line tool for transferring data with URL syntax
* [`lighttpd`](https://www.lighttpd.net) - webserver designed and optimized for high performance
* [`php`](https://secure.php.net) - a popular general-purpose web scripting language
* [AdminLTE Dashboard](https://github.com/almasaeed2010/AdminLTE) - premium admin control panel based on Bootstrap 3.x

While quite outdated at this point, [this original blog post about Pi-hole](https://jacobsalmela.com/2015/06/16/block-millions-ads-network-wide-with-a-raspberry-pi-hole-2-0/) goes into **great detail** about how Pi-hole was originally setup and how it works. Syntactically, it's no longer accurate, but the same basic principles and logic still apply to Pi-hole's current state.

-----

## Pi-hole Projects
- [The Big Blocklist Collection](https://wally3k.github.io)
- [Docker Pi-hole container (x86 and ARM)](https://hub.docker.com/r/diginc/pi-hole/)
- [Pi-Hole in the cloud](http://blog.codybunch.com/2015/07/28/Pi-Hole-in-the-cloud/)
- [Pie in the Sky-Hole [A Pi-Hole in the cloud for ad-blocking via DNS]](https://dlaa.me/blog/post/skyhole)
- [Pi-hole Enable/Disable Button](http://thetimmy.silvernight.org/pages/endisbutton/)
- [Minibian Pi-hole](https://munkjensen.net/wiki/index.php/See_my_Pi-Hole#Minibian_Pi-hole)
- [CHiP-hole: Network-wide Ad-blocker](https://www.hackster.io/jacobsalmela/chip-hole-network-wide-ad-blocker-98e037)
- [Chrome Extension: Pi-Hole List Editor](https://chrome.google.com/webstore/detail/pi-hole-list-editor/hlnoeoejkllgkjbnnnhfolapllcnaglh) ([Source Code](https://github.com/packtloss/pihole-extension))
- [Splunk: Pi-hole Visualiser](https://splunkbase.splunk.com/app/3023/)
- [Adblocking with Pi-hole and Ubuntu 14.04 on VirtualBox](https://hbalagtas.blogspot.com.au/2016/02/adblocking-with-pi-hole-and-ubuntu-1404.html)
- [Pi-hole stats in your Mac's menu bar](https://getbitbar.com/plugins/Network/pi-hole.1m.py)
- [Pi-hole unRAID Template](https://forums.lime-technology.com/topic/36810-support-spants-nodered-mqtt-dashing-couchdb/)
- [Copernicus: Windows Tray Application](https://github.com/goldbattle/copernicus)
- [Let your blink1 device blink when Pi-hole filters ads](https://gist.github.com/elpatron68/ec0b4c582e5abf604885ac1e068d233f)
- [Pi-hole metrics](https://github.com/nlamirault/pihole_exporter) exporter for [Prometheus](https://prometheus.io/)
- [Magic Mirror with DNS Filtering](https://zonksec.com/blog/magic-mirror-dns-filtering/#dnssoftware)
- [Pi-hole Droid: Android client](https://github.com/friimaind/pi-hole-droid)
- [Windows DNS Swapper](https://github.com/roots84/DNS-Swapper), see [#1400](https://github.com/pi-hole/pi-hole/issues/1400)
- [Pi-hole Visualizer](https://www.reddit.com/r/pihole/comments/82ikgb/pihole_visualizer_update/)
-----

## Coverage
- [Lifehacker: Turn A Raspberry Pi Into An Ad Blocker With A Single Command](https://www.lifehacker.com.au/2015/02/turn-a-raspberry-pi-into-an-ad-blocker-with-a-single-command/)
- [MakeUseOf: Adblock Everywhere: The Raspberry Pi-Hole Way](http://www.makeuseof.com/tag/adblock-everywhere-raspberry-pi-hole-way/)
- [Catchpoint: Ad-Blocking on Apple iOS9: Valuing the End User Experience](http://blog.catchpoint.com/2015/09/14/ad-blocking-apple/)
- [Security Now Netcast: Pi-hole](https://www.youtube.com/watch?v=p7-osq_y8i8&t=100m26s)
- [TekThing: Raspberry Pi-Hole Makes Ads Disappear!](https://youtu.be/8Co59HU2gY0?t=2m)
- [Foolish Tech Show](https://youtu.be/bYyena0I9yc?t=2m4s)
- [Block Ads on All Home Devices for $53.18](https://medium.com/@robleathern/block-ads-on-all-home-devices-for-53-18-a5f1ec139693#.gj1xpgr5d)
- [Pi-Hole for Ubuntu 14.04](http://www.boyter.org/2015/12/pi-hole-ubuntu-14-04/)
- [MacObserver Podcast 585](https://www.macobserver.com/tmo/podcast/macgeekgab-585)
- [The Defrag Show: Endoscope USB Camera, The Final [HoloLens] Vote, Adblock Pi and more](https://channel9.msdn.com/Shows/The-Defrag-Show/Defrag-Endoscope-USB-Camera-The-Final-HoloLens-Vote-Adblock-Pi-and-more?WT.mc_id=dlvr_twitter_ch9#time=20m39s)
- [Adafruit: Pi-hole is a black hole for internet ads](https://blog.adafruit.com/2016/03/04/pi-hole-is-a-black-hole-for-internet-ads-piday-raspberrypi-raspberry_pi/)
- [Digital Trends: 5 Fun, Easy Projects You Can Try With a $35 Raspberry Pi](https://youtu.be/QwrKlyC2kdM?t=1m42s)
- [Adafruit: Raspberry Pi Quick Look at Pi Hole ad blocking server with Tony D](https://www.youtube.com/watch?v=eg4u2j1HYlI)
- [Devacron: OrangePi Zero as an Ad-Block server with Pi-Hole](http://www.devacron.com/orangepi-zero-as-an-ad-block-server-with-pi-hole/)
- [Linux Pro: The Hole Truth](http://www.linuxpromagazine.com/Issues/2017/200/The-sysadmin-s-daily-grind-Pi-hole)
- [CryptoAUSTRALIA: How We Tried 5 Privacy Focused Raspberry Pi Projects](https://blog.cryptoaustralia.org.au/2017/10/05/5-privacy-focused-raspberry-pi-projects/)
- [CryptoAUSTRALIA: Pi-hole Workshop](https://blog.cryptoaustralia.org.au/2017/11/02/pi-hole-network-wide-ad-blocker/)
- [Know How 355: Killing ads with a Raspberry Pi-Hole!](https://www.twit.tv/shows/know-how/episodes/355)
- [Bloomberg: Inside the Brotherhood of the Ad Blockers](https://www.bloomberg.com/news/features/2018-05-10/inside-the-brotherhood-of-pi-hole-ad-blockers)

{!abbreviations.md!}
