provider "aws" {
  region = "eu-west-1"
}

module "keypair" {
  source = "git::https://github.com/clouddrove/terraform-aws-keypair.git"

  key_path        = "~/.ssh/id_rsa.pub"
  key_name        = "main-key"
  enable_key_pair = true
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  cidr_block = "172.16.0.0/16"
}

module "public_subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git"

  name        = "public-subnet"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  availability_zones = ["eu-west-1a", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
}

module "http-https" {
  source      = "git::https://github.com/clouddrove/terraform-aws-security-group.git"
  name        = "http-https"
  application = "clouddrove"
  label_order = ["environment", "name", "application"]

  environment   = "test"
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["0.0.0.0/0"]
  allowed_ports = [80, 443]
}

module "ssh" {
  source      = "git::https://github.com/clouddrove/terraform-aws-security-group.git"
  name        = "ssh"
  application = "clouddrove"
  label_order = ["environment", "name", "application"]

  environment   = "test"
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [22]
}

module "ec2" {
  source = "git::https://github.com/clouddrove/terraform-aws-ec2.git"

  name        = "ec2-instance"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  instance_count              = 2
  ami                         = "ami-08d658f84a6d84a80"
  ebs_optimized               = false
  instance_type               = "t2.nano"
  key_name                    = module.keypair.name
  monitoring                  = false
  associate_public_ip_address = true
  tenancy                     = "default"
  disk_size                   = 8
  vpc_security_group_ids_list = [module.ssh.security_group_ids, module.http-https.security_group_ids]
  subnet_ids                  = tolist(module.public_subnets.public_subnet_id)

  assign_eip_address = true

  ebs_volume_enabled = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30
}

module "acm" {
  source = "git::https://github.com/clouddrove/terraform-aws-acm.git"

  name        = "certificate"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  domain_name          = "clouddrove.com"
  validation_method    = "EMAIL"
  validate_certificate = true
}

module "alb" {
  source = "git::https://github.com/clouddrove/terraform-aws-alb.git"

  name        = "alb"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  internal                   = false
  load_balancer_type         = "application"
  instance_count             = module.ec2.instance_count
  security_groups            = [module.ssh.security_group_ids, module.http-https.security_group_ids]
  subnets                    = module.public_subnets.public_subnet_id
  enable_deletion_protection = false

  target_id             = module.ec2.instance_id
  vpc_id                = module.vpc.vpc_id
  target_group_protocol = "HTTP"
  target_group_port     = 80

  listener_certificate_arn = module.acm.arn
  https_enabled            = true
  http_enabled             = true
  https_port               = 443
  listener_type            = "forward"

}