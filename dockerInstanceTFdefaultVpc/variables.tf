# --------------------------------------------------------------------
# Region and AZ for networking resources and instance
# --------------------------------------------------------------------

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "availability_zone" {
  type    = string
  default = "us-west-2a"
}

# --------------------------------------------------------------------
# Tag value for all resources
# --------------------------------------------------------------------

variable "tags" {
  type    = map(string)
  default = {
    Project = "DockerInstance"
  }
}

# --------------------------------------------------------------------
# Private Key & Key Pair Variables
# --------------------------------------------------------------------

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "dockerInstanceKeyPairSSH"
}

variable "private_key_path" {
  description = "File name; saves locally in same folder as TF module"
  type        = string
  default     = "dockerInstanceKeyPairSSH.pem"
}

# --------------------------------------------------------------------
# Instance variables
# --------------------------------------------------------------------

variable "ami_id" {
  description = "Ubuntu 22.04"
  type        = string
  default     = "ami-00f46ccd1cbfb363e"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip" {
  description = "Attach a public IP to the instance"
  type        = bool
  default     = true
}