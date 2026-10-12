
variable "project_name" {
  description = "Name of the TerraWeek project"
  type        = string
  default     = "terraweek"
}

variable "vpc_cidr" {
  description = "CIDR block for the environment VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the environment"
  type        = string
}

variable "ingress_ports" {
  description = "TCP ports allowed inbound"
  type        = list(number)
  default     = [22, 80]
}
