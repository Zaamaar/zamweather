output "alb_dns_name" {
  description = "ALB URL - use this to test the Flask API"
  value       = module.alb.alb_dns_name
}

output "instance_public_ip" {
  description = "EC2 instance public IP for SSH access"
  value       = length(data.aws_instances.app_servers.public_ips) > 0 ? data.aws_instances.app_servers.public_ips[0] : "Instance not running yet"
}
