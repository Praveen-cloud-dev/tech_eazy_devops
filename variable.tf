variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  type        = string
  default     = "ami-02d26659fd82cf299" # Ubuntu 22.04 AMI in ap-south-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"

}

variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
  default = "terra-key"
}



variable "environment" {
  description = "Deployment stage (dev/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID for the instance"
  type        = string
  default     = "vpc-0fe7248d4329da7fe" #  your VPC ID
}
