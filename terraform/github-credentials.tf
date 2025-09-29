# GitHub credentials for ArgoCD and Kargo
# Uses variables defined in variables.tf

# GitHub credentials secret for ArgoCD
# TODO: Use proper secret management (e.g., HashiCorp Vault) for production
resource "kubernetes_secret" "github_credentials_argocd" {
  metadata {
    name      = "github-credentials"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = local.repository_url
    password = var.github_pat
    username = var.github_username
  }

  type = "Opaque"
}

# GitHub credentials secret for Kargo
resource "kubernetes_secret" "github_credentials_kargo" {
  metadata {
    name      = "github"
    namespace = "hello"
    labels = {
      "kargo.akuity.io/cred-type" = "git"
    }
  }

  data = {
    repoURL = local.repository_url
    username = var.github_username
    password = var.github_pat
  }

  depends_on = [time_sleep.wait_for_kargo_project]

  type = "Opaque"
}
