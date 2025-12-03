############ ASG Variables ############

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0c02fb55956c7d316"   # Ubuntu 22.04 (update if needed)
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 Key Pair"
}

variable "asg_min" {
  description = "Minimum number of EC2 instances in ASG"
  default     = 1
}

variable "asg_desired" {
  description = "Desired number of EC2 instances in ASG"
  default     = 2
}

variable "asg_max" {
  description = "Maximum number of EC2 instances in ASG"
  default     = 4
}

############ Networking Inputs ############

variable "vpc_id" {
  description = "VPC ID where ASG should run"
}

variable "subnet_ids" {
  description = "List of private/public subnets for ASG"
  type        = list(string)
}

############ CloudWatch / SNS Inputs ############

variable "alert_email" {
  description = "Email ID for SNS alerts"
}

variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

############ Existing Assignment-2 Vars ############

variable "artifact_bucket" {
  description = "S3 bucket name where GitHub will upload app.jar"
  type        = string
}

variable "logs_bucket" {
  description = "S3 bucket name where instances upload logs"
  type        = string
}
