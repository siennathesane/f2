module "cnpg" {
  depends_on = [module.bootstrap]
  source     = "./modules/cnpg"
}

module "contour" {
  depends_on = [module.cert-manager]
  source     = "./modules/contour"
}

module "bootstrap" {
  source      = "./modules/bootstrap"
  environment = var.environment
}

module "cert-manager" {
  depends_on  = [module.bootstrap]
  source      = "./modules/cert-manager"
  environment = var.environment
}

module "minio" {
  depends_on = [module.bootstrap]
  source     = "./modules/minio"
}

module "f2-infra" {
  depends_on            = [module.bootstrap, module.cnpg, module.contour, module.cert-manager, module.minio]
  source                = "./modules/f2-infra"
  environment           = var.environment
  ghcr-pull-secret-name = module.bootstrap.ghcr-pull-secret-name
  namespace             = module.bootstrap.f2-namespace
  public-url            = local.public-url
  # public-realtime-url   = local.public-realtime-url
}
