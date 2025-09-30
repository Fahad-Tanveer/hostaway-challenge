resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  version    = "v1.18.2"
  wait = true
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name
  values = [
    <<EOF
prometheus:
  enabled: false
crds:
  enabled: true
EOF
  ]
}
