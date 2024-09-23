provider "aws" {
  region = "us-east-1"
  shared_config_files = ["/home/pngash/.aws/config"]
  shared_credentials_files = ["/home/pngash/.aws/credentials"]
  profile = "default"
}