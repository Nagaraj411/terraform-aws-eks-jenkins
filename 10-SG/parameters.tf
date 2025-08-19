# Store the security group ID in SSM Parameter Store for ingress ALB security group
resource "aws_ssm_parameter" "ingress_alb_sg_id" {
  name  = "/${var.project}/${var.environment}/ingress_alb_sg_id"
  type  = "String"
  value = module.ingress_alb.sg_id
}

# Store the security group ID in SSM Parameter Store for bastion security group
resource "aws_ssm_parameter" "bastion_sg_id" {
  name  = "/${var.project}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = module.bastion.sg_id
}

# Store the security group ID in SSM Parameter Store for VPN security group
resource "aws_ssm_parameter" "vpn_sg_id" {
  name  = "/${var.project}/${var.environment}/vpn_sg_id"
  type  = "String"
  value = module.vpn.sg_id
}

# Store the security group ID in SSM Parameter Store for EKS control plane security group
resource "aws_ssm_parameter" "eks_control_plane_sg_id" {
  name  = "/${var.project}/${var.environment}/eks_control_plane_sg_id"
  type  = "String"
  value = module.eks_control_plane.sg_id
}


# Store the security group ID in SSM Parameter Store for EKS nodes security group
resource "aws_ssm_parameter" "eks_node_sg_id" {
  name  = "/${var.project}/${var.environment}/eks_node_sg_id"
  type  = "String"
  value = module.eks_node.sg_id
}




