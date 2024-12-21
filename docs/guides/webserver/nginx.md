### Notes & Warnings

- **This is an unsupported configuration created by the community**
- **Replace `8.2` with the PHP version you installed, e.g. if you're using Raspbian Bullseye (Debian 11) replace `8.2` with `7.4`.**
- The `php8.2-sqlite3` package must be installed otherwise Networking and Querying will throw an error that it can't access the database.

### Basic requirements

1. Stop and disable the default lighttpd web server

    ```bash
    systemctl disable --now lighttpd
    ```

2. Install the nginx package and ensure the necessary PHP packages are installed

    ```bash
    apt-get -y install nginx php8.2-fpm php8.2-cgi php8.2-xml php8.2-sqlite3 php8.2-intl
    ```

3. Enable php8.2-fpm at startup and start the service

    ```bash
    systemctl enable --now php8.2-fpm
    ```

4. Enable nginx at startup and start the service

    ```bash
    systemctl enable --now nginx
    ```

5. Replace the contents of `/etc/nginx/sites-available/default` with the following configuration. If necessary, adjust the PHP version number on the `fastcgi_pass` line to match your installation:

    ```nginx
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        server_name _;

        index pihole/index.php index.php index.html index.htm;

        location / {
            expires max;
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
            fastcgi_pass unix:/run/php/php8.2-fpm.sock;
            fastcgi_param FQDN true;
        }

        location /*.js {
            index pihole/index.js;
        }

        location /admin {
            root /var/www/html;
            index index.php index.html index.htm;
        }
    }
    ```

6. Restart the nginx web server

    ```bash
    systemctl restart nginx
    ```

### Optional configuration

- If you want to use your custom domain to access admin page (e.g.: `http://mydomain.internal/admin/settings.php` instead of `http://pi.hole/admin/settings.php`), make sure `mydomain.internal` is assigned to `server_name` in `/etc/nginx/sites-available/default`. E.g.: `server_name mydomain.internal;`

- When using nginx to serve Pi-hole, Let's Encrypt can be used to directly configure nginx. Make sure to use your hostname instead of _ in `server_name _;` line above.

    ```bash
    add-apt-repository ppa:certbot/certbot
    apt-get install certbot python-certbot-nginx

    certbot --nginx -m "$email" -d "$domain" -n --agree-tos --no-eff-email
    ```
