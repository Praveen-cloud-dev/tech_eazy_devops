region          = "ap-south-1"
artifact_bucket = "praveen-app-file"
logs_bucket     = "latest-log-of-servers12"
key_name        = "logs"       # replace with your keypair
my_ip           = "152.59.85.234/32"           # replace with your public IP
ami_id          = "ami-0a0f1259dd1c90938" # optional, keep default
instance_type   = "t3.micro"
health_check_path = "/"


# aws s3 cp app.jar s3://praveen-app-file/app.jar