variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_ports" {
  description = "List of ports to allow for inbound traffic"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
