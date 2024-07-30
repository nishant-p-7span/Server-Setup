# AWS Server set up guide.
## **Setup EC2 Instace:**
**1. Launch EC2 instance:** Here I am going to use Ubuntu, so next all the commands will be according to the ubuntu.

**2. SSH into your instance:** You can use any method, I am going to use "EC2 Instance Connect".

**3. Update, upgrade and Install git, htop and wget:**

Update:

    sudo apt update

Upgrade:

    sudo apt upgrade -y

Install git, htop and wget:

    sudo apt install -y git htop wget

**4. Installing Node:**

Download NVM Script:

    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

Running either of the above commands downloads a script and runs it. The script clones the nvm repository to ~/.nvm, and attempts to add the source lines from the snippet below to the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).

Copy & Paste Following Line (Each Line Saparately):

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

Verify nvm:

    nvm --version

install Node:

    nvm install --lts

Verify NodeJS:

    node --version

Verify NPM:

    npm --version

**5. Testing:**

make sure you are in /home/ubuntu directory.

    cd /home/ubuntu

clone the repo:

    git clone https://github.com/nishant-p-7span/test-node.git

go to repo directory:

    cd test-node

run app.js:

    node app.js

To acces the application go to the following address: 
    
    http://ip-of-instace:portno 

**6. PM2 set up:**

    npm i -g pm2

**7. Making Available node, pm2 and npm to root:**

Node:

    sudo ln -s "$(which node)" /sbin/node

npm:

    sudo ln -s "$(which npm)" /sbin/npm

pm2:

    sudo ln -s "$(which pm2)" /sbin/pm2

**8. Running app with sudo:**
Running app.js with pm2 with custom name:

    sudo pm2 start app.js --name=test-node

Save the app, otherwise pm2 will forget running app on next boot:

    sudo pm2 save

Start PM2 on system boot:

    sudo pm2 startup

# Now Done, if you make chages to the git repo then automatically trigger the pipeline and deploy it.

# NPM hangs problem on t2.micro.

We will Solve this issue by Allocating our ebs storage as memory, so it will increase our RAM.

first make sure you are log in as root ( so our swap file be stay persistant on the reboots ).

    sudo su #if you are log in as ubuntu user.

Copy Paste the following commands.

    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap  /swapfile
    swapon /swapfile
    swapon  --show
    free -h
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# NGINX Setup:
- install nginx
  ```
  sudo apt install nginx
  ```
- Go to folowing location: `etc/nginx/site-available`.
- Create file with domain name of app
  ```
  nano domain.com
  ```
- Add following content to the file:
  ```
  server {
        listen 80;
        listen [::]:80;

        root /var/www/your_domain/html;
        index index.html index.htm index.nginx-debian.html;

        server_name your_domain;

        location / {
                # try_files $uri $uri/ =404;
                proxy_pass http://localhost:8001; #whatever port your app runs on
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
        }
    }
   ```
- Enter following command to link to the `sites-enable`.
  ```
  sudo ln -s /etc/nginx/sites-available/domain.com /etc/nginx/sites-enabled/
  ```
- Configuration check command:
  ```
  nginx -t
  ```
- Reload NGINX:
  ```
  nginx -s reload
  ```
- NGINX parameter to limit file upload size.
  ```
  client_max_body_size 100M;
  ```
- NGINX wildcard parameter to query other routes.
  ```
  location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
  ```

# Certbot Set up:
- add repo:
  ```
  sudo add-apt-repository ppa:certbot/certbot
  ```
- update:
  ```
  sudo apt-get update
  ```
- install certbot:
  ```
  sudo apt-get install python3-certbot-nginx
  ```
- Command to activate SSL.
    ```
    sudo certbot --nginx --register-unsafely-without-email -d yourdomain.com
    ```
- Renew Command:
  ```
  certbot renew --dry-run
  ```
- Set up Cron to auto update SSL:
  ```
  crontab -e
  ```
- Add certbot command:
  ```
  0 12 * * * /usr/bin/certbot renew --quiet
  ```
  
# Directus Commands:
- Initiate directus project:
  ```
  npm init directus-project@latest <project-name>
  ```
- Start new project.
  ```
  npx directus start
  ```
- If database already exist or set up project from already existing env.
  ```
  npx directus bootstrap
  ```
