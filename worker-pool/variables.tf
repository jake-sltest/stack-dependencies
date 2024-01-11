variable "worker_pool_config" {
  type = string
}

variable "worker_pool_private_key" {
  type = string
}

variable "worker_pool_id" {
  type = string
}

variable "worker_pool_security_groups" {
  type = list(string)
}

variable "worker_pool_subnets" {
  type = list(string)
}