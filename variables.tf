variable "package_name" {}
variable "python_version" {}

variable "is_lambda_layers" {
  default = false
}

variable "source_dir" {
  description = "Any changes in this directory will let the module build new package"
}
