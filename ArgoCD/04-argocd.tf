resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = var.argocd_repository
  chart            = "argo-cd"
  namespace        = var.argocd_chart_namespace
  create_namespace = var.argocd_chart_create_namespace
  version          = var.argocd_chart_version

  values = [file(var.argocd_values_path)]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password == null ? null : bcrypt(var.argocd_admin_password)
  }

}
