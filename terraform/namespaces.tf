# Application namespaces
resource "kubernetes_namespace" "external_staging_hello" {
  metadata {
    name = "external-staging-hello"
    labels = {
      environment = "staging"
      app         = "hello"
      type        = "external"
    }
  }
}

resource "kubernetes_namespace" "external_production_hello" {
  metadata {
    name = "external-production-hello"
    labels = {
      environment = "production"
      app         = "hello"
      type        = "external"
    }
  }
}

# System namespaces
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "kargo" {
  metadata {
    name = "kargo"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}


