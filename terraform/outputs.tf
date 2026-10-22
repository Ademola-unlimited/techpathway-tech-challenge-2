
# ==========================================
# ECR REPOSITORY OUTPUTS
# ==========================================

output "frontend_ecr_url" {
  description = "Frontend Docker image repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_url" {
  description = "Backend Docker image repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

# ==========================================
# APPLICATION LOAD BALANCER OUTPUT
# ==========================================

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "frontend_url" {
  description = "Public URL of the deployed frontend"
  value       = "http://${aws_lb.main.dns_name}"
}
