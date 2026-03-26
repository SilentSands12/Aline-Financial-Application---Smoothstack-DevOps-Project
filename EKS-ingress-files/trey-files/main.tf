resource "helm_release" "nginx_ingress_controller" {
  name       = var.release_name
  repository = var.repository
  chart      = var.chart

  values = [
    <<EOF
controller:
  service:
    name: "custom-nginx-ingress"
    type: LoadBalancer
EOF
  ]

  set {
    name  = var.service_type_key
    value = var.service_type_value
  }
}
