# Nginx Reverse Proxy for Pi-hole v6

This guide covers step by step the `Nginx` reverse proxy configuration for Pi-hole v6 and the benefits of this deployment.

<!-- markdownlint-disable code-block-style -->
!!! info "Key Changes in v6"
    Unlike Pi-hole v5, version 6 no longer relies on `lighttpd`. The new architecture features a built-in web server within `pihole-FTL`. This change significantly simplifies reverse proxy configurations as there are no longer conflicting external web server dependencies to manage by default.

    Since Pi-hole v6 handles its own web interface and API directly, `Nginx` simply acts as a (secure) gateway, without the need for complex fastcgi or PHP-fpm passthroughs.
<!-- markdownlint-enable code-block-style -->

<!-- markdownlint-disable code-block-style -->
!!! danger "Security Warning: Exposure to the Internet"
    Exposing your Pi-hole directly to the open internet is **strongly discouraged**. Doing so can make your instance a target for unauthorized access and cyber-attacks. If you choose to do so, it is your responsibility to follow security best practices, including for example, but not limited to:

    - Using strong, unique passwords;
    - Implementing Multi-Factor Authentication (MFA);
    - Restricting access via VPN or IP whitelisting;
    - etc

    **Disclaimer:** Utilizing `Nginx` as a reverse proxy does not automatically guarantee safety against all vulnerabilities associated with internet exposure. This guide focuses exclusively on the generic configuration of `Nginx` as a web proxy with some security tips; it does not cover, nor is it intended to cover, the advanced hardening techniques required for public internet exposure. Neither this guide nor the Pi-hole team shall be held responsible for any security breaches, data loss, or damages resulting from your network configuration.
<!-- markdownlint-enable code-block-style -->

---

## Network Mapping & Port Alignment

### Ports layout

To avoid conflicts with `Nginx` or other services running on your system, we need to move Pi-hole v6 away from the standard HTTP port (80).

In this guide, we will use **8053** as the internal port for Pi-hole, while `Nginx` will handle the external secure traffic on port **453** (or any other port you prefer). Additionally, we will also set up an external HTTP port **8080** in `Nginx` to demonstrate how to automatically redirect HTTP traffic to the secure HTTPS port.

| Accessible From | Service | Protocol | Port |
| :--- | :--- | :---: | :---: |
| **Internet / LAN / Anywhere** | Nginx | HTTP | `8080` |
| **Internet / LAN / Anywhere** | Nginx | HTTPs | `453` |
| **Localhost only (127.0.0.1)** | Pi-hole FTL | HTTP | `8053` |

<!-- markdownlint-disable code-block-style -->
!!! info "SSL/TLS Certificates"
    Do not use Pi-hole's internal certificates for the web server. `Nginx` Nginx is not notified when Pi-hole renews its certificates on disk, it will continue to serve the old (expired) ones.

    `Nginx` requires a restart or reload to apply updated certificates, a process that is not handled automatically. Managing this would require cumbersome scripts and timers; therefore, it is highly recommended to generate certificates independently using dedicated tools like **Certbot** or similar, which can use hooks to reload `Nginx` seamlessly upon renewal.
<!-- markdownlint-enable code-block-style -->

<!-- markdownlint-disable code-block-style -->
!!! security "Security Note"
    Since `Nginx` will handle SSL/TLS termination and encryption for external traffic, we will not connect to Pi-hole's native SSL/TLS for the internal connection. This simplifies the communication between `Nginx` and Pi-hole (localhost), as encryption is not strictly required for traffic that never leaves the machine.

    By binding the Pi-hole dashboard to `127.0.0.1` only, it is no longer exposed to your entire network. Only `Nginx` (running on the same machine) can "talk" to it. This effectively creates a "security air-lock."
<!-- markdownlint-enable code-block-style -->

### Update Pi-hole's Configs

You must instruct Pi-hole to stop listening on port 80, 443 or any other ports and switch to our (arbitrary choosen) port **8053**. Additionally, for sake of security, we will restrict its web interface to listen only on the local interface (`127.0.0.1`), ensuring it is only accessible via the `Nginx` proxy.

