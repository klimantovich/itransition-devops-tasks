output "kubeconfig" {
  description = "Kubeconfig"
  value       = nonsensitive(data.aws_secretsmanager_secret_version.kubeconfig.secret_string)
}
