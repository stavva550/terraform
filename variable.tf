variable "cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "vpc cidr block"
}
variable "publicsubnet1" {
  type        = string
  default     = "10.0.0.0/24"
  description = "public subnet cidr block"
}
variable "publicsubnet2" {
  type        = string
  default     = "10.0.1.0/24"
  description = "private subnet cidr block"
}

