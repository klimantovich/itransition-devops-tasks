resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = var.argocd_repository
  chart            = "argo-cd"
  namespace        = var.argocd_chart_namespace
  create_namespace = var.argocd_chart_create_namespace
  version          = var.argocd_chart_version

  values = [file(var.argocd_values_path)]

  depends_on = [module.dev_eks]

}

# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
