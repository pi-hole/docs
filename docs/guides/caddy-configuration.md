**This is an unsupported configuration created by the community**

If you'd like to use [Caddy](https://caddyserver.com/) as your main web server with Pi-hole, you'll need to make a few changes.

## Modifying lighttpd configuration

First, change the listen port in this file: `/etc/lighttpd/lighttpd.conf:`

```lighttpd
server.port = 1080
```

In this case I chose 1080 somewhat at random. Use whatever feels right to you.

Next, restart the lighttpd server with either of these commands:

```bash
sudo systemctl restart lighttpd
```

or

```bash
sudo service lighttpd restart
```

## Setting up your Caddyfile

Now we need to set up a "virtual host" in our Caddyfile (default `/etc/caddy/Caddyfile`). There are many more options you can add, but at bare minimum you need to make a "default" host by binding `0.0.0.0:80`  which will accept requests for any host.

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

In this case I've chosen to also add blackhole and pi.hole as valid names to open the admin page with.

Finally, restart your Caddy server: `sudo service caddy restart`

## Verifying your setup

First, make sure that any other sites you're serving from caddy are still functioning. For example, if you have a block for `myawesomesite.com:80` in your Caddyfile, open up a browser to `http://myawesomesite.com` and verify it still loads.

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
