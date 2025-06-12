output "f2-cluster" {
  value     = kubectl_manifest.f2-cluster.yaml_body
  sensitive = true
}

output "f2-control-db" {
  value     = kubectl_manifest.f2-control-db.yaml_body
  sensitive = true
}
