
variable "private_subnet_ids" {
    type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "ec2_sg_id" {
  type = string
}
