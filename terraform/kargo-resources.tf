# Wait for Kargo CRDs to be available
resource "time_sleep" "wait_for_kargo_crds" {
  depends_on = [helm_release.kargo]
  create_duration = "45s"
}

# Kargo Project
resource "kubectl_manifest" "kargo_project" {
  yaml_body = yamlencode({
    apiVersion = "kargo.akuity.io/v1alpha1"
    kind       = "Project"
    metadata = {
      name = "hello"
    }
    spec = {
      promotionPolicies = [
        {
          stage                = "hello-staging"
          autoPromotionEnabled = true
        },
        {
          stage                = "hello-production"
          autoPromotionEnabled = false
        }
      ]
    }
  })

  depends_on = [helm_release.kargo, time_sleep.wait_for_kargo_crds]
}

resource "time_sleep" "wait_for_kargo_project" {
  depends_on = [kubectl_manifest.kargo_project]
  create_duration = "10s"
}

# Kargo Warehouse
resource "kubectl_manifest" "kargo_warehouse" {
  yaml_body = yamlencode({
    apiVersion = "kargo.akuity.io/v1alpha1"
    kind       = "Warehouse"
    metadata = {
      name      = "hello"
      namespace = "hello"
    }
    spec = {
      subscriptions = [
        {
          git = {
            repoURL = local.repository_url
            branch  = "main"
          }
        }
      ]
    }
  })

  depends_on = [time_sleep.wait_for_kargo_project]
}

# Kargo Stage - Staging
resource "kubectl_manifest" "kargo_stage_staging" {
  yaml_body = yamlencode({
    apiVersion = "kargo.akuity.io/v1alpha1"
    kind       = "Stage"
    metadata = {
      name      = "hello-staging"
      namespace = "hello"
    }
    spec = {
      requestedFreight = [
        {
          origin = {
            kind = "Warehouse"
            name = "hello"
          }
          sources = {
            direct = true
          }
        }
      ]
      promotionTemplate = {
        spec = {
          steps = [
            {
              uses = "argocd-update"
              config = {
                apps = [
                  {
                    name      = "hello-staging"
                    namespace = "argocd"
                    sources = [
                      {
                        repoURL              = local.repository_url
                        desiredRevision      = "$${{commitFrom(\"${local.repository_url}\").ID}}"
                        updateTargetRevision = true
                      }
                    ]
                  }
                ]
              }
            }
          ]
        }
      }
    }
  })

  depends_on = [time_sleep.wait_for_kargo_project]
}

# Kargo Stage - Production
resource "kubectl_manifest" "kargo_stage_production" {
  yaml_body = yamlencode({
    apiVersion = "kargo.akuity.io/v1alpha1"
    kind       = "Stage"
    metadata = {
      name      = "hello-production"
      namespace = "hello"
    }
    spec = {
      requestedFreight = [
        {
          origin = {
            kind = "Warehouse"
            name = "hello"
          }
          sources = {
            direct = false
            stages = ["hello-staging"]
          }
        }
      ]
      promotionTemplate = {
        spec = {
          steps = [
            {
              uses = "argocd-update"
              config = {
                apps = [
                  {
                    name      = "hello-production"
                    namespace = "argocd"
                    sources = [
                      {
                        repoURL              = local.repository_url
                        desiredRevision      = "$${{commitFrom(\"${local.repository_url}\").ID}}"
                        updateTargetRevision = true
                      }
                    ]
                  }
                ]
              }
            }
          ]
        }
      }
    }
  })

  depends_on = [time_sleep.wait_for_kargo_project]
}
