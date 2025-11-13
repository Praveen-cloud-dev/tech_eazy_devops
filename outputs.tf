###########################
# outputs.tf
###########################

output "alb_dns" {
  description = "ALB DNS name"
  value       = aws_lb.app_lb.dns_name
}

output "instance_public_ips" {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.app[*].public_ip
}
