variable "cidr" {
  description = "The IPv4 CIDR block of the VPC."
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "Must be valid IPv4 CIDR"
  }
}

variable "azs" {
  description = "A list of availability zone names in the region."
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of CIDR blocks for the public subnets inside the VPC."
  type        = list(string)
  default     = []
  validation {
    condition     = can([for v in var.public_subnets : cidrhost(v, 0)])
    error_message = "Elements must be valid IPv4 CIDRs"
  }
}

variable "private_subnets" {
  description = "A list of CIDR blocks for the private subnets inside the VPC."
  type        = list(string)
  default     = []
  validation {
    condition     = can([for v in var.private_subnets : cidrhost(v, 0)])
    error_message = "Elements must be valid IPv4 CIDRs"
  }
}

variable "nat_gws" {
  description = "Number of NAT Gateways to create."
  type        = number
  default     = 0
}

variable "flow_log_config" {
  description = "An object for the definition for a flow log of the VPC."
  type = object({
    identifier        = string
    traffic_type      = string
    retention_in_days = number
  })
  default = null
  validation {
    condition     = length(try(var.flow_log_config["identifier"], "abc")) > 2
    error_message = "Identifier must be at least 3 characters"
  }
  validation {
    condition = try(var.flow_log_config["traffic_type"], "ALL") == "ALL" || (
      try(var.flow_log_config["traffic_type"], "ACCEPT") == "ACCEPT") || (
    try(var.flow_log_config["traffic_type"], "REJECT") == "REJECT")
    error_message = "Traffic type must be 'ALL', 'ACCEPT' or 'REJECT'"
  }
  validation {
    condition = try(var.flow_log_config["retention_in_days"], 1) == 1 || (
      try(var.flow_log_config["retention_in_days"], 3) == 3) || (
      try(var.flow_log_config["retention_in_days"], 5) == 5) || (
      try(var.flow_log_config["retention_in_days"], 7) == 7) || (
      try(var.flow_log_config["retention_in_days"], 14) == 14) || (
      try(var.flow_log_config["retention_in_days"], 30) == 30) || (
      try(var.flow_log_config["retention_in_days"], 365) == 365) || (
    try(var.flow_log_config["retention_in_days"], 0) == 0)
    error_message = "Retention in days must be one of these values: 0, 1, 3, 5, 7, 14, 30, 365"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
