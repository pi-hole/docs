### Notes & Warnings

- **This is an unsupported configuration created by the community**
- This describes how to use traefik on a (possibly remote) machine to serve pi-hole via https and a different domain, not how to do this in docker (via docker-compose).

### Basic requirements

1. Have a traefik server running anywhere where it can access port 80 of the pihole server. Technically it can run in a docker container though. For LetsEncrypt to work traefik must be reachable on port 80 and 443 from the internet and have the domain.tld pointed at its external address.

2. The following traefik config (traefik.toml)

    ```toml
    debug = false
    checkNewVersion = true
    logLevel = "INFO"
    defaultEntryPoints = ["https","http"]

    [entryPoints]
      [entryPoints.http]
        address = ":80"
        [entryPoints.http.redirect]
          entryPoint = "https"
      [entryPoints.https]
        address = ":443"
        [entryPoints.https.tls]
          # Optional Security Settings
    [retry]

    [docker]
      endpoint = "unix:///var/run/docker.sock"
      domain = "domain.tld"
      watch = true
      exposedbydefault = false

    [acme]
      email = "emailForLetsEncryptACME"
      storage = "acme.json"
      storageFile = "/etc/traefik/acme/acme.json"
      entryPoint = "https"
      OnHostRule = true
      [acme.tlsChallenge]
      [[acme.domains]]
        main = "pihole.domain.tld"

    [file]
      watch = true

    [backends]
      [backends.pihole]
        [backends.pihole.servers.server1]
        url = "http://IP-Of-Pihole:80"

    [frontends]
      [frontends.pihole]
      backend = "pihole"
      passHostHeader = true
        [frontends.pihole.headers]
        STSSeconds = 31536000
        [frontends.pihole.routes.route1]
        rule = "Host:pihole.domain.tld"
    ```

3. Edit your /etc/lighttpd/external.conf to

    ```lighttpd
    $SERVER["socket"] == ":80" {
      # Ensure the Pi-hole Block Page knows that this is not a blocked domain
      setenv.add-environment = ("fqdn" => "true")


      $HTTP["host"] =~ "^pi\.hole" {
          url.redirect = ("^/(.*)" => "https://pihole.domain.tld/$1")
      }
    }
    ```

4. Restart pi-hole's lighttpd and traefik, then you should be able to access your pihole via `https://pihole.domain.tld/`
