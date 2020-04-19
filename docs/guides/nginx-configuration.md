### Notes & Warnings

- **This is an unsupported configuration created by the community**
- **Replace `7.3` with the PHP version you installed, e.g. if you're using Raspbian Stretch (Debian 9) replace `7.3` with 7.0`.**
- The `php7.3-sqlite` package must be installed otherwise Networking and Querying will throw an error that it can't access the database.

### Basic requirements

1. Stop default lighttpd

    ```bash
    service lighttpd stop
    ```

2. Install necessary packages

    ```bash
    apt-get -y install nginx php7.3-fpm php7.3-zip php7.3-sqlite apache2-utils
    ```

3. Disable lighttpd at startup

    ```bash
    systemctl disable lighttpd
    ```

4. Enable php7.3-fpm at startup

    ```bash
    systemctl enable php7.3-fpm
    ```

5. Enable nginx at startup

    ```bash
    systemctl enable nginx
    ```

6. Edit `/etc/nginx/sites-available/default` to:

    ```nginx
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        server_name _;
        autoindex off;

        index pihole/index.php index.php index.html index.htm;

        location / {
            expires max;
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
            fastcgi_pass unix:/run/php/php7.3-fpm.sock;
            fastcgi_param FQDN true;
            auth_basic "Restricted"; # For Basic Auth
            auth_basic_user_file /etc/nginx/.htpasswd; # For Basic Auth
        }

        location /*.js {
            index pihole/index.js;
            auth_basic "Restricted"; # For Basic Auth
            auth_basic_user_file /etc/nginx/.htpasswd; # For Basic Auth
        }

        location /admin {
            root /var/www/html;
            index index.php index.html index.htm;
            auth_basic "Restricted"; # For Basic Auth
            auth_basic_user_file /etc/nginx/.htpasswd; # For Basic Auth
        }

        location ~ /\.ht {
            deny all;
        }
    }
    ```

7. Create a username for authentication for the admin - we don't want other people in our network change our black and whitelist ;)

    ```bash
    htpasswd -c /etc/nginx/.htpasswd exampleuser
    ```

8. Change ownership of the html directory to nginx user

    ```bash
    chown -R www-data:www-data /var/www/html
    ```

9. Make sure the html directory is writable

    ```bash
    chmod -R 755 /var/www/html
    ```

10. Start php7.3-fpm daemon

    ```bash
    service php7.3-fpm start
    ```

11. Start nginx web server

    ```bash
    service nginx start
    ```

### Optional configuration

- If you want to use your custom domain to access admin page (e.g.: `http://mydomain.internal/admin/settings.php` instead of `http://pi.hole/admin/settings.php`), make sure `mydomain.internal` is assigned to `server_name` in `/etc/nginx/sites-available/default`. E.g.: `server_name mydomain.internal;`

- If you want to use block page for any blocked domain subpage (aka Nginx 404), add this to Pi-hole server block in your Nginx configuration file:

    ```nginx
    error_page 404 /pihole/index.php;
    ```

- When using nginx to serve Pi-hole, Let's Encrypt can be used to directly configure nginx. Make sure to use your hostname instead of _ in `server_name _;` line above.

    ```bash
    add-apt-repository ppa:certbot/certbot
    apt-get install certbot python-certbot-nginx

    certbot --nginx -m "$email" -d "$domain" -n --agree-tos --no-eff-email
    ```
