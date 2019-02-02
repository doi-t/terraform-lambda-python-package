locals {
  build_dir    = "build"
  packages_dir = "packages"
  function_dir = "${local.packages_dir}/${var.package_name}"
  layer_dir    = "${local.packages_dir}/${var.package_name}/python"

  # A package directory that manages all source codes and its dependencies with requirements.txt
  package_source_dir = "${var.is_lambda_layers ? local.layer_dir : local.function_dir }"
  archive_source_dir = "${local.packages_dir}/${var.package_name}"
  package_file_path  = "${local.archive_source_dir}/${var.package_name}.zip"
}

# Generate source code hash depending on package_file_path and source code in source directory
# Note that any code changes in source directory changes the result of source code hash
# Ref. https://github.com/hashicorp/terraform/issues/10878#issuecomment-453241734
data "external" "source_code_hash" {
  program = ["bash", "${path.module}/check-source-code-hash.sh"]

  query = {
    package_file = "${local.package_file_path}"
    source_dir   = "${var.source_dir}"
  }
}

# Ref. https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204
resource "null_resource" "build_lambda_package" {
  triggers {
    src_hash = "${data.external.source_code_hash.result["sha256"]}"
  }

  provisioner "local-exec" {
    command = "${path.module}/build-lambda-package.sh ${var.package_name} ${var.python_version} ${var.source_dir} ${local.package_source_dir} ${local.build_dir}"
  }
}

# NOTE: 'terrraform plan' does not evaluate 'data'.
# As a result, you always see a change of source_code_hash in plan but it won't happen in apply 
# if there is no code change in source directory.
# Ref. https://github.com/hashicorp/terraform/issues/17034
data "archive_file" "lambda_zip_package" {
  type        = "zip"
  source_dir  = "${local.archive_source_dir}"
  output_path = "${local.package_file_path}"

  depends_on = ["null_resource.build_lambda_package"]
}
