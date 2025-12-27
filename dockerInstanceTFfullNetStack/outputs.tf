output "ssh_link" {
  value = "ssh -i ${var.private_key_path} ubuntu@ec2-${local.dashedInstanceIpAddress}.${var.aws_region}.compute.amazonaws.com"
}