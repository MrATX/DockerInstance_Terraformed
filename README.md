# DockerInstance_Terraformed
Terraform modules for deploying an EC2 instance and installing Docker

Uses Terraform to deploy an AWS EC2 instance and install Docker, then outputs a link to SSH into the instance

Module includes:
- EC2 instance using Ubuntu 22.04
- Bash script run via user data to clone "MrATXDockerScripts" repo, and run the Docker install script
- Private Key and Key Pair saved locally for SSH access
- Security Group with an ingress rule allowing access to port 22 from the IP you run the Terraform plan from, and with open egress

The "defaultVpc" version of the module only deploys the EC2 instance, Key Pair, and Security Group, which will use the default VPC and one of its subnets for the region.

The "fullNetStack" version of the module creates an independent networking setup for the app by also deploying a VPC, public subnet, Internet Gateway (IGW), and route table.


*** Requirements
- An AWS Account
- AWS CLI
- Terraform
- That should be it!


Notes
- Deafult region is us-west-2
- Security Group allows SSH access from your IP; it does not allow any other ingress
- Output includes a link to SSH into the machine from the same place you run the TF module
