# Set up NGINX, PHP, Comoposer and Laravel.

## Installing NGINX:
1. Update:
   ```
   sudo apt update
   ```
2. Install:
   ```
   sudo apt install nginx
   ```
## Install MYSQL:
- You can refer to the MySQL branch of this repo for detailed mysql set up. with user creation with native password and all.
  ```
  sudo apt install mysql-server
  sudo mysql_secure_installation
  ```
## Installing PHP:
- Install `php8.1-fpm` and `php-mysql`.
  ```
  sudo apt install php8.1-fpm php-mysql
  ```
## Configure NGINX to user PHP Processor.
1. Create root web directory for domain:
   ```
   sudo mkdir /var/www/your_domain
   ```
   Set your current user(mostly `Ubuntu`) to use web directory:
   ```
   sudo chown -R $USER:$USER /var/www/your_domain
   ```
2. Create NGINX config file:
   ```
   sudo nano /etc/nginx/sites-available/your_domain
   ```
   Paste following config file with requre edits:
   ```
   server {
    listen 80;
    server_name your_domain www.your_domain;
    root /var/www/your_domain;

    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
     }

    location ~ /\.ht {
        deny all;
    }

    }
   ```
- Link NGINX config file:
  ```
  sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/
  ```
- Unlink Config File:
  ```
  sudo unlink /etc/nginx/sites-enabled/default
  ```
- Check NGINX config:
  ```
  sudo nginx -t
  ```
- Reload NGINX:
  ```
  sudo systemctl reload nginx
  ```
## Now you are all set. You can create PHP project on `/var/www/your_domain` then it will be working.
# Composer installation.
- Install `php-cli`:
  ```
  sudo apt install php-cli unzip
  ```
1. Move to home directory and download composer installer file:
   ```
   curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
   ```
   Fetch hash:
   ```
   HASH=`curl -sS https://composer.github.io/installer.sig`
   ```
   Echo hash:
   ```
   echo $HASH
   ```
   Varify Downloader:
   ```
   php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
   ```
2. Install composer Globaly:
   ```
   sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
   ```
   test composer:
   ```
   composer
   ```

# Laravel Installation:
- Installing dependacies:
  ```
  sudo apt update
  ```
  ```
  sudo apt install php-mbstring php-xml php-bcmath php-curl
  ```
1. Create MySQL database for your application...
2. Creating new laravel project:
   ```
   composer create-project --prefer-dist laravel/laravel appname
   ```
3. Chnage directory to app and veryfy componenets:
   ```
   cd appname
   ```
   ```
   php artisan
   ```
4. Configure Laravel:
   ```
   nano .env
   ```
   Env shoulbe like:
   ```
   APP_NAME=TravelList
   APP_ENV=development
   APP_KEY=APPLICATION_UNIQUE_KEY_DONT_COPY
   APP_DEBUG=true
   APP_URL=http://domain_or_IP
    
   LOG_CHANNEL=stack
   
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=travellist
   DB_USERNAME=travellist_user
   DB_PASSWORD=password
   ```
5. move filw to `/var/www`:
   ```
   sudo mv ~/travellist /var/www/travellist
   ```
   we need to give the web server user write access to the storage and cache folders, where Laravel stores application-generated files:
   ```
   sudo chown -R www-data.www-data /var/www/travellist/storage
   sudo chown -R www-data.www-data /var/www/travellist/bootstrap/cache
   ```
6. Set up NGINX:
   ```
   sudo nano /etc/nginx/sites-available/travellist
   ```
   Config File:
   ```
   server {
    listen 80;
    server_name server_domain_or_IP;
    root /var/www/travellist/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
    }
   ```
  Link files:
   ```
   sudo ln -s /etc/nginx/sites-available/travellist /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```
