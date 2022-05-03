variable "name" {
  type    = string
  default = "go-hello-eks"
}

variable "name_ecr" {
  type    = string
  default = "go-hello-ecr"
}

variable "cluster_version" {
  type    = string
  default = "1.22"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}
