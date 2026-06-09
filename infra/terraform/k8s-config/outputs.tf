output "namespaces" {
  value       = [kubernetes_namespace.prod.metadata[0].name, kubernetes_namespace.staging.metadata[0].name]
  description = "Created namespaces"
}
