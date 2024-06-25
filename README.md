# BitBucket CI/CD implementation.
In this section, We are going to create CI/CD pipeline using AWS CodeDeploy and CodePipeline on EC2 instance. Before, going into the further process make sure your git repo is set up with appsec.yml file properly as I have done.

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

## Bitbucket:
- Create Workspace, then Repository and push your application code into it.
- To attach EC2 (self-hosted runner) go to: --> Repository settings --> Pipelines --> Runner --> Add Runner -->
  - Linux Shell, Runner name and labels.
- You will get some commands to run that runner on your EC2 instance.
  - All comm will run perfectly, but last command you can notice after sometimes that. This script is only running util you are in the shell.
  - To keep this scipt running in the backgroud after exiting terminal
    1. We will use `screen` command which is pre-installed in ubunutu. This will keep running script in the bg so, our host always stays online.
    ```
    screen ./start.sh_command
    ```
    Then, press **Ctrl + A** and then **Ctrl + D** to detach screen section.
    you can type `screen -r` to see the screen with the runner
  - after that you will get code to add into the CI/CD copy it.
- Now, we have to create **Pipeline**:
  - Go to Pipelines --> select build and test NodeJS code --> then it will prompt .yml file that we have to configure
`bitbucket-pipelines.yml`
```
image: node:20

pipelines:
  branches:
    main:
      - step:
          runs-on:
            - self.hosted
            - linux.shell
          clone:
            enabled: true
          script:
            - echo "This step will run on a self hosted runner.";
            - pwd
            - npm install
            - pm2 restart test
```
 - Commit, and now your CI/CD is up and running. 
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
