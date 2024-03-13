locals {
  tls_secret_name = "ingress-project-tls"
  tls_host_name   = "project.local"
}

resource "kubectl_manifest" "argocd_project" {
  yaml_body  = <<-EOF
    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      name: ${var.argocd_project_name}
      namespace: ${var.argocd_chart_namespace}
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      sourceRepos:
        - ${var.project_repository}
      destinations:
        - server: https://kubernetes.default.svc
          name: in-cluster
          namespace: "${var.project_namespace}"
      clusterResourceWhitelist:
        - group: "*"
          kind: Namespace
      namespaceResourceWhitelist:
        - group: "apps"
          kind: Deployment
        - group: "*"
          kind: ConfigMap
        - group: "*"
          kind: Secret
        - group: "networking.k8s.io"
          kind: Ingress
        - group: "*"
          kind: Service
  EOF
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "argocd_application" {
  yaml_body = <<-EOF
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ${var.project_application_name}
      namespace: ${var.argocd_chart_namespace}
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: ${var.argocd_project_name}
      source:
        repoURL: ${var.project_repository}
        targetRevision: ${var.project_repository_branch}
        path: ${var.project_repository_path}
        helm:
          valueFiles:
            - "../../values/gymmanagement-dev.yaml"
            - "../../values/gymmanagement-dev-image.yaml"
          valuesObject:
            ingress:
              tls:
                - secretName: ${local.tls_secret_name}
                  hosts:
                    - ${local.tls_host_name}
              enabled: true
              httpAuth:
                user: ${var.httpAuthUser}
                password: ${data.aws_secretsmanager_random_password.nginx_password.random_password}
            configmap:
              db_user: ${var.db_user}
              db_name: ${var.db_name}
              db_host: ${module.dev_db.instance_address}
            secret:
              db_password: ${data.aws_secretsmanager_random_password.db_password.random_password}
      destination:
        server: https://kubernetes.default.svc
        namespace: ${var.project_namespace}
      syncPolicy:
        automated: {}
        syncOptions:
          - CreateNamespace=true
  EOF

  depends_on = [helm_release.argocd]
}

#-----------------------------------------------
# Generate SSL certs for ingress
#-----------------------------------------------
resource "tls_private_key" "project_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "project_cert" {
  private_key_pem = tls_private_key.project_key.private_key_pem

  subject {
    common_name = local.tls_host_name
  }

  validity_period_hours = 72

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "project_cert" {
  metadata {
    name = local.tls_secret_name
  }
  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.project_cert.cert_pem
    "tls.key" = tls_private_key.project_key.private_key_pem
  }

}
