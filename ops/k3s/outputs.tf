output "f2-cluster" {
  value     = module.f2-infra.f2-cluster
  sensitive = true
}

output "f2-control-db" {
  value     = module.f2-infra.f2-control-db
  sensitive = true
}
