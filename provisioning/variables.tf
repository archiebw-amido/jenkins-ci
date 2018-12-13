variable "region" {
    default = "eu-west-2"  
}
variable "availability_zones" {
    default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "namespace" {
  default = "abw"
}

variable "stage" {
  default = "ci"
}

variable "name" {
  default = "jenkinsCI"
}

variable "delimiter" {
  default     = "-"
}

variable "attributes" {
  type        = "list"
  default     = ["terraform"]
}

variable "tags" {
  type        = "map"
  default     = {
    createdBy = "abw-terraform"
  }
}
