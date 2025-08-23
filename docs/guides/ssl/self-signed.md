# Pi-hole v6: Creating Your Own Self-Signed SSL Certificates

## Overview

By default, Pi-hole v6 provides a self-signed SSL certificate, but you can create your own self-signed certificate for Pi-hole that specifies your desired hostnames, fully qualified domain names (FQDN), and IP addresses for your Pi-hole server using **openssl**.

## Prerequisites

Install `openssl`:

```bash
sudo apt update && sudo apt install openssl -y   # For Debian/Ubuntu
sudo yum install openssl -y                      # For RHEL/CentOS
sudo dnf install openssl -y                      # For Fedora
```

This guide assumes:

- `openssl` is installed on the same machine that Pi-hole is installed on, but this is not a requirement -
`openssl` can be installed on a machine that is not running Pi-hole; `tls.pem` just needs to be copied to `/etc/pihole` on the target mahcine running Pi-hole.
- All shell commands are executed from the home directory (e.g., `/home/your_user` or `~/`).

---

## Method 1: Use an Internal Certificate Authority CA (Recommended)

- Pros: All future certificates are trusted once you install the CA cert.
- Cons: Requires setting up a CA.

**Summary:** Set up a CA, sign certificates for each server, and install only one CA certificate instead of trusting multiple self-signed certificates.

### Step 1: Create a directory to hold your cert, config, and key files:

```bash
mkdir -p ~/crt && cd ~/crt
```

### Step 2: Create a Certificate Authority (CA) Key and Certificate

The CA will be used to sign server certificates.

```bash
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days 3650 -keyout homelabCA.key -out homelabCA.crt -subj "/C=US/O=My Homelab CA/CN=MyHomelabCA"
```

- `x509`: Generates a self-signed certificate (for a CA).
- `newkey ec`: Creates a new EC key.
- `pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 curve.
- `nodes`: Skips password protection (optional).
- `-days 3650`: Valid for 10 years.
- `keyout homelabCA.key`: Saves the private key.
- `out homelabCA.crt`: Saves the self-signed CA certificate.
- `subj`: Provides the Distinguished Name (DN) inline:
    - `C=US`: Country
    - `O=My Homelab CA`: Organization (CA)
    - `CN=MyHomelabCA`: Common Name (CA)

The **CA key** (homelabCA.key) and **CA certificate** (homelabCA.crt) is now ready to be used to sign server certificates.

### Step 3: Create a Certificate Configuration File (`cert.cnf`)

```bash
touch cert.cnf && nano cert.cnf
```

Use the attached [cert.cnf](https://gist.github.com/kaczmar2/e1b5eb635c1a1e792faf36508c5698ee#file-cert-cnf) file as a template:

```ini
# Country Name (C)
#Organization Name (O)
#Common Name (CN) - Set this to your server’s hostname or IP address.

# SAN (Subject Alternative Name), [alt-names] is required
# You can add as many hostname and IP entries as you wish

[req]
default_md = sha256
distinguished_name = req_distinguished_name
req_extensions = v3_ext
x509_extensions = v3_ext
prompt = no

[req_distinguished_name]
C = US
O = My Homelab
CN = pi.hole

