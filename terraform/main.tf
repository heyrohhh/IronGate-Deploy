module "vpc" {
  source = "./module/vpc"
}

module "alb" {
  source             = "./module/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = [module.vpc.public_subnet_id, module.vpc.public_subnet2_id]
  alb_sg_id          = module.vpc.alb_sg_id
}

module "ec2" {
  source           = "./module/ec2"
  ec2_subnet       = module.vpc.private_subnet_id 
  sg_id            = module.vpc.ec2_sg_id         
  target_group_arn = module.alb.tg_arn
  public_subnet_id = module.vpc.public_subnet_id
  bastion_sg_id =   module.vpc.bastion_sg_id
}

