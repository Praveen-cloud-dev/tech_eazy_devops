########################################
# ALB OUTPUT
########################################
output "alb_dns" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.app_lb.dns_name
}

########################################
# ASG OUTPUTS
########################################
output "asg_name" {
  description = "Auto Scaling Group Name"
  value       = aws_autoscaling_group.app_asg.name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.app_lt.id
}

########################################
# BUCKET OUTPUTS
########################################
output "artifact_bucket_name" {
  description = "S3 bucket used for JAR storage"
  value       = aws_s3_bucket.artifact.bucket
}

output "logs_bucket_name" {
  description = "S3 bucket used for app logs"
  value       = aws_s3_bucket.logs.bucket
}

########################################
# IAM OUTPUTS
########################################
output "iam_instance_profile" {
  description = "IAM Instance Profile Name"
  value       = aws_iam_instance_profile.ec2_profile.name
}

########################################
# SNS OUTPUT
########################################
# Only enable after adding SNS in main.tf
# output "sns_topic_arn" {
#   description = "SNS Topic ARN for alerts"
#   value       = aws_sns_topic.alerts.arn
# }

########################################
# CLOUDWATCH ALARMS OUTPUT
########################################
# These activate after alarms are added
# output "cpu_high_alarm" {
#   value = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
# }
# 
# output "memory_high_alarm" {
#   value = aws_cloudwatch_metric_alarm.memory_high.alarm_name
# }

#output "cpu_low_alarm" {