You can apply the change using the `pihole-FTL` command line configuration tool:

```bash
# Binding to localhost's custom port only
sudo pihole-FTL --config webserver.port "127.0.0.1:8053"
```


## Nginx configuration

Before proceeding with the configuration, please keep in mind the following workflow. To ensure stability and avoid service interruptions, we will consistently use two main commands:

1. **`sudo nginx -t`**: This is the most important command. It performs a full test of your configuration files without applying them; if any syntax errors exist, it will highlight them immediately; otherwise, it returns `syntax is ok` and `test is successful`;
2. **`sudo systemctl restart nginx.service`**: This command should **only** be executed if the previous test completes successfully.

!!! note "User Responsibility"
    If `sudo nginx -t` reports an error, do not restart the service. Since network environments and custom configurations vary, you will need to troubleshoot any specific errors based on your personal setup. This guide focuses on the standard proxy implementation; ensuring compatibility with pre-existing configurations remains the user's responsibility.

### Installation and Clean-up

This section is intended for users who do not have `Nginx` installed yet or wish to start with a fresh configuration dedicated to Pi-hole.

1. **Install Nginx**

    ```bash
    sudo apt update
    sudo apt install -y nginx nginx-extras
    ```

2. **Clean up default configurations and restart**

    Before proceeding adding the Pi-hole dedicated configurations, it is recommended to remove or at least deactivate, according to your distribution configuration, the default *"Welcome to Nginx"* site to avoid potential/hypothetical conflicts.

    ```bash
    sudo systemctl restart nginx.service
    ```

### Configure the HTTP redirect to HTTPS (Optional)

This configuration is intended **only** for users who wish to automatically redirect incoming traffic from a non-encrypted port to the secure HTTPS port.

In this example, we will use port **8080** as the external HTTP to avoid possible conflicts with other services; it will "force" the redirect of all traffic toward the secure port **453** (used in this guide).

!!! info "Scope"
    This redirect applies only to the **external/exposed** ports. Internal communication between `Nginx` and Pi-hole remains on port `8053` and is unaffected by this rule.

1. **Create the redirect file configuration**

    Place the following file in your Nginx configuration path (e.g., `/etc/nginx/conf.d/` or `/etc/nginx/sites-available/` depending on your distribution configuration).

    ```bash
    sudo nano pihole_v6_http_redirect.conf
    ```

2. **Copy and paste the following server block**

    ```nginx
    # ------------------------------------------------------------
    # Pi-hole v6 - Nginx HTTPS Redirect
    # ------------------------------------------------------------

    # HTTP Server (Port 8080)
    server {
        listen 8080; # IPv4
        listen [::]:8080; # Comment if you don't want IPv6

        server_name _; # Or your domain/IP

        # Redirect all HTTP requests to HTTPS
        return 301 https://$host:453$request_uri;
    }
    ```

3. **Enable, test and restart `Nginx`**

    Once the `pihole_v6_http_redirect.conf` file is saved and enabled, verify configurations and restart the service:

    ```bash
    sudo nginx -t
    sudo systemctl restart nginx.service
    ```

!!! tip "Firewall Reminder"
    If you are using a firewall (like `ufw`), be sure to allow traffic on port **8080** or the redirection won't work:
    `sudo ufw allow 8080/tcp`

