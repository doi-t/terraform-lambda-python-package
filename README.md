# terraform-lambda-python-package
Terraform module which builds AWS Lambda Functions or AWS Lambda Layers package for Python runtime.

This module is for a person who considers a lambda function and layer is a part of infrastructure and wants to glue everything in [Terraform](https://www.terraform.io/). Please note that [Terraform is not intended to be a build tool](https://github.com/hashicorp/terraform/issues/8344#issuecomment-361014199).

The module builds a package on your local during `terraform apply` when there is a change in source directory (except for [the second deployment](https://github.com/doi-t/terraform-lambda-python-package/issues/1)).

# Usage

## AWS Lambda Functions Package

```hcl
variable "your_function_name" {
  default = "your_function"
}

module "function_package" {
  source         = "github.com/doi-t/terraform-lambda-python-package?ref=v0.2.0"
  package_name   = "${var.function_name}"
  python_version = "3.7"
  source_dir     = "src/your_function"
}

resource "aws_lambda_function" "your_example_function" {
  filename         = "${module.function_package.package_file_path}"
  source_code_hash = "${module.function_package.zip_package_sha256}"
  function_name    = "${var.function_name}"
  layers           = ["${aws_lambda_layer_version.your_example_layer.layer_arn}"]
  role             = "${aws_iam_role.iam_for_lambda.arn}" # Create your own aws_iam_role
  handler          = "main.handler" # 'handler' function in src/your_function/main.py
  runtime          = "python3.7"
}
```

## AWS Lambda Layers Package

If you want to build AWS Lambda Layers package, enable `is_lambda_layers` to place libraries in one of the folders supported by Python runtime.

Ref. https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html#configuration-layers-path

```hcl
variable "your_layer_name" {
  default = "your_layer"
}

module "layer_package" {
  source           = "github.com/doi-t/terraform-lambda-python-package?ref=v0.2.0"
  package_name     = "${var.layer_name}"
  python_version   = "3.7"
  is_lambda_layers = true
  source_dir       = "src/layers/your_layer"
}

resource "aws_lambda_layer_version" "your_example_layer" {
  filename         = "${module.layer_package.package_file_path}"
  source_code_hash = "${module.layer_package.zip_package_sha256}"
  layer_name       = "${var.layer_name}"

  compatible_runtimes = ["python3.7"]
}
```

## Source Code Management

This Module requires single directory for each package. If your implementation requires pip package dependencies, you can add `requirements.txt`. The module will detect it and install all dependencies written in `requirements.txt` to package file.

This is an example of source directory. Your source directory structure can look different unless a specified directory (`source_dir` in module) includes all necessary Python codes and dependencies in `requirements.txt`.

```
src
├── your_function
│   ├── main.py
│   └── requirements.txt
└── layers
    └── your_layer
        ├── layer_sample.py
        └── requirements.txt
```
