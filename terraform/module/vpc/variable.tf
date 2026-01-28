variable "vpc_cidr" {
    type = string 
    default = "10.0.0.0/16"
}

variable "vpc_name" {
    type = string
    default = "inventory_mg"
}

variable "dns_hostname" {
    type = bool
    default = true
}

variable "dns_support" {
    type = bool
    default = true
}

variable "zone" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
