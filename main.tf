########################################
# PROVIDER
########################################
provider "aws" {
  region = "ap-south-1"
}

########################################
# S3 BUCKETS
########################################

resource "aws_s3_bucket" "artifact" {
  bucket = var.artifact_bucket
}

resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket
}

########################################
# IAM ROLE FOR EC2
########################################

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role" "ec2_role" {
  name               = "s3-rw-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy" "ec2_rw_policy" {
  name = "ec2-s3-rw"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:*"],
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
  name = "ec2-s3-instance-profile1"
  role = aws_iam_role.ec2_role.name
}


# New policy resource (or append to existing ec2_rw_policy)
resource "aws_iam_role_policy" "ec2_cloudwatch_policy" {
  name = "ec2-cloudwatch-sns-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ssm:GetParameter"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "*"
      }
    ]
  })
}

#upload user for artifacts policy
resource "aws_iam_user" "upload_user" {
  name = "artifact-upload-user"
}

resource "aws_iam_user_policy" "upload_policy" {
  name = "upload-only-policy"
  user = aws_iam_user.upload_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow listing the artifact bucket
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = aws_s3_bucket.artifact.arn
      },
      # Allow uploading/overwriting objects inside the artifact bucket
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"],
        Resource = "${aws_s3_bucket.artifact.arn}/*"
      }
    ]
  })
}


resource "aws_iam_access_key" "upload_user_key" {
  user = aws_iam_user.upload_user.name
}

########################################
# SECURITY GROUP
########################################

# Security group for ALB (public)
resource "aws_security_group" "alb_sg" {
  name        = "app-alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for instances (allow only ALB to talk to instances on 80)
resource "aws_security_group" "instance_sg" {
  name        = "app-instance-sg"
  description = "Allow traffic from ALB to EC2 instances"
  vpc_id      = aws_vpc.main.id

  # Allow ALB SG to access instance on http
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


########################################
# APPLICATION LOAD BALANCER
########################################

resource "aws_lb" "app_lb" {
  name               = "app-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}


resource "aws_lb_target_group" "tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/hello"
    port = "80"
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



########################################
# Launch Template (used by ASG)
########################################
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = var.ami_id       # make sure variable present
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.instance_sg.id]
  }

  # Use templatefile() so user_data variables are injected
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    artifact_bucket = var.artifact_bucket,
    logs_bucket     = var.logs_bucket
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
      Project = "lift-shift"
    }
  }
}

########################################
# Auto Scaling Group (attached to ALB TG)
########################################
resource "aws_autoscaling_group" "app_asg" {
  name_prefix          = "app-asg-"
  desired_capacity     = var.asg_desired
  min_size             = var.asg_min
  max_size             = var.asg_max
  vpc_zone_identifier =   [aws_subnet.private[0].id,aws_subnet.private[1].id
]
  health_check_type    = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }
}



