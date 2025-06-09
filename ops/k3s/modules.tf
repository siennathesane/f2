module "cnpg" {
  source = "./modules/cnpg"
}

module "f2" {
  source                = "./modules/f2-infra"
  environment           = var.environment
  ghcr-pull-secret-name = module.bootstrap.ghcr-pull-secret-name
  namespace             = module.bootstrap.f2-namespace
  public-url            = local.public-url
}

module "bootstrap" {
  source      = "./modules/bootstrap"
  environment = var.environment
}

module "cert-manager" {
  source      = "./modules/cert-manager"
  environment = var.environment
}
