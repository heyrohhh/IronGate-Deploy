
variable "ami" {
    type = string
    default = "ami-07ff62358b87c7116"
}



variable "ec2_subnet" {
    type = string
}

variable "sg_id" {
    type = string
}

variable "key_name" {
    type = string
    default = "Portfolio_key"
}

variable "target_group_arn" {
  description = "ALB Target Group ARN for attaching instances"
  type        = string
}

variable "public_subnet_id" {
    type = string
}
variable "bastion_sg_id" {
    type = string
}
