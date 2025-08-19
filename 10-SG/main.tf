# ingress-alb SG details
module "ingress_alb" {
  source = "../../terraform-aws-security group" # Use the child path to the module
  #source = "git::https://github.com/Nagaraj411/terraform-aws-security-group.git?ref=main"
  project     = var.project
  environment = var.environment

  sg_name        = "ingress_alb"
  sg_description = "for ingress_alb"
  vpc_id         = local.vpc_id
}

module "bastion" {
  source = "../../terraform-aws-security group" # Use the child path to the module
  #source = "git::https://github.com/Nagaraj411/terraform-aws-security-group.git?ref=main"
  project     = var.project
  environment = var.environment

  sg_name        = var.bastion_sg_name
  sg_description = var.bastion_sg_description
  vpc_id         = local.vpc_id
}

module "vpn" {                                  # This module is used to create a security group for the VPN
  source = "../../terraform-aws-security group" # Use the child path to the module
  #source = "git::https://github.com/Nagaraj411/terraform-aws-security-group.git?ref=main"
  project     = var.project
  environment = var.environment

  sg_name        = "vpn"
  sg_description = "for vpn"
  vpc_id         = local.vpc_id
}

module "eks_control_plane" {                                  # This module is used to create a security group for the EKS control plane
  source = "../../terraform-aws-security group" # Use the child path to the module
  #source = "git::https://github.com/Nagaraj411/terraform-aws-security-group.git?ref=main"
  project     = var.project
  environment = var.environment

  sg_name        = "eks_control_plane"
  sg_description = "for eks_control_plane"
  vpc_id         = local.vpc_id
}

module "eks_node" {                                  # This module is used to create a security group for the EKS nodes
  source = "../../terraform-aws-security group" # Use the child path to the module
  #source = "git::https://github.com/Nagaraj411/terraform-aws-security-group.git?ref=main"
  project     = var.project
  environment = var.environment

  sg_name        = "eks_node"
  sg_description = "for eks_node"
  vpc_id         = local.vpc_id
}

#=================================================================================================================================================================
#=================================================================================================================================================================
#=================================================================================================================================================================

# Store the security group ID in SSM Parameter Store for bastion instances security group
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  from_port         = 22 # ssh port ec2 instance
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# vpn ports 22, 443, 943, 1194
resource "aws_security_group_rule" "vpn_ingress" {  # vpn_ssh or vpn_ingress both are same
  count             = length(var.vpn_ingress)
  type              = "ingress"
  from_port         = var.vpn_ingress[count.index]
  to_port           = var.vpn_ingress[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

# Store the security group ID in SSM Parameter Store for EKS control plane security group
resource "aws_security_group_rule" "eks_control_plane_eks_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_node.sg_id
  security_group_id = module.eks_control_plane.sg_id
}

# Store the security group ID in SSM Parameter Store for EKS node security group
resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_control_plane.sg_id
  security_group_id = module.eks_node.sg_id
}


resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "-1"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_control_plane.sg_id
}

resource "aws_security_group_rule" "eks_node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "-1"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_node.sg_id
}

resource "aws_security_group_rule" "eks_node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id = module.vpn.sg_id
}