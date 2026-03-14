output "alb_dns_name" {
  description = "ALB URL - use this to test the Flask API"
  value       = module.alb.alb_dns_name
}