<!-- markdownlint-disable code-block-style -->
!!! warning "Connection Refused / Unable to Connect"
    At this stage of the guide, if your browser successfully redirects you to the HTTPS port but then shows **"Unable to Connect"**, don't panic. This occurs because the `Nginx` HTTP redirection is active, but the HTTPS Proxy and the relative bridge to the backend isn't configured yet.

    You must now proceed to the next step: [Configure the HTTPS Proxy ](#configure-the-https-proxy).
<!-- markdownlint-enable code-block-style -->

### Configure the HTTPS Proxy

1. **Generate the required Pi-hole SSL/TLS files**

    We generate the private key and a Certificate Signing Request (CSR). In real world, we should send the generated CSR to the CA for the signing, getting back the Certificate; in this guide (at command #4) we directly self-sign them, or in a Private PKI environments, we autonomusly sign it with the Private CA.

    ```bash
    # 1. Prepare the Nginx SSL/TLS Directory
    sudo mkdir -p /etc/nginx/ssl

    # 2. Generate Pi-hole private key (using NIST P-521 curve)
    sudo openssl ecparam -genkey -name secp521r1 -out /etc/nginx/ssl/pihole.key
    # Read Pi-hole private key
    sudo openssl pkey -text -noout -in /etc/nginx/ssl/pihole.key

    # 3. Generate Pi-hole Certificate Signing Request (CSR)
    sudo openssl req -sha512 -nodes -new \
      -subj "/C=IT/ST=Italy/L=Milan/O=Pi-hole/CN=pi.hole" \
      -addext "subjectAltName = DNS:pi.hole,DNS:*.pi.hole" \
      -key /etc/nginx/ssl/pihole.key \
      -out /etc/nginx/ssl/pihole.csr
    # Read Pi-hole CSR
    sudo openssl req -text -noout -in /etc/nginx/ssl/pihole.csr

    # 4. Self-sign the Pi-hole certificate (Valid for 1 years)
    echo "subjectKeyIdentifier=hash" > /tmp/openssl.cnf
    echo "authorityKeyIdentifier=keyid:always,issuer" >> /tmp/openssl.cnf
    echo "basicConstraints=critical,CA:FALSE" >> /tmp/openssl.cnf
    echo "keyUsage=critical,digitalSignature,keyEncipherment" >> /tmp/openssl.cnf
    echo "extendedKeyUsage=serverAuth" >> /tmp/openssl.cnf
    echo "subjectAltName=DNS:pi.hole,DNS:*.pi.hole" >> /tmp/openssl.cnf
    sudo openssl x509 -req -sha512 -days 365 \
      -signkey /etc/nginx/ssl/pihole.key \
      -in /etc/nginx/ssl/pihole.csr \
      -out /etc/nginx/ssl/pihole.crt \
      -extfile /tmp/openssl.cnf
    sudo rm -rf /tmp/openssl.cnf
    # Read Pi-hole certificate
    sudo openssl x509 -text -noout -in /etc/nginx/ssl/pihole.crt
    ```

2. **Create the proxy file configuration**

    Place the following file in your `Nginx` configuration path (e.g., `/etc/nginx/conf.d/` or `/etc/nginx/sites-available/` depending on your distribution configuration).

    ```bash
    sudo nano pihole_v6.conf
    ```

3. **Copy and paste the following server block**

    ```nginx
    # ------------------------------------------------------------
    # Pi-hole v6 - Nginx Reverse Proxy
    # ------------------------------------------------------------

    upstream pihole_v6 {
        server 127.0.0.1:8053; # Ensure this matches your real FTL port settings
        keepalive 16;
    }

    # HTTPS Server (Port 453)
    server {
        listen 453 ssl; # IPv4
        listen [::]:453 ssl; # IPv6 (comment out if not needed)

        # --- HTTP/2 SUPPORT ---
        # For Nginx >= 1.25.1: Use the standalone directive below
        http2 on; 
        # For Nginx < 1.25.1: Comment "http2 on" above and 
        # append "http2" to the listen lines (e.g., listen 453 ssl http2;)
        
        server_name _; # Or your domain/IP

        # --- SSL/TLS ---
        ssl_certificate_key /etc/nginx/ssl/pihole.key;
        ssl_certificate /etc/nginx/ssl/pihole.crt;
        # Intermediate Mozilla's security standards
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ecdh_curve X25519MLKEM768:X25519:prime256v1:secp384r1:secp521r1;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
        ssl_prefer_server_ciphers off;

        # --- SECURITY ---
        # Restricted HTTP Methods: Allow only methods mentioned in API docs
        # and block everything else (e.g., TRACE, CONNECT);
        # this prevents potential exploit attempts using uncommon request methods.
        if ($request_method !~ ^(GET|HEAD|POST|PATCH|PUT|DELETE)$ ) { return 405; }
        # HSTS (ngx_http_headers_module is required) (63072000 seconds)
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;

        # --- ERROR RESOLUTION: 413 & 414 ---
        # Fixes 413 (Request Entity Too Large)
        # Increases allowed body size from 1M to 2M
        client_max_body_size 2M;
        # Fixes 414 (Request-URI Too Large)
        # Allocates 4 buffers of 8k for large request headers as per default
        large_client_header_buffers 4 8k;

        # --- AUTHENTICATION ---
        # Basic Auth
        #auth_basic "Restricted";
        #auth_basic_user_file /etc/nginx/.htpasswdpihole;
        # mTLS 
        #ssl_client_certificate /etc/nginx/ssl/CertificateAuthority.pem;
        #ssl_verify_client on;

        # Permanent Redirect (301) to /admin
        location = / {
            return 301 /admin;
        }

        location / {
            proxy_pass http://pihole_v6;

            # Standard Proxy Headers
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Sends the original host header explicitly.
            proxy_set_header X-Forwarded-Host $host;

            # Sends the hostname of the proxy server.
            proxy_set_header X-Forwarded-Server $host;

            # Defines how long Nginx will wait when trying to establish a TCP connection to the upstream server.
            proxy_connect_timeout 60s;
            # Defines how long Nginx will wait while sending data to the upstream (i.e., uploading request body).
            proxy_send_timeout 60s;
            # Defines how long Nginx waits for a response from the upstream after the request is sent.
            proxy_read_timeout 60s;
        }
    }
    ```

4. **Enable, test and restart `Nginx`**

    Once the `pihole_v6.conf` file is saved and enabled, verify configurations and restart the service:

    ```bash
    sudo nginx -t
    sudo systemctl restart nginx.service
    ```

!!! tip "Firewall Reminder"
    If you are using a firewall (like `ufw`), be sure to allow traffic on port **453** or the redirection won't work:
    `sudo ufw allow 453/tcp`

#### Understanding the Configuration

##### The Upstream Block

The `upstream` block defines the backend server where Nginx will forward the incoming traffic. It acts as a bridge between the external web server and the internal Pi-hole service.

The `keepalive 16` setting improves performance by keeping up to 16 idle connections open between `Nginx` and Pi-hole. Instead of opening and closing a new connection for every single request (like loading different icons or scripts on the dashboard), `Nginx` reuses existing ones, reducing latency and CPU overhead.

!!! tip "Troubleshooting"
    If you ever change the Pi-hole internal port (e.g., using `webserver.port`), you must update the address in this `upstream` block as well, otherwise `Nginx` will return a **502 Bad Gateway** error.

##### HTTP/2 Support

The `http2` directive is essential for modern web performance, allowing the browser to load multiple assets simultaneously over a single connection. However, the way Nginx handles this setting has changed recently:

- **For Modern Systems (Nginx 1.25.1 and newer):** `Nginx` has introduced a standalone `http2 on;` directive. This is the preferred method as it clearly separates the connection protocol from the listening port configuration.
- **For Older Systems:** In previous versions, HTTP/2 was enabled by appending the keyword `http2` directly to the listen line (e.g., `listen 453 ssl http2;`).

!!! note "Version Check"
    You can check your currently installed version by running `sudo nginx -v`.

##### SSL/TLS Certificates

In this guide, we have created a *Self Signed Certificate* as explained the process. You are invited to use your own certificate, self-signed or signed by a Public/Private CA, customize the configuration accordingly.

Furthermore, this configuration follows the [intermediate Mozilla's security standards](https://ssl-config.mozilla.org/#server=nginx&version=1.27.3&config=intermediate&openssl=4.0.0&hsts&guideline=6.0). You can review the settings or stay updated by visiting the [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org).

##### HTTP Methods Filtering

To harden your setup, we implement a filter on the types of HTTP requests the server will accept; the `$request_method` line acts as a security gatekeeper; this minimizes the attack surface by blocking unexpected request types.

The `$request_method` filtering in the configuration above is strictly aligned with the [HTTP methods reported by the Pi-hole API documentation](/api/); any other method will return a `405 Method Not Allowed` error.

##### Security Headers

These header can add a layer of protection by instructing the user's browser how to handle the site's content securely:

- **Strict-Transport-Security:** Forces the browser to communicate with the server exclusively over HTTPS. By setting a `max-age` (in this case, 2 years), it ensures that even if you try to access the site via HTTP, the browser will automatically redirect to the secure version before any data is sent. The `includeSubDomains` flag extends this protection to all related subdomains.
- **Pi-hole defaults:** Pi-hole already handles specific headers; it is better to avoid overriding them in `Nginx` as well. You can check the Pi-hole configuration via command line: `pihole-FTL --config webserver.headers`

!!! info "Implementation Note"
    It is important to note that since `Nginx` acts as the entry point, these security headers are sent directly to the end-user's browser, providing a robust shield managed entirely by the web server.

##### Error Resolution (413 and 414)

The 2 directives are specifically placed to prevent common errors that can occur when interacting with the Pi-hole v6 web interface, especially during heavy administrative tasks or in presence of other custom settings inherited from a more restrictive global configuration.

- **`client_max_body_size 2M`**: By default, `Nginx` limits the body size of a request to **1M**. If a request exceeds this value, `Nginx` returns a **413 (Request Entity Too Large)** error. In Pi-hole, this can happen when saving settings or updating complex configurations through the UI. Raising this limit to **2M** ensures these operations complete smoothly without interruption.
- **`large_client_header_buffers 4 8k`**: This directive defines the number and size of buffers used for reading large request headers. A request line cannot exceed the size of a single buffer, or a **414 (Request-URI Too Large)** error is returned. The value adopted is just the `Nginx` default one. In case of more restrictive values, you will likely encounter errors when visiting the **Query Log** page without this.

##### Authentication

The Authentication section in the configuration is provided as an optional security enhancement and is **commented out by default**.
These directives allow you to implement **Basic Password Authentication** or **Client Certificate Verification (mTLS)**. By keeping them commented, Nginx will rely solely on Pi-hole's internal login system. If you wish to add this extra layer of security at the proxy level, you can find the step-by-step setup instructions and the security implications in the **[Additional Pre-Authentication](#additional-pre-authentication)** section of this guide.

##### Redirect to admin

By default, Pi-hole's web interface is located at the `/admin` path. To make accessing the dashboard faster and more intuitive, we add a specific `location` block for the root URL.


## HINTS

### Additional Pre-Authentication

While Pi-hole v6 has its own authentication, you can add an additional layer of security directly at the `Nginx` level. This is particularly useful if your dashboard is exposed to a local network with multiple users or via a VPN.

The lines in the proxy configuration file are commented out to prevent errors; however, depending on your preferences, you can configure and uncomment them to enable them by following the instructions below.


#### Choosing the Right Method

| Method | Best For | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Basic Auth** | General use | Works on any device, easy to set up. | Vulnerable to brute-force if not protected. |
| **mTLS** | Maximum security | Virtually impossible to bypass without the physical certificate file. | Complex to manage (requires installing certificates on every phone/PC), and the level of security relies on the encryption algorithm and key size chosen (weak = can theoretically be compromised) |

<!-- markdownlint-disable code-block-style -->
!!! tip "Combining Methods"
    For most users, **Basic Auth** is the perfect balance between security and convenience. If you are a power user seeking a **Zero Trust** environment, **mTLS** is the gold standard.

    Combining Methods is not suggested for average users, to avoid complex debugging to fix the issues and errors.
<!-- markdownlint-enable code-block-style -->


#### Basic Authentication (User/Password)

This method prompts a standard browser login popup before the Pi-hole interface even starts to load.

For further details, please refer to the [official Nginx documentation](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/).


1. **Install the utility:**
    You need `apache2-utils` (which contains the `htpasswd` tool)

    ```bash
    sudo apt update
    sudo apt install -y apache2-utils
    ```

2. **Create the password file:** When creating a password file for `Nginx`, it is vital to store it in a secure location and restrict its permissions so that only the web server can read it. We store the file in `/etc/nginx/`, this directory is standard for configuration and is protected by root permissions. You will be prompted to enter a password. Remember to replace `PIHOLE` with your chosen custom name for the login and feel free to customize the file name `.htpasswdpihole`.

    ```bash
    sudo htpasswd -B -C 6 -c /etc/nginx/.htpasswdpihole PIHOLE
    ```

    !!! security "Why those flags?"
        - **`-B` (Bcrypt)**: Forces the use of the `Bcrypt` hashing algorithm. This is considered the modern standard for password security because it is specifically designed to be slow and computationally expensive for attackers to "brute-force."
        - **`-C 6` (Cost Factor)**: This sets the computing time used for the hashing. Default is 5 and are accepted between 4 to 17. An higher number increases the work required to crack the password. We use **`6`** as a balanced value for Pi-hole.

    <!-- markdownlint-disable code-block-style -->
    !!! danger "The Performance Trade-off"
        It is important to understand that `Nginx` must verify this hash for **every single request** (images, scripts, API calls) that isn't handled by a persistent connection.

        If you set the Cost Factor too high (e.g., 12 or 14), the CPU will spend significant time just "thinking" to validate each element of the dashboard. During a page refresh, where dozens of small elements are loaded, a high cost factor can lead to an **exponential increase in load times** and high CPU spikes, making the interface feel sluggish or unresponsive. A value of `6` provides robust security without sacrificing the fluidity of your Pi-hole dashboard.
    <!-- markdownlint-enable code-block-style -->


3. **Change Ownership of the password file:** `Nginx` usually (and for this guide too) runs under the user `www-data`. For security reasons, the password file should be owned by **root**, but the **group** should be set to `www-data` so the web server can access it; the permissions must be set to `640`

    ```bash
    sudo chown root:www-data /etc/nginx/.htpasswdpihole
    sudo chmod 640 /etc/nginx/.htpasswdpihole
    ```

    <!-- markdownlint-disable code-block-style -->
    !!! security "Why these permissions?"
        By setting the permissions to `640`, you ensure that:

        - **Root** (Read/Write) can modify the passwords.
        - **Nginx (www-data)** (Read) can read the file to authenticate you.
        - **Other users** (None) on the system cannot see the file nor attempt to crack the hashes offline.
    <!-- markdownlint-enable code-block-style -->


4. **Edit the configuration and enable it:** Uncomment the following lines in the configuration

    ```bash
    sudo nano /etc/nginx/sites-available/pihole_v6
    ```

    ```nginx
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswdpihole;
    ```

5. **Test and restart `Nginx`:**

    ```bash
    sudo nginx -t
    sudo systemctl restart nginx
    ```

<!-- markdownlint-disable code-block-style -->
!!! danger "Login without prompt"
    Including credentials directly in the URL is a possible practice; while it works, it is widely considered a major security anti-pattern. Example: [https://PIHOLE:password@pi.hole](https://PIHOLE:password@pi.hole)

    Entering credentials in the URL is significantly more dangerous than using a standard login prompt or form, even when using HTTPS. While HTTPS encrypts the data during transit (preventing **"Man-in-the-Middle"** attacks from seeing the URL), it does not protect the credentials once they reach the device or the server.
<!-- markdownlint-enable code-block-style -->


#### Client Certificate Verification (mTLS Certificate)

This is a high-security "passwordless" method. `Nginx` will only allow access if the device (browser) presents a valid certificate signed by a Certificate Authority (CA) that you trust (Public or Private).

For further details, please refer to the [official Nginx documentation](https://docs.nginx.com/nginx-instance-manager/system-configuration/secure-traffic/#mutual-client-certificate-authentication-setup-mtls).

!!! info "Educational Note"
    In the following steps we show how to create a **Minimal Private CA certificate** for testing purposes. In a production environment, you might use a certificate from a Trusted Public CA or a secure established private PKI.

1. **Prepare the Nginx SSL/TLS Directory**
    First, create a dedicated folder to store the CA certificate that `Nginx` will use to verify clients.

    ```bash
    sudo mkdir -p /etc/nginx/ssl
    ```

2. **Create a Minimal Private CA Certificate (Test Purpose Only)**
    Even for a single user, TLS protocol requires the client certificate to be signed by a CA. Here we generate a self-signed Private CA using the **ECDSA** (Elliptic Curve) algorithm.

    ```bash
    # Generate CA private key (using NIST P-521 curve)
    sudo openssl ecparam -genkey -name secp521r1 -out /etc/nginx/ssl/CertificateAuthority.key
    # Read CA private key
    sudo openssl pkey -text -noout -in /etc/nginx/ssl/CertificateAuthority.key

    # Generate the CA certificate (Self-signed, valid for 10 years)
    sudo openssl req -x509 -sha512 -nodes -days 3650 \
      -key /etc/nginx/ssl/CertificateAuthority.key \
      -out /etc/nginx/ssl/CertificateAuthority.pem \
      -subj "/C=IT/ST=Italy/L=Milan/O=MyOrg/CN=MyPrivateCA" \
      -addext "subjectKeyIdentifier=hash" \
      -addext "authorityKeyIdentifier=keyid:always,issuer" \
      -addext "basicConstraints=critical,CA:true"
    # Read CA certificate
    sudo openssl x509 -text -noout -in /etc/nginx/ssl/CertificateAuthority.pem
    ```

3. **Generate the Client Certificate**
    We generate the private key for the user and a Certificate Signing Request (CSR). In real world, we should send the generated CSR to the CA for the signing, getting back the Certificate; in this guide (at command #3), and in Private PKI environments, we autonomusly sign it with our Private CA.

    ```bash
    # 1. Generate Client private key (using NIST P-521 curve)
    openssl ecparam -genkey -name secp521r1 -out client.key
    # Read Client private key
    openssl pkey -text -noout -in client.key

    # 2. Generate Client Certificate Signing Request (CSR)
    openssl req -sha512 -nodes -new -key client.key -out client.csr \
      -subj "/C=IT/ST=Italy/L=Milan/O=MyOrg/CN=UserTest" \
      -addext "extendedKeyUsage = clientAuth"
    # Read Client CSR
    openssl req -text -noout -in client.csr

    # 3. Sign the Client certificate with our Private CA (Valid for 1 years)
    sudo openssl x509 -req -sha512 -days 365 \
      -CA /etc/nginx/ssl/CertificateAuthority.pem \
      -CAkey /etc/nginx/ssl/CertificateAuthority.key \
      -in client.csr -out client.crt
    # Adjust ownership of the generated certificate
    sudo chown $(id -u):$(id -g) client.crt
    # Read Client certificate
    openssl x509 -text -noout -in client.crt
    ```

4. **Export to PKCS#12 for Browser Installation**
    To use this certificate in a browser (Chrome, Firefox, Safari), must be converted into a `.p12` bundle.

    ```bash
    # Bundle Client data to PKCS#12
    openssl pkcs12 -export \
      -certfile /etc/nginx/ssl/CertificateAuthority.pem \
      -inkey client.key -in client.crt \
      -out client.p12 \
      -macalg SHA512 -iter 100000 \
      -keypbe AES-256-CBC -certpbe AES-256-CBC \
      -pbmac1_pbkdf2 -pbmac1_pbkdf2_md SHA512 \
      -name "MyPiholeLoginCertificate" \
      -passout pass:abcdef123456
    # Read Client p12 certificate
    openssl pkcs12 -info -in client.p12 \
      -nodes -passin pass:abcdef123456
    ```

    !!! danger "Change the PKCS#12 password"
        In this guide, to speed up the command execution, the **weak** password `abcdef123456` has been used; we reccomend to choose a strong password and do not pass it via command line to keep it as secret as possible.

    !!! tip "TLS/SSL Installation"
        - **Trust:** You may also need/want to import the `CertificateAuthority.pem` as a Trusted Root CA if it is a private one. Detailed instructions can be found in the [Pi-hole Official Documentation](/api/tls/#adding-the-ca-to-your-browser);
        - **Browser:** Import the `client.p12` file into your browser's certificate manager (Settings > Security > Manage Certificates > Your Certificates); it is similar to precedent point, so you can read the [Pi-hole Official Documentation](/api/tls/#adding-the-ca-to-your-browser);
        - **Issue during import:** In case of issue while importing the `client.p12` file into your browser, try to add the parameter `-legacy` to the *export* command;

5. **Enable mTLS in `Nginx`**
    Uncomment the following lines in your `Nginx` proxy configuration:

    ```bash
    sudo nano /etc/nginx/sites-available/pihole_v6
    ```

    ```nginx
    ssl_client_certificate /etc/nginx/ssl/CertificateAuthority.pem;
    ssl_verify_client on;
    ```

6. **Test and restart `Nginx`:**

    ```bash
    sudo nginx -t
    sudo systemctl restart nginx
    ```

    !!! danger "Warning for mTLS"
        If you restart `Nginx` with `ssl_verify_client on;` and you do not have the client certificate installed in your browser, you will be completely locked out with a **400 Bad Request (No required SSL certificate was sent)** error. In case of errors, you have to comment back the lines and restart `Nginx`.

<!-- markdownlint-disable code-block-style -->
!!! tip "Cryptographic Compatibility Matrix"
    When generating certificates for web browsers, you must be careful with the choice of algorithms:

    - **Supported**: **RSA** and **ECDSA** (specifically NIST curves like **P-256**, **P-384**, and **P-521**) are the current standards widely accepted by all major browsers and operating systems.
    - **Unsupported**: Do **not** use Edwards-curve Digital Signature Algorithm (EdDSA) such as **Ed25519** or **Ed448** for client certificates. While highly secure and efficient, they are frequently **not supported** for mTLS authentication in many browsers (including Chrome and Firefox), or Certificates in general, and will result in a connection failure that is difficult to debug and impossible to solve without enhancement and development from the software in use.
<!-- markdownlint-enable code-block-style -->


## Troubleshooting

### `Nginx` crashes due to HTTP/2

If `Nginx` fails to start or throws a syntax error regarding the `http2` directive, it is likely due to an `Nginx` version mismatch. Please refer to the [HTTP/2 Support](#http2-support) section to check your Nginx version and apply the appropriate syntax (latest vs. legacy).

### Blank or missing error text

When the `http2` directive is active, certain application-level errors that are normally displayed in the browser might appear as blank/empty text or generic connection errors.
If you are debugging an issue like that one, temporarily disable `http2`, reload `Nginx`, and check again. This (combined with checking the `Nginx` logs) will help you see the specific error message. Remember to re-enable it once the issue is resolved.

### Errors when saving settings (Error 413)

If you encounter errors specifically when clicking "Save" or "Update" within the Pi-hole settings pages, it is likely that the request body exceeds the configured `Nginx` limit. Verify that `client_max_body_size` is set to at least `2M`. Refer to the [Error Resolution (413 and 414)](#error-resolution-413-and-414) section for more information.

### Query Log issues (Error 414)

If you experience **414 (Request-URI Too Large)** errors, see blank logs, or get continuous error pop-ups when accessing the **Query Log** (or clicking on dashboard graphs), ensure your `large_client_header_buffers` is correctly set. This directive is essential for handling the long URLs generated by Pi-hole's filtering system. Refer to the [Error Resolution (413 and 414)](#error-resolution-413-and-414) section for more information.

### Common Issues

- **Port Mismatch:** If `Nginx` returns a `502 Bad Gateway`, double-check that `pihole-FTL` is actually listening on port `8053` (the default port for v6 web interface).
- **Permission Denied during Authentication:** Ensure `Nginx` has the necessary permissions to read your `.htpasswdpihole` file and/or SSL/TLS certificates; read step-by-step guide [here](#additional-pre-authentication)
- **Redirect Loops:** If you use a custom `server_name`, ensure your internal DNS doesn't create a loop between the proxy and the upstream.
