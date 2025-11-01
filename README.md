Terraform + AWS EC2 Deployment of Spring Boot Application

This repository contains Terraform configuration files to deploy a Spring Boot application on AWS EC2 using user_data for automated setup and environment-based deployments.

📋 Prerequisites

Before starting, make sure you have the following installed locally:

Terraform

AWS CLI

Git

Configure your AWS credentials:

aws configure
⚙️ Step 1: Clone This Repository
git clone https://github.com/<your-username>/Tech_eazy_devops.git
cd Tech_eazy_devops
🧱 Step 2: Initialize Terraform

Initialize Terraform to download all necessary providers and modules.

terraform init
🏗️ Step 3: Review EC2 Configuration

Ensure that your EC2 instance resource block includes the user_data script for automatic setup and deployment.

🔒 Step 4: Configure Security Group

Ensure your EC2 Security Group allows the following:

Type	Protocol	Port	Source
HTTP	TCP	80	0.0.0.0/0
SSH	TCP	22	Your IP
🌍 Step 5: Choose Environment and Deploy

You can deploy either a Development or Production environment using separate variable files.

🧩 Dev Environment
terraform plan -var-file="dev_config.tfvars"
terraform apply -var-file="dev_config.tfvars" -auto-approve
🏭 Prod Environment
terraform plan -var-file="prod_config.tfvars"
terraform apply -var-file="prod_config.tfvars" -auto-approve

Each .tfvars file defines environment-specific variables:

instance_type = "t2.micro"
environment   = "dev"
🔍 Step 6: Verify Deployment

Get the public IP of your EC2 instance:

terraform output

SSH into the instance:

ssh -i terra-key-ec2.pem ubuntu@<public-ip>

Check setup logs:

cat /var/log/user_data.log | tail -n 30
🌐 Step 7: Access the Application

Open your browser and go to:

http://<public-ip>/

If deployment is successful, you’ll see your Spring Boot application running.

🧹 Step 8: Destroy Infrastructure (Optional)

To delete all resources created by Terraform:

terraform destroy -auto-approve
📂 Recommended Terraform Folder Structure
Tech_eazy_devops/
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data.sh
│   └── security_group/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── env/
│   ├── dev/
│   │   ├── main.tf
│   │   └── dev_config.tfvars
│   └── prod/
│       ├── main.tf
│       └── prod_config.tfvars
│
├── README.md
└── terra-key-ec2.pem

💡 Notes:

modules/ contains reusable Terraform components (EC2, SG, etc.)

env/dev and env/prod contain environment-specific variables.

user_data.sh handles automated Spring Boot setup.

outputs.tf helps retrieve useful info like EC2 public IP.

🪄 Common Troubleshooting
Issue	Cause	Fix
Maven not found	User data didn’t install it	Ensure sudo apt install -y maven exists in script
App not running	Port blocked	Open port 80 in security group
404 Error	App build failed	Check /home/ubuntu/app.log
Repo not cloned	Wrong GitHub URL	Verify your repo link is correct
🔁 Pull Request Workflow

Create a new branch and make your changes:

git checkout -b feature/update-readme
git add .
git commit -m "Added detailed README and deployment instructions"

Push your branch to GitHub:

git push origin feature/update-readme

Create a Pull Request (PR) to the main branch and share the link for review.

✅ Expected Outcome

After a successful deployment:

EC2 instance is launched

Java, Git, and Maven are installed

Spring Boot app is cloned and deployed automatically

Application accessible via browser on port 80

Author: Praveen Kumar Prasad
Project: Tech Eazy DevOps
Purpose: Automated Multi-Environment Spring Boot Deployment on AWS using Terraform
