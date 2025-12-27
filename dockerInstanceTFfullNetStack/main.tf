# --------------------------------------------------------------------
# Local variable for user IP address, and cleaning up VM IP for SSH url
# --------------------------------------------------------------------

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
  instanceIpAddress        = aws_instance.dockerVmInstance.public_ip
  dashedInstanceIpAddress = replace(local.instanceIpAddress, ".", "-")
}

# --------------------------------------------------------------------
# Create a VPC
# --------------------------------------------------------------------

resource "aws_vpc" "dockerVmVpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "DockerInstance_VPC"
    }
  )
}

# --------------------------------------------------------------------
# Create a Public Subnet in the VPC
# --------------------------------------------------------------------

resource "aws_subnet" "dockerVmPublicSubnet" {
  vpc_id                  = aws_vpc.dockerVmVpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "DockerInstance_PublicSubnet"
    }
  )
}

# --------------------------------------------------------------------
# Create an Internet Gateway (IGW) in the VPC
# --------------------------------------------------------------------

resource "aws_internet_gateway" "dockerVmIgw" {
  vpc_id = aws_vpc.dockerVmVpc.id

  tags = merge(
    var.tags,
    {
      Name = "DockerInstance_IGW"
    }
  )
}

# --------------------------------------------------------------------
# Create a Route Table directing outbound traffic to IGW
# --------------------------------------------------------------------

resource "aws_route_table" "dockerVmRouteTable" {
  vpc_id = aws_vpc.dockerVmVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dockerVmIgw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "DockerInstance_RouteTable"
    }
  )
}

# --------------------------------------------------------------------
# Associate the Subnet to the Route Table
# --------------------------------------------------------------------

resource "aws_route_table_association" "dockerVmRTassign" {
  subnet_id      = aws_subnet.dockerVmPublicSubnet.id
  route_table_id = aws_route_table.dockerVmRouteTable.id
}

# --------------------------------------------------------------------
# Create a Security Group and Ingress/Egress Rules
# --------------------------------------------------------------------

resource "aws_security_group" "dockerVmSecurityGroup" {
  name        = "DockerInstance_SecurityGroup"
  description = "Allow SSH access to 22 from user IP only"
  region      = var.aws_region
  vpc_id      = aws_vpc.dockerVmVpc.id

  tags = merge(
    var.tags,
    {
      Name = "DockerInstance_SecurityGroup"
    }
  )
}

# Create an Ingress rule only allowing local IP to access port 22
resource "aws_vpc_security_group_ingress_rule" "dockerVmSGIngress22" {
  region            = var.aws_region
  security_group_id = aws_security_group.dockerVmSecurityGroup.id
  cidr_ipv4         = local.my_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Create an Egress rule allowing all outbound traffic
resource "aws_vpc_security_group_egress_rule" "dockerVmSGEgressOpen" {
  region            = var.aws_region
  security_group_id = aws_security_group.dockerVmSecurityGroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# --------------------------------------------------------------------
# Create Private Key and Key Pair for SSH access, and save pem file locally
# --------------------------------------------------------------------

resource "tls_private_key" "dockerVmprivateKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dockerVmkeyPair" {
  key_name   = var.key_name
  region     = var.aws_region
  public_key = tls_private_key.dockerVmprivateKey.public_key_openssh
}

resource "local_file" "dockerVmprivate_key_pem" {
  filename        = var.private_key_path
  content         = tls_private_key.dockerVmprivateKey.private_key_pem
  file_permission = "0400"
}

# --------------------------------------------------------------------
# Create EC2 instance connected to the networking resources created above
# --------------------------------------------------------------------

resource "aws_instance" "dockerVmInstance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  region                 = var.aws_region
  subnet_id              = aws_subnet.dockerVmPublicSubnet.id
  vpc_security_group_ids = [aws_security_group.dockerVmSecurityGroup.id]
  key_name               = aws_key_pair.dockerVmkeyPair.key_name

  associate_public_ip_address = var.associate_public_ip

  user_data = file("install_docker.sh")

  tags = merge(
    var.tags,
    {
      Name = "DockerInstance_Instance"
    }
  )
}