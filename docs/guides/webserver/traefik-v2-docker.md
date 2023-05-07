### Notes & Warnings

- **This is an unsupported configuration created by the community**
- This describes how to use [Traefik](https://doc.traefik.io/traefik/) v2 in a Docker container (via docker-compose.yml) to serve the Pi-hole web admin interface via https and includes a permenent http -> https redirect.
- This does not describe how to proxy DNS or DHCP requests to Pi-hole, which is not recommended.
- For ACME challenges, the Traefik container may need to be able to resolve the desired Pi-hole hostname without relying on Pi-hole to do so. Provide this via the `extra_hosts` parameter in your Traefik container's config in docker-compose.yml if needed.
- For LetsEncrypt to work Traefik must be reachable on port 80 and 443 from the Internet and have `domain.tld` pointed at its external address.

### Basic requirements

1. Have a Traefik v2 Docker container running where it can access port 80 of the Pi-hole server.

1. The following Traefik static config (passed as `command` arguments to the Traefik container in docker-compose.yml):

      ```
      - "--providers.docker=true"
      - "--providers.docker.network=traefik-net"  # replace with your configured Docker network name
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.email=your-email@example.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=acme.json"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      ```

1. The next step has 2 scenarios:

   - If Pi-hole is running in a container on the same Docker host as Traefik, put the following `labels` in your Pi-hole container's config in docker-compose.yml:

      ```
      - "traefik.http.routers.pihole.rule=Host(`pihole.domain.tld`)"
      - "traefik.http.routers.pihole.entrypoints=websecure"
      - "traefik.http.routers.pihole.tls=true"
      - "traefik.http.routers.pihole.tls.certresolver=letsencrypt"
      - "traefik.http.routers.pihole.tls.domains[0].main=pihole.domain.tld"
      - "traefik.http.routers.pihole.tls.domains[0].sans=pihole.domain.tld"
      - "traefik.http.services.pihole.loadbalancer.server.port=80"
      ```

   - If Pi-hole is running on a different host, you need to provide the Pi-hole (dynamic) config via a `traefik.yml` file to Traefik. This is best done by bind mounting the local directory containing this file to the `/etc/traefik` directory within the container:

      ```
      # Traefik container config:
      volumes:
        - './traefik/fileproviders:/etc/traefik'
      ```

      ```
      # traefik.yml dynamic config for Pi-hole:
      http:
        routers:
          pihole:
            rule: Host(`pihole.domain.tld`)
            entrypoints: websecure
            tls:
              certresolver: letsencrypt
              domains:
                - main: pihole.domain.tld
                  sans:
                    - pihole.domain.tld
        services:
          pihole:
            loadbalancer:
              servers:
                - url: "http://pihole.domain.tld/"
       ```

1. Restart the Traefik and Pi-hole containers, then you should be able to access your pihole via `https://pihole.domain.tld/`
