###########################
# variable.tf
###########################

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "artifact_bucket" {
  description = "S3 bucket name where app.jar is stored"
  type        = string
  default     = "praveen-app-file"
}

variable "logs_bucket" {
  description = "S3 bucket name where logs will be saved"
  type        = string
  default     = "latest-log-of-servers12"
}

variable "key_name" {
  description = "EC2 keypair name to use for SSH"
  type        = string
  default     = "your-keypair-name" # replace in terraform.tfvars
}

variable "my_ip" {
  description = "Your public IP in CIDR format to allow SSH (e.g. 1.2.3.4/32)"
  type        = string
  default     = "0.0.0.0/32"
}

variable "ami_id" {
  description = "AMI id (Amazon Linux 2 recommended)"
  type        = string
  default     = "ami-0a0f1259dd1c90938" # ap-south-1 Amazon Linux 2 (example)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "health_check_path" {
  description = "ALB health check path"
  type        = string
  default     = "/"
}
