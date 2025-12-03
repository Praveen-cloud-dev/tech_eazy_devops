#################################
# Existing
#################################
artifact_bucket = "praveen-app-file"
logs_bucket     = "latest-log-of-servers12"

#################################
# ASG / EC2 Configuration
#################################
ami_id        = "ami-0d92749d46e71c34c"
instance_type = "t3.micro"
key_name      = "kubernetes"     # <--- IMPORTANT: replace with your real key pair

#################################
# ASG desired size
#################################
asg_min     = 1
asg_desired = 2
asg_max     = 4

#################################
# Networking (DO NOT FILL)
# These will be assigned automatically using aws_subnet.private[*].id
#################################
vpc_id     = ""     # ignored
subnet_ids = []     # ignored

#################################
# SNS Alerts Email
#################################
alert_email = "pprasadpraveen03@gmail.com"

#################################
# Region
#################################
region = "ap-south-1"


#give values for the variables used in main.tf and cloudwatch_sns.tf
