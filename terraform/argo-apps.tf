# Wait for Argo CD CRDs to be available
resource "time_sleep" "wait_for_argocd_crds" {
  depends_on = [helm_release.argocd]

  create_duration = "1s"
}

# Argo CD Project
resource "kubectl_manifest" "argocd_project" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "hello-project"
      namespace = "argocd"
    }
    spec = {
      description = "Hello application project"
      sourceRepos = [
        local.repository_url
      ]
      destinations = [
        {
          namespace = "external-staging-hello"
          server    = "https://kubernetes.default.svc"
        },
        {
          namespace = "external-production-hello"
          server    = "https://kubernetes.default.svc"
        },
        {
          namespace = "argocd"
          server    = "https://kubernetes.default.svc"
        }
      ]
      clusterResourceWhitelist = [
        {
          group = ""
          kind  = "Namespace"
        }
      ]
      namespaceResourceWhitelist = [
        {
          group = ""
          kind  = "Service"
        },
        {
          group = ""
          kind  = "ConfigMap"
        },
        {
          group = ""
          kind  = "Secret"
        },
        {
          group = "apps"
          kind  = "Deployment"
        },
        {
          group = "monitoring.coreos.com"
          kind  = "ServiceMonitor"
        }
      ]
    }
  })

  depends_on = [helm_release.argocd, time_sleep.wait_for_argocd_crds]
}

# TODO: Use App-of-Apps pattern or Applicationsets for better management
# Hello Staging Application
resource "kubectl_manifest" "argocd_hello_staging" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "hello-staging"
      namespace = "argocd"
      annotations = {
        "kargo.akuity.io/authorized-stage" = "hello:hello-staging"
      }
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "hello-project"
      source = {
        repoURL        = local.repository_url
        targetRevision = "main"
        path           = "charts/hello"
        helm = {
          valueFiles = ["values-staging.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "external-staging-hello"
      }
      syncPolicy = {
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })

  depends_on = [helm_release.argocd, time_sleep.wait_for_argocd_crds]
}

# Hello Production Application
resource "kubectl_manifest" "argocd_hello_production" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "hello-production"
      namespace = "argocd"
      annotations = {
        "kargo.akuity.io/authorized-stage" = "hello:hello-production"
      }
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "hello-project"
      source = {
        repoURL        = local.repository_url
        targetRevision = "main" 
        path           = "charts/hello"
        helm = {
          valueFiles = ["values-production.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "external-production-hello"
      }
      syncPolicy = {
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })

  depends_on = [helm_release.argocd, time_sleep.wait_for_argocd_crds]
}
