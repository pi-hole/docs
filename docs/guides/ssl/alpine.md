# Configure SSL with Alpine


## Dehydrated

Dehydrated is a client for signing certificates with an ACME-server (e.g. Let's Encrypt) implemented as a relatively simple (zsh-compatible) bash-script.

Install the [dehydrated](https://github.com/dehydrated-io/dehydrated) package:

```shell
sudo apk add dehydrated
```

Example `/etc/dehydrated/domains.txt`:

```text
pihole.example.com
```

### Cloudflare DNS challenge

To use the Cloudflare DNS challenge, install [cfhookbash](https://github.com/sineverba/cfhookbash) per the Readme

Example install:

```shell
cd /lib
git clone https://github.com/sineverba/cfhookbash.git
```
Example `/lib/cfhookbash/deploy.sh`:

```shell
case ${1} in
  "pihole.example.com")
    # Remove the old certificate
    rm -f /etc/pihole/tls*

    # Pi-hole requires a PEM file containing both the private key and server certificate.
    # Install the certificate:
    cat /var/lib/dehydrated/certs/pihole.example.com/fullchain.pem /var/lib/dehydrated/certs/pihole.example.com/privkey.pem > /etc/pihole/tls.pem

    #restart pihole
    service pihole restart
  ;;

esac
```

Example crontab entry:

```crontab
0       4       *       *       *       dehydrated --cron --cleanup-delete --challenge dns-01 --hook "/lib/cfhookbash/hook.sh" >> /tmp/cfhookbash-`date +\%Y-\%m-\%d-\%H-\%M-\%S`.log 2>&1
```

