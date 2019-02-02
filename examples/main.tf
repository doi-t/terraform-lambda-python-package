provider "aws" {
  version = "~> 1.57.0"
  region  = "ap-northeast-1" # Use your region
}

locals {
  function_name           = "example-terraform-lambda-python-package"
  function_python_version = "3.7"
}

module "function_package" {
  source         = "../"
  package_name   = "${local.function_name}"
  python_version = "${local.function_python_version}"
  source_dir     = "src/"
}

output "package_file_path" {
  value = "${module.function_package.package_file_path}"
}

output "local_source_code_hash" {
  value = "${module.function_package.local_source_code_hash}"
}

output "zip_package_sha256" {
  value = "${module.function_package.zip_package_sha256}"
}
