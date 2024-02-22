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
  yaml_body  = <<-EOF
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
              httpAuth:
                user: ${var.httpAuthUser}
                password: ${data.google_secret_manager_secret_version.httpAuth_password.secret_data}
            configmap:
              db_user: ${var.db_user}
              db_name: ${var.db_name}
              db_host: ${module.dev_db.instance_address}
            secret:
              db_password: ${data.google_secret_manager_secret_version.db_password.secret_data}
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
