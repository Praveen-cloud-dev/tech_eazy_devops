###########################
# main.tf
###########################
provider "aws" {
  region = var.region
}

# S3 buckets (artifact & logs)
resource "aws_s3_bucket" "artifact" {
  bucket = var.artifact_bucket
  # force_destroy = true   # optional: uncomment if you want terraform to delete non-empty buckets
}

resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket
  # force_destroy = true
}

# IAM assume policy for EC2 role
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for EC2 (SSM + S3 read)
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-s3-rw-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ec2_rw_policy" {
  name = "ec2-s3-rw"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.artifact.arn,
          "${aws_s3_bucket.artifact.arn}/*",
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Security group for ALB + SSH
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow ALB HTTP and SSH from your IP"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere (ALB traffic)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path               = var.health_check_path
    port               = "80"
    healthy_threshold  = 2
    unhealthy_threshold = 2
    timeout            = 10
    interval           = 15
    matcher            = "200-399"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# EC2 Instances (3)
resource "aws_instance" "app" {
  count                        = 3
  ami                          = var.ami_id
  instance_type                = var.instance_type
  subnet_id                    = aws_subnet.public[count.index].id
  associate_public_ip_address  = true
  key_name                     = var.key_name
  security_groups              = [aws_security_group.app_sg.id]
  iam_instance_profile         = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
  artifact_bucket = var.artifact_bucket
  logs_bucket     = var.logs_bucket
  aws_region      = var.region     
})


  tags = {
    Name = "app-instance-${count.index}"
  }
}

# Register instances with TG
resource "aws_lb_target_group_attachment" "attach" {
  count            = 3
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}
