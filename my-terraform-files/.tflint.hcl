# .tflint.hcl

# Configure the AWS plugin for TFLint
plugin "aws" {
  enabled = true # Enable the AWS plugin
  version = "0.32.0" # Version of the AWS plugin to use (replace with the latest version)
  source  = "github.com/terraform-linters/tflint-ruleset-aws" # Source repository for AWS plugin rules
  region  = "us-east-1" # AWS region to use for AWS-specific checks
}
