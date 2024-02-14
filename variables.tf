variable "name" {
  description = "Name of this module which is used as identifier on all resources"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The IPv4 CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "Must be valid IPv4 CIDR"
  }
}

variable "azs" {
  description = "A list of availability zone names in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of CIDR blocks for the public subnets inside the VPC"
  type        = list(string)
  default     = []
  validation {
    condition     = can([for v in var.public_subnets : cidrhost(v, 0)])
    error_message = "Elements must be valid IPv4 CIDRs"
  }
}

variable "private_subnets" {
  description = "A list of CIDR blocks for the private subnets inside the VPC"
  type        = list(string)
  default     = []
  validation {
    condition     = can([for v in var.private_subnets : cidrhost(v, 0)])
    error_message = "Elements must be valid IPv4 CIDRs"
  }
}

variable "nat_gw" {
  description = "A flag for wether or not creating a NAT Gateway in the first public subnet in order to route the private subnets traffic through it"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  validation {
    condition     = !contains(keys(var.tags), "Name")
    error_message = "Name tag is reserved and will be used automatically"
  }
}
