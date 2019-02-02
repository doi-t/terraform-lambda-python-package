output "package_file_path" {
  value = "${local.package_file_path}"
}

output "local_source_code_hash" {
  value = "${data.external.source_code_hash.result["sha256"]}"
}

output "zip_package_sha256" {
  value = "${data.archive_file.lambda_zip_package.output_base64sha256}"
}
