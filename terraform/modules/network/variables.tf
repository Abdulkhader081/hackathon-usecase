variable "project" {
  type = string
}

variable "region" {
  type = string
}

# SSH sources — default is empty so SSH is not allowed unless set.
variable "ssh_source_ranges" {
  type        = list(string)
  default     = []
}

# Ports your microservices need to expose
variable "microservice_ports" {
  type    = list(string)
  default = ["3001", "3002", "8080"]
}

# Who can access microservice ingress?
variable "microservice_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
