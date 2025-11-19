resource "aws_sns_topic" "alerts" {
  name = "asg-alerts-topic"
}
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ASG-CPU-High"
  alarm_description   = "CPU > 30% for 2 periods triggers scale out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out.arn,
    aws_sns_topic.alerts.arn
  ]
}
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "ASG-CPU-Low"
  alarm_description   = "CPU < 10% for 5 minutes triggers scale in"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_in.arn
  ]
}
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "ASG-Memory-High"
  alarm_description   = "Memory usage > 80% triggers alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

