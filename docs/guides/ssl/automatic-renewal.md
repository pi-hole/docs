# Automating Certificate Renewal

## Overview

By default, Pi-hole v6 provides a self-signed SSL certificate, but you can automate certificate renewal with acme.sh, Cloudflare and Let's Encrypt.

This guide uses:

- [acme.sh](https://github.com/acmesh-official/acme.sh?tab=readme-ov-file#an-acme-shell-script-acmesh): An ACME shell script.
- [Cloudflare DNS](https://www.cloudflare.com/application-services/products/dns/).
- [Let’s Encrypt](https://letsencrypt.org/).

## Prerequisites

- **Pi-hole installed and running** on your system.  
- **A Cloudflare account** that manages your domain’s DNS records.  
- **Control of a registered domain** (e.g., `mydomain.com`). 

These prerequisites ensure that you can successfully request and install an SSL certificate using **Cloudflare DNS validation** with `acme.sh`.
This guide uses **Cloudflare DNS** and **Let’s Encrypt**. These instructions can be adapted for any DNS provider and Certificate Authority (CA) that `acme.sh` supports. Simply update the `--dns` and `--server` flags accordingly when issuing your certificate.

**Note:** This guide assumes that `acme.sh` runs under the `root` user. The `--reloadcmd` contains commands that require `sudo`, such as removing old certificates, writing the new certificate, and restarting Pi-hole FTL. If you prefer to run `acme.sh` as a regular user, additional configuration is required to allow these commands to execute without a password. Methods for achieving this, such as configuring `sudo` rules, are beyond the scope of this article.

## **1. Install acme.sh as `root`**

Run a login shell as root:
```
sudo -i
```

Install it:
```bash
curl https://get.acme.sh | sh -s email=my@example.com
```

Reload .bashrc to register the acme.sh alias:
```
source .bashrc
```

Verify installation:
```bash
acme.sh --version
```

---

## **2. Set Up Cloudflare DNS API**
For **DNS-based domain verification**, export your **Cloudflare API token**:

```bash
export CF_Token="ofz...xxC"
export CF_Email="me@mydomain.com"
```
This allows `acme.sh` to create the required DNS records automatically.

---

## **3. Issue the SSL Certificate for Pi-hole**
Run:
```bash
acme.sh --issue --dns dns_cf -d ns1.mydomain.com --server letsencrypt
```
This generates:
- **Private key**: `ns1.mydomain.com.key`
- **Full-chain certificate**: `fullchain.cer` (includes `ns1.mydomain.com.cer` + `ca.cer`, in that order)


You do not need these other certificate files:
- **Server certificate**: `ns1.mydomain.com.cer` (included in `fullchain.cer`)
- **Intermediate CA cert**: `ca.cer` (included in `fullchain.cer`)

---

## **4. Install and Apply the SSL Certificate to Pi-hole**
Pi-hole **requires a PEM file** containing **both the private key and server certificate**.

Install the certificate:
```bash
acme.sh --install-cert -d ns1.mydomain.com \
  --reloadcmd "sudo rm -f /etc/pihole/tls* && \
  sudo cat fullchain.cer ns1.mydomain.com.key | sudo tee /etc/pihole/tls.pem && /
  sudo service pihole-FTL restart"
```

This:

- Deletes old certificates (`/etc/pihole/tls*`).
- Creates `tls.pem` with both the full-chain certificate file and private key, in that order.
- Restarts Pi-hole FTL to apply the new certificate.

---

## **5. Configure Pi-hole**
To avoid domain mismatch warnings (`CERTIFICATE_DOMAIN_MISMATCH`), set the **correct hostname**:

```bash
sudo pihole-FTL --config webserver.domain 'ns1.mydomain.com'
sudo service pihole-FTL restart
```

Fixes:  
```
CERTIFICATE_DOMAIN_MISMATCH SSL/TLS certificate /etc/pihole/tls.pem does not match domain pi.hole!
```

---

## **Notes**
- Your **certificate renews automatically** via `acme.sh`'s cron job.
- You can manually renew with:
  ```bash
  acme.sh --renew -d ns1.mydomain.com --force
  ```
- To check your certificate:
  ```bash
  sudo openssl x509 -in /etc/pihole/tls.pem -text -noout
  ```
