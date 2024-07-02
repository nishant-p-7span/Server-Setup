# AWS CodeDeploy and CodePipeline on EC2 instance with github.
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

**9. Install AWS CodeDeploy Agent:**

installing Dependencies:

    sudo apt install ruby-full

install Agetnt file: [Refer this AWS Document](https://docs.aws.amazon.com/codedeploy/latest/userguide/resource-kit.html#resource-kit-bucket-names)

    wget https://bucket-name.s3.region-identifier.amazonaws.com/latest/install
    wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install #In my case, instance is in ap-south-1 region.

chmod:

    chmod +x ./install

install latest versrion of Agent:

    sudo ./install auto

Start agent:

    sudo service codedeploy-agent start

Restart Agent:

    sudo service codedeploy-agent restart

## **[IMPORTANT] appsec.yml, after_install.sh and application_start.sh:**

**appsec.yml**

appsec.yml file is going to run when we deploy our app, so write it carefully. 

    destination: /home/ubuntu/test-node #here test-node is name of repo, so if your repo has different name then chnage it accordingly.

for other refer to the appsec.yml file in this repo.

**after_install.sh**

Make sure cd command is written correctly according to your server. otherwise npm command will not run.

**application_start.sh**

    pm2 restart test-node

here we used command restart test-node because, we have already started the app.js with name test-node in previous steps. so our app is already running and after this scripts run, we only need to restart the app to apply changes.

## **IAM Roles SetUp:**

**CodeDeploy Role for EC2 instace:**

Create Role --> AWS Servives --> EC2 --> "AmazonEC2RoleforAWSCodeDeploy" --> Create Role.

**IAM Role for CodeDeploy:**

Create Role --> AWS Servives --> CodeDeploy --> "AWSCodeDeployRole" --> Create Role.

**Attach EC2 Role to instance:**

Action --> Security --> Modify IAM Role --> Attach created role for EC2.

    sudo service codedeploy-agent restart #better to restart agent after attaching the role.

## **CodeDeploy SetUp:**

**Create Application:**
Go to CodeDeploy --> Create Application --> Name --> Compute Platfrom: EC2/On-Premise --> Create

**Create Deployment Group:**
Create Deployment Group --> Group Name --> Service Role: attach Codedeploy Role --> Deployment Type: In place --> AWS EC2 instance: set key and name --> Agent Configuration: leave default --> Deployment Settings: OneAtTime
--> Disable Load Balancer --> create group.

**Menual Deployment for testing: (Optional but recommened for successful pipeline execution:)**
Create Deployment --> Revision Type: My app is stored in GitHub --> GitHub Token Name: your-username --> Connect To GitHub (Connect your git account to AWS CodeDeploy suit --> Repo name: nishant-p-7span/test-node --> Commit ID: ![image](https://github.com/nishant-p-7span/test-node/assets/160576245/452348e5-f6d6-47fc-b5c0-841f42112cca) Click there and Copy the Full Commit ID from URL --> Deployment Behaviour: Override the Content --> Deplpoy 

If this Deployment Succeded then Good to Go for Pipeline otherwise try to solve issues that is occuring. (Codepipeline Has only 100 minutes are free for free tier users so, use it carefully)

## **CodePipeline SetUp:**

Create New Pipeline --> Pipeline Name --> Create service Role --> Source Provider: GitHub - V1, Connect it then select repo and branch, Detection option AWS CodePipeline --> Skip Build Stage --> Deploy Stage: Select CodeDeploy, application and deployment Group. --> Create Pipeline.

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

```sudo certbot --nginx --register-unsafely-without-email -d yourdomain.com```
