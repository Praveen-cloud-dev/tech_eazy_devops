# 🚀 AWS Auto Scaling + ALB + CloudWatch Monitoring (Terraform Project)

This project deploys a complete AWS infrastructure using Terraform, including:

- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Launch Template for EC2
- S3 buckets for artifacts & logs
- IAM roles & instance profile
- CloudWatch Agent (CPU + Memory metrics)
- CloudWatch Alarms (CPU High, CPU Low, Memory High)
- SNS Email Notifications
- Log upload automation to S3
- VPC with public/private subnets, NAT Gateway & routing

---

## 📂 Folder Structure

project/
├── main.tf
├── variables.tf
├── networking.tf
├── outputs.tf
├── cloudwatch_sns.tf
├── user_data.sh
└── terraform.tfvars

yaml
Copy code

---

## ⚙️ What This Infrastructure Does

- Runs EC2 instances inside an Auto Scaling Group.
- Distributes traffic using an Application Load Balancer.
- Monitors CPU & Memory using CloudWatch.
- Auto-scales based on CloudWatch alarms.
- Sends email alerts through Amazon SNS.
- Uploads application logs to S3 every 2 minutes.
- Java application starts automatically using systemd.

---

## 🚀 How to Deploy

### 1️⃣ Initialize Terraform
```bash
terraform init
2️⃣ Validate
bash
Copy code
terraform validate
3️⃣ Apply
bash
Copy code
terraform apply -auto-approve
4️⃣ Confirm SNS Subscription
Check your email and confirm the AWS SNS Subscription.

🔍 After Deployment — Validation Checklist
Open the ALB DNS from Terraform output:

bash
Copy code
terraform output alb_dns
Ensure app loads in browser.

Check EC2 instances inside Auto Scaling Group.

Check Target Group → instances should be healthy.

Check S3 bucket for log uploads.

Check CloudWatch → CPU / Memory metrics.

Trigger scale-out by generating traffic.

Verify email alerts from SNS.

🗑️ Cleanup (Avoid AWS Billing)
To delete everything safely:

bash
Copy code
terraform destroy -auto-approve
This removes:

NAT Gateway

ALB

EC2 instances

ASG

EIP

CloudWatch alarms

SNS

S3 buckets

All VPC components

📌 Requirements
AWS CLI configured

Terraform installed

Existing EC2 Key Pair (used in variables)

🙌 Author
Praveen
Terraform | AWS | DevOps Projects