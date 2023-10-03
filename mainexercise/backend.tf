terraform {
  backend "s3" {
    bucket = "bucket123unique1"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
