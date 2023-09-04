### Notes & Warnings

- **This is an unsupported configuration created by the community**
- The `php-sqlite3` package must be installed otherwise Networking and Querying will throw an error that it can't access the database.

### Basic requirements

1. Stop default lighttpd

    ```bash
    systemctl stop lighttpd
    ```

1. Install necessary packages

    ```bash
    apt-get -y install nginx php-fpm php-cgi php-xml php-sqlite3 php-intl apache2-utils
    ```

1. Disable lighttpd at startup

    ```bash
    systemctl disable lighttpd
    ```

1. Enable php8.2-fpm at startup
    *Note:* The name of this service includes the version of `php-fpm` installed. To find yours, run `sudo apt list --installed | grep php.*fpm`

    ```bash
    systemctl enable php8.2-fpm
    ```

1. Enable nginx at startup

    ```bash
    systemctl enable nginx
    ```

1. Edit `/etc/nginx/sites-available/default` to:

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

1. Create a username for authentication for the admin - we don't want other people in our network change our black and whitelist ;)

    ```bash
    htpasswd -c /etc/nginx/.htpasswd exampleuser
    ```

1. Change ownership of the html directory to nginx user

    ```bash
    chown -R www-data:www-data /var/www/html
    ```

1. Make sure the html directory is writable

    ```bash
    chmod -R 755 /var/www/html
    ```

1. Grant the admin panel access to the gravity database

    ```bash
    usermod -aG pihole www-data
    ```

1. Start php8.2-fpm daemon

    ```bash
    systemctl restart php8.2-fpm
    ```

1. Start nginx web server

    ```bash
    systemct restart nginx
    ```

### Optional configuration

- If you want to use your custom domain to access admin page (e.g.: `http://mydomain.internal/admin/settings.php` instead of `http://pi.hole/admin/settings.php`), make sure `mydomain.internal` is assigned to `server_name` in `/etc/nginx/sites-available/default`. E.g.: `server_name mydomain.internal;`

- When using nginx to serve Pi-hole, Let's Encrypt can be used to directly configure nginx. Make sure to use your hostname instead of _ in `server_name _;` line above.

    ```bash
    add-apt-repository ppa:certbot/certbot
    apt-get install certbot python-certbot-nginx

    certbot --nginx -m "$email" -d "$domain" -n --agree-tos --no-eff-email
    ```
