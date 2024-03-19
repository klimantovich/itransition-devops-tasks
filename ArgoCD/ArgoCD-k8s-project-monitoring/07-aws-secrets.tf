#-----------------------------------------------
# Generate passwords
#-----------------------------------------------
resource "random_password" "db_password" {
  length  = "16"
  special = false
}

resource "random_password" "nginx_password" {
  length  = "16"
  special = false
}

resource "random_password" "argocd_password" {
  length  = "16"
  special = false
}

#-----------------------------------------------
# Get passwords form GCP Secret Manager
#-----------------------------------------------
data "google_secret_manager_secret_version" "bot_token" {
  secret  = "tg_bot_token"
  project = "disco-freedom-409407"
}

#-----------------------------------------------
# Create secrets in AWS Secret Manager
#-----------------------------------------------
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project_application_name}-db_password"
  description = "Secret password for Gym management application http basic auth password"
}

resource "aws_secretsmanager_secret" "nginx_password" {
  name        = "${var.project_application_name}-nginx_password"
  description = "Secret password for Gym management application database"
}

resource "aws_secretsmanager_secret" "argocd_password" {
  name        = "${var.project_application_name}-argocd_password"
  description = "Secret password for Argocd admin user"
}

#-----------------------------------------------
# Push passwords to AWS Secret Manager secret
#-----------------------------------------------
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_secretsmanager_secret_version" "nginx_password" {
  secret_id     = aws_secretsmanager_secret.nginx_password.id
  secret_string = random_password.nginx_password.result
}

resource "aws_secretsmanager_secret_version" "argocd_password" {
  secret_id     = aws_secretsmanager_secret.argocd_password.id
  secret_string = random_password.argocd_password.result
}
