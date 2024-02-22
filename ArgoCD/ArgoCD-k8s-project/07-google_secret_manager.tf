# Get passwords from Google Secret Manager
data "google_secret_manager_secret_version" "db_password" {
  project = var.gsm_project
  secret  = var.gsm_db_password_secret
}

data "google_secret_manager_secret_version" "httpAuth_password" {
  project = var.gsm_project
  secret  = var.gsm_httpAuth_password_secret
}
