# Variables
variable "required_tags" {
  type    = list(string)
  default = ["Name", "Owner"]
}

variable "vm_size" {
  type    = string
  default = "Standard_A2"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}