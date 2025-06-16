module "cnpg" {
  depends_on = [module.bootstrap, module.longhorn]
  source     = "./modules/cnpg"
}

module "contour" {
  depends_on = [module.cert-manager]
  source     = "./modules/contour"
}

module "bootstrap" {
  source           = "./modules/bootstrap"
  environment      = var.environment
  dockerconfigjson = var.dockerconfigjson
}

module "cert-manager" {
  depends_on  = [module.bootstrap]
  source      = "./modules/cert-manager"
  environment = var.environment
}

module "minio" {
  depends_on = [module.bootstrap, module.longhorn]
  source     = "./modules/minio"
}

module "longhorn" {
  depends_on = [module.bootstrap]
  source     = "./modules/longhorn"
}

module "f2-infra" {
  depends_on            = [module.bootstrap, module.cnpg, module.contour, module.cert-manager]
  source                = "./modules/f2-infra"
  environment           = var.environment
  ghcr-pull-secret-name = module.bootstrap.ghcr-pull-secret-name
  namespace             = module.bootstrap.f2-namespace
  public-url            = local.public-url
  public-fqdn           = local.public-fqdn
  # public-realtime-url   = local.public-realtime-url
}
