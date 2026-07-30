variable "env" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "key_name" {
  type = string
}