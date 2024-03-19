# output "project_url" {
#   value = "https://${module.dev_eks.ingress_endpoint}"
# }

# output "argocd_url" {
#   value = "https://${data.kubernetes_service.argocd_endpoint.status.0.load_balancer.0.ingress.0.hostname}"
# }
