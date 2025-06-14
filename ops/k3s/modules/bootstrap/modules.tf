module "cert-manager" {
  source = "./cert-manager"
}

module "cnpg" {
  source = "./cnpg"
}

module "contour" {
  source = "./contour"
}

module "minio" {
  source = "./minio"
}

module "longhorn" {
  source = "./longhorn"
}
