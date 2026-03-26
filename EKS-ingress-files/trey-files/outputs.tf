output "nginx_ingress_controller_release_name" {
  description = "The name of the Helm release created"
  value       = helm_release.nginx_ingress_controller.metadata.0.name
}

