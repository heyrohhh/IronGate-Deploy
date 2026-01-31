module "vpc" {
  source = "./modules/vpc"
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg.alb_sg_id
}

module "asg" {
  source             = "./modules/asg"
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id          = module.sg.ec2_sg_id
  target_group_arn  = module.alb.target_group_arn
}



