variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}


variable "instance_tenancy" {
  description = "Tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "create_igw" {
  description = "Whether to create an Internet Gateway and attach it to the VPC"
  type        = bool
  default     = true
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}