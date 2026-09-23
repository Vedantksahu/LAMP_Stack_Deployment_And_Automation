output "public_ip" {
  value = aws_instance.lamp_ec2.public_ip
}

output "instance_id" {
  value = aws_instance.lamp_ec2.id
}

# Writes an Ansible inventory file automatically after `terraform apply`
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
  [lamp]
  ${aws_instance.lamp_ec2.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem
  EOT
}
