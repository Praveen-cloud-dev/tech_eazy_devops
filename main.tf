#kay-pair
# key pair (login)
resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = file("terra-key-ec2.pub ")

}

resource "aws_security_group" "allow_http" {
  name        = "allow_http_${var.environment}"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #all traffic allowed
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "devops_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  user_data = file("User_data.sh")
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  tags = {
    Name = "DevOps-Automation-${var.environment}"
  }
}