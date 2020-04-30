**This is an unsupported configuration created by the community**

If you'd like to use [Caddy](https://caddyserver.com/) as your main web server with Pi-hole, you'll need to make a few changes.

> Note: This guide only deals with setting up caddy as a reverse-proxy and not as a replacement for lighttpd (Although caddy is capable of doing so, but it is beyond the scope of this guide).

## Modifying lighttpd configuration

First, change the listen port in this file: `/etc/lighttpd/lighttpd.conf:`

```lighttpd
server.port = 1080
```

In this case, port 1080 was chosen at random. You can use a custom port.

Next, restart the lighttpd server with either of these commands:

```bash
sudo systemctl restart lighttpd
```

or

```bash
sudo service lighttpd restart
```

## Setting up your Caddyfile

Now set up a "virtual host" in your Caddyfile (default `/etc/caddy/Caddyfile`). There are many options you can add, but at a minimum, you need to make a "default" host by binding `0.0.0.0:80`. This will accept requests for any interface.

### Caddyfile (Caddy Version 1)

```
blackhole:80, pi.hole:80, 0.0.0.0:80 {
  root /var/www/html/pihole
  log /var/log/caddy/blackhole.log

  rewrite {
    ext js
    to index.js
  }

  proxy / localhost:1080 {
    transparent
  }
}
```

In this case, I've chosen to also add blackhole and pi.hole as valid names to open the admin page with.

### Caddyfile (Caddy version 2)

```
pi.hole:80{
  reverse_proxy localhost:1080
}
```

- If you'd like to enable Https on your site, make sure your server is reacheable via your domain name (ex: myawesomesite.com) and is pointing to the right IP address.
- Additionally you need to open ports :80 and :443 (Apart from the one's required specifically for pi-hole) for your server before setting up https.

The following configuration will automatically fetch and setup Https for your domain using Lets-Encrypt

```
myawesomesite.com {
  reverse_proxy localhost:1080
}
```

Additionally you can make pihole reacheable via a subdomain and optionally can you enable Zstandard and Gzip compression as follows:

```
pihole.myawesomesite.com {
  reverse_proxy localhost:1080
  encode zstd gzip
}
```

Finally, run `sudo systemctl daemon-reload` to force caddy to load the new configuration.

## Verifying your setup

First, make sure that any other sites you're serving from caddy are still functioning. For example, if you have a block for `myawesomesite.com:80` or similar in your Caddyfile, open up a browser to `http://myawesomesite.com` (or `https://` if you have enabled it) and verify it still loads.

Next, verify you can load the admin page. Open up `http://pi.hole/admin` (or use the IP address of your server) and verify that you can access the admin page.

Finally, verify that requests for ads are being black holed:

```bash
$ curl -H "Host: badhost" pi.hole/
<html>
<head>
<script>window.close();</script>
</head>
<body>
</body>
</html>
```

Replace the URL `pi.hole` with the IP address or alternate DNS name you're using if necessary.

Lastly, ensure that requests for JavaScript files from advertisement domains are being served properly:

```bash
curl -H "Host: badhost" pi.hole/malicious.js
var x = "Pi-hole: A black hole for Internet advertisements."
```

For more information visit caddy's documentation [website](https://caddyserver.com/docs/).
