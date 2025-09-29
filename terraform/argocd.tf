# Argo CD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.6.12"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    <<EOF
global:
  domain: localhost:8080

configs:
  params:
    server.insecure: true
  secret:
    argocdServerAdminPassword: $2a$10$bwOuk7sQB3LZMbZzrimA1Oyd5tLLJxhda.RjJhURHsNhxMvuXfzRO

server:
  service:
    type: ClusterIP
    port: 80
  ingress:
    enabled: false
  extraArgs:
    - --insecure

repoServer:
  env:
    - name: ARGOCD_EXEC_TIMEOUT
      value: "300s"

controller:
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true

dex:
  enabled: false

notifications:
  enabled: false

applicationSet:
  enabled: true
EOF
  ]
}
