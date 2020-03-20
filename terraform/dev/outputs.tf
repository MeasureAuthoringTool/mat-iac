output "cluster_endpoint" {
  description = "Endpoint for bmat-eks control plane."
  value       = module.bmat-eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.bmat-eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.bmat-eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this bmat-eks cluster."
  value       = module.bmat-eks.config_map_aws_auth
}

output "region" {
  description = "AWS region."
  value       = var.region
}
