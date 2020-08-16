### Notes & Warnings

- **This is an unsupported configuration created by the community**
- **Replace `7.4` with the PHP version installed, e.g. if you're using Raspbian Stretch (Debian 9), replace `7.4` with `7.0`.**
- The `$phpver-sqlite3` package must be installed otherwise Networking and Querying will throw an error that it can't access the database.

### Basic requirements
0. Set correct PHP version (Run    `php -v` to find which version you have installed)

    ```bash
    phpver=php7.4
    ```

1. Stop default lighttpd

    ```bash
    service lighttpd stop
    ```

2. Install necessary packages

    ```bash
    apt-get -y install nginx $phpver-fpm $phpver-cgi $phpver-xml $phpver-sqlite3 $phpver-intl apache2-utils
    ```

3. Disable lighttpd at startup

    ```bash
    systemctl disable lighttpd
    ```

4. Enable $phpver-fpm at startup

    ```bash
    systemctl enable $phpver-fpm
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
            fastcgi_pass unix:/run/php/phpver-fpm.sock;
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

7. Insert correct php version.

    ```bash
    sed -i "s/phpver/$phpver/g" /etc/nginx/sites-available/default
    ```

8. Create a username for authentication for the admin - we don't want other people in our network change our black and whitelist ;)

    ```bash
    htpasswd -c /etc/nginx/.htpasswd exampleuser
    ```

9. Change ownership of the html directory to nginx user

    ```bash
    chown -R www-data:www-data /var/www/html
    ```

10. Make sure the html directory is writable

    ```bash
    chmod -R 755 /var/www/html
    ```

11. Grant the admin panel access to the gravity database

    ```bash
    usermod -aG pihole www-data
    ```

12. Start $phpver-fpm daemon

    ```bash
    service $phpver-fpm start
    ```

13. Start nginx web server

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
