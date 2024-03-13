#-----------------------------------------------
# Generate passwords
#-----------------------------------------------
data "aws_secretsmanager_random_password" "db_password" {
  password_length     = 16
  exclude_punctuation = true
}

data "aws_secretsmanager_random_password" "nginx_password" {
  password_length     = 16
  exclude_punctuation = true
}

data "aws_secretsmanager_random_password" "argocd_password" {
  password_length     = 16
  exclude_punctuation = true
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
  secret_string = data.aws_secretsmanager_random_password.db_password.random_password
}

resource "aws_secretsmanager_secret_version" "nginx_password" {
  secret_id     = aws_secretsmanager_secret.nginx_password.id
  secret_string = data.aws_secretsmanager_random_password.nginx_password.random_password
}

resource "aws_secretsmanager_secret_version" "argocd_password" {
  secret_id     = aws_secretsmanager_secret.argocd_password.id
  secret_string = data.aws_secretsmanager_random_password.argocd_password.random_password
}
