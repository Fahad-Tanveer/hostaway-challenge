# Kargo
resource "helm_release" "kargo" {
  name       = "kargo"
  repository = "oci://ghcr.io/akuity/kargo-charts"
  chart      = "kargo"
  version    = "1.7.5"
  namespace  = kubernetes_namespace.kargo.metadata[0].name

  wait    = true
  timeout = 600

  values = [
    <<EOF
controller:
  enabled: true

api:
  enabled: true
  service:
    type: NodePort
    nodePort: 30303
  adminAccount:
    passwordHash: $2a$12$AEwlgYTiM31XyRtDdnrqlOIsKSBLusKY/818iYDfjnP1UkK88kWkC
    tokenSigningKey: jscntWZwmZ2uCMubrxYjVfqe3UMZ3+n0c6DxD0w

externalWebhooksServer:
  enabled: false

webhooks:
  regsiter: true

webhooksServer:
  enabled: true

managementController:
  enabled: true

garbageCollector:
  enabled: true

dexServer:
  enabled: false
EOF
  ]
  depends_on = [helm_release.cert-manager]
}