[v3_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = pi.hole                 # Default pihole hostname
DNS.2 = pihole-test             # Replace with your server's hostname
DNS.3 = pihole-test.home.arpa   # Replace with your server's FQDN
IP.1 = 10.10.10.115             # Replace with your Pi-hole IP
IP.2 = 10.10.10.116             # Another local IP if needed
```

### Step 4: Generate a Key and CSR

Use **Elliptic Curve Digital Signature Algorithm (ECDSA)** to generate both the **private key** (`tls.key`) and **Certificate Signing Request (CSR)** (`tls.csr`).

```bash
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -keyout tls.key -out tls.csr -config cert.cnf
```

- `-newkey ec`: Creates a new EC key.
- `-pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 curve.
- `-nodes` - No password on the private key.
- `-keyout tls.key`: Saves the private key.
- `-out tls.csr`: Saves the certificate signing request (CSR).
- `-config cert.cnf`: Uses the config file for CSR details.

### Step 5: Sign the CSR with the CA

This generates your server certificate from the CSR.

```bash
openssl x509 -req -in tls.csr -CA homelabCA.crt -CAkey homelabCA.key -CAcreateserial -out tls.crt -days 365 -sha256 -extfile cert.cnf -extensions v3_ext
```

- `-req -in tls.csr`: Uses the Certificate Signing Request (CSR) for signing.
- `-CA homelabCA.crt -CAkey homelabCA.key`: Uses our CA to sign the certificate.
- `-CAcreateserial`:Generates a unique serial number.
- `-out tls.crt`: Saves the signed certificate.
- `-days 365`: Valid for 365 days (1 year).
- `-extfile cert.cnf` -extensions v3_ext → Includes Subject Alternative Names (SAN)s.

### Step 6: Create a Combined `tls.pem` File

```bash
cat tls.key tls.crt | tee tls.pem
```

### Step 7: [On Pi-hole Server] Remove existing Pi-hole self-signed cert files:

```bash
sudo rm /etc/pihole/tls*
```

### Step 8: [On Pi-hole Server] Copy `tls.pem` (cert+private key) to Pi-hole directory

```bash
sudo cp tls.pem /etc/pihole
```

### Step 9. [On Pi-hole Server] Restart Pi-hole

```bash
sudo service pihole-FTL restart
```

### Step 10: Install `homelabCA.crt` (CA) in Chrome (this is on your client machine running a browser, for example your Windows PC running Chrome)

Import `homelabCA.crt` into your browser's **Trusted Root Certificate Store**

- Copy `homelabCA.crt` to your local PC
- Open `chrome://certificate-manager` in Chrome
- Click **Manage Imported Certificates**
- Click **Trusted Root Certification Authorities**
- Click **Import, Next, Finish**

### Issuing additional server certificates with your CA (Optional)

You can issue additional certificates for your other servers using the CA you created in **step 2**, and you do not have to re-install the CA certificate in your browser.
Just run the commands listed in **steps 4 and 5** again:

```bash
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -keyout tls2.key -out tls2.csr -config cert2.cnf
```

```bash
openssl x509 -req -in tls.csr -CA homelabCA.crt -CAkey homelabCA.key -CAcreateserial -out tls2.crt -days 365 -sha256 -extfile cert2.cnf -extensions v3_ext
```

---

## Method 2: Use a Self-Signed Certificate and Manually Trust It

- Pros: Simple, no need to set up a CA.
- Cons: Must manually add each self-signed cert to your browser.

**Summary:** Generate a self-signed certificate and install it in your browser. You must manually trust each certificate, so this is adequate for a single server setup.

### Step 1: Create a directory to hold your cert, config, and key files:

```bash
mkdir -p ~/crt && cd ~/crt
```

### Step 2: Create a Certificate Configuration File (`cert.cnf`)

```bash
touch cert.cnf && nano cert.cnf
```

Use the attached [cert.cnf](https://gist.github.com/kaczmar2/e1b5eb635c1a1e792faf36508c5698ee#file-cert-cnf) file as a template:

```ini
# Country Name (C)
#Organization Name (O)
#Common Name (CN) - Set this to your server’s hostname or IP address.

# SAN (Subject Alternative Name), [alt-names] is required
# You can add as many hostname and IP entries as you wish

[req]
default_md = sha256
distinguished_name = req_distinguished_name
req_extensions = v3_ext
x509_extensions = v3_ext
prompt = no

[req_distinguished_name]
C = US
O = My Homelab
CN = pi.hole

[v3_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = pi.hole                 # Default pihole hostname
DNS.2 = pihole-test             # Replace with your server's hostname
DNS.3 = pihole-test.home.arpa   # Replace with your server's FQDN
IP.1 = 10.10.10.115             # Replace with your Pi-hole IP
IP.2 = 10.10.10.116             # Another local IP if needed
```

### Step 3: Generate a key and Self-Signed Certificate

Use **Elliptic Curve Digital Signature Algorithm (ECDSA)** to generate both the **private key** (`tls.key`) and the **Self-Signed Certificate** (`tls.crt`).

```bash
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days 365 -keyout tls.key -out tls.crt -config cert.cnf
```

- `x509`: Creates a self-signed certificate.
- `-newkey ec`: Creates a new Elliptic Curve (EC) key.
- `-pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 (NIST prime256v1) curve.
- `-nodes`: Skips password protection.
- `-days 365`: Valid for 365 days (1 year).
- `-keyout tls.key`: Saves the private key.
- `-out tls.crt`: Saves the self-signed certificate.
- `-config cert.cnf` Uses cert configuration file `cert.cnf` defined above.

### Step 4: Create a Combined `tls.pem` File

```bash
cat tls.key tls.crt | tee tls.pem
```

### Step 5: [On Pi-hole Server] Remove existing Pi-hole self-signed cert files:

```bash
sudo rm /etc/pihole/tls*
```

### Step 6: [On Pi-hole Server] Copy `tls.pem` (cert+private key) to Pi-hole directory

```bash
sudo cp tls.pem /etc/pihole
```

### Step 7. [On Pi-hole Server] Restart Pi-hole

```bash
sudo service pihole-FTL restart
```

### Step 8: Install `tls.crt` (cert) in Chrome (this is on your client machine running a browser, for example your Windows PC running Chrome)

Import `tls.crt` into your browser's **Trusted Root Certificate Store**

- Copy `tls.crt` to your local PC
- Open `chrome://certificate-manager` in Chrome
- Click **Manage Imported Certificates**
- Click **Trusted Root Certification Authorities**
- Click **Import, Next, Finish**

## Installation of Self-Signed Certs for Mobile Devices

- See: Pi-hole API > [TLS/SSL](../../api/tls.md)
