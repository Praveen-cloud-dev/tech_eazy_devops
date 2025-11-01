# 🚀 Terraform + AWS EC2 Deployment of Spring Boot Application

This repository contains Terraform configuration files to deploy a **Spring Boot application** on **AWS EC2** using **user_data** for automated setup and environment-based deployments.

---

## 📋 Prerequisites

Before starting, make sure you have the following installed locally:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Git](https://git-scm.com/downloads)
- AWS Account credentials configured using:

  ```bash
  aws configure
⚙️ Step 1: Clone This Repository
git clone https://github.com/<your-username>/Tech_eazy_devops.git
cd Tech_eazy_devops

🧱 Step 2: Initialize Terraform

Initialize Terraform to download all necessary providers and modules.

terraform init

🏗️ Step 3: Review EC2 Configuration

Ensure that your EC2 instance resource block includes the following user_data script for automatic setup and deployment

🔒 Step 4: Configure Security Group

Ensure your EC2 Security Group allows the following:

Type	Protocol	Port	Source
HTTP	TCP	80	0.0.0.0/0
SSH	TCP	22	Your IP
🌍 Step 5: Choose Environment and Deploy

You can deploy either a Development or Production environment using separate variable files.

🧩 For Dev environment:
terraform plan -var-file="dev_config.tfvars"
terraform apply -var-file="dev_config.tfvars" -auto-approve

🏭 For Prod environment:
terraform plan -var-file="prod_config.tfvars"
terraform apply -var-file="prod_config.tfvars" -auto-approve


Each .tfvars file should define environment-specific variables like:

instance_type = "t2.micro"
environment   = "dev"

🔍 Step 6: Verify Deployment

After the instance is created, get its public IP address:

terraform output


or from the AWS Console.

SSH into the EC2 instance:

ssh -i terra-key-ec2.pem ubuntu@<public-ip>


Check the setup logs:

cat /var/log/user_data.log | tail -n 30

🌐 Step 7: Access the Application

Open your browser and go to:

http://<public-ip>/


If the deployment was successful, you’ll see your Spring Boot application running.

🧹 Step 8: Destroy Infrastructure (Optional)

To delete all resources created by Terraform:

terraform destroy -auto-approve

🪄 Common Troubleshooting
Issue	Cause	Fix
Maven not found	User data didn’t install it	Ensure sudo apt install -y maven exists in script
App not running	Port blocked	Open port 80 in security group
404 Error	App build failed	Check /home/ubuntu/app.log
Repo not cloned	Wrong GitHub URL	Verify your repo link is correct

🔁 Pull Request Workflow
If you’re submitting this as part of an assignment or team project:


Create a new branch and make your changes:
git checkout -b feature/update-readme
git add .
git commit -m "Added detailed README and deployment instructions"



Push your branch to GitHub:
git push origin feature/update-readme



Go to your GitHub repo and create a Pull Request (PR) to the main branch.


Share the PR link for review.



✅ Expected Outcome
After a successful deployment:


EC2 instance is launched


Java, Git, and Maven are installed


Spring Boot app is cloned and deployed automatically


Application accessible via browser on port 80



Author: Praveen Kumar Prasad
Project: Tech Eazy DevOps
Purpose: Automated Multi-Environment Spring Boot Deployment on AWS using Terraform

---

Would you like me to **add Terraform folder structure** (like `/modules`, `/env/dev`, `/env/prod`) inside this README so it looks more professional for your assignment?
