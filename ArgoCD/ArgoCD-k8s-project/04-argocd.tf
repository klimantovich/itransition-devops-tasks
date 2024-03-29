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
    value = bcrypt(data.aws_secretsmanager_random_password.argocd_password.random_password)
  }

  depends_on = [module.dev_eks]

}

data "kubernetes_service" "argocd_endpoint" {
  metadata {
    name      = "argocd-server"
    namespace = var.argocd_chart_namespace
  }
  depends_on = [helm_release.argocd]
}
