output "alb_dns_name" {
  description = "ALB URL - internal, use for direct API testing only"
  value       = module.alb.alb_dns_name
}

output "cloudfront_url" {
  description = "Public URL - share this with everyone"
  value       = "https://${module.cloudfront.cloudfront_domain}"
}

output "instance_public_ip" {
  description = "EC2 instance public IP for SSH access"
  value       = length(data.aws_instances.app_servers.public_ips) > 0 ? data.aws_instances.app_servers.public_ips[0] : "Instance not running yet"
}
