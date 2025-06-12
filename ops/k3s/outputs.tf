output "f2-cluster" {
  value     = module.f2.f2-cluster
  sensitive = true
}

output "f2-control-db" {
  value     = module.f2.f2-control-db
  sensitive = true
}
