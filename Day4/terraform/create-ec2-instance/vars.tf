variable "resource_name_prefix" {
   type = string
   description = "Could be your project name or your name in training environment"
}

variable "key_name" {
   type = string
   description = "name of the key"
}

output "ssh_user" {
   value = "ubuntu"
}

output "vm_public_ip" {
  value = "aws_instance.${var.resource_name_prefix}_ubuntu1.public_ip"
}
