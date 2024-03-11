resource "helm_release" "nginx_ingress" {
  count = var.ingress_enabled && local.create_node_group ? 1 : 0

  name       = var.ingress_release_name
  chart      = var.ingress_chart
  repository = var.ingress_repository
  version    = var.ingress_chart_version
  atomic     = var.ingress_atomic

  create_namespace = var.ingress_create_namespace
  namespace        = var.ingress_namespace

  dynamic "set" {
    for_each = var.ingress_chart_options
    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }

}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress"
  }
  depends_on = [helm_release.nginx_ingress]
}
