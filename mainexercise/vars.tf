variable "REGION" {
  default = "us-east-1"
}

variable "ZONE1" {
  default = "us-east-1a"
}

variable "AMI" {
  type = map(any)
  default = {
    us-east-1 = "ami-0bb4c991fa89d4b9b"
  }
}