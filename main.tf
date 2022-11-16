module "networking" {
  source        = "./networking"
  vpc_cidr      = "10.0.0.0/16"
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

}

module "application" {
  count          = 3
  source         = "./application"
  web_sg         = module.networking.ec2_sg
  private_subnet = element(module.networking.private_subnet, count.index)
  key_name = "04NSOC.SUPP.0000.NSV-kp"
  kms_key_id = "94e44c5d-08eb-4511-8f6a-c5ff72dc5526"
  role_name = "ssm-role-${count.index}"
  instance_profile = "ec2-instance-profile-${count.index}"
  # user_data = file("./user_data.sh") 
  ec2_tags = "04NSOC.SUPP.0000.NSV-${count.index}"

}

module "loadbalancing" {
  source         = "./loadbalancing"
  public_subnet = module.networking.public_subnet
  vpc_id         = module.networking.vpc_id
  web_sg         = module.networking.web_sg
  target_id1 = "${module.application.0.instance_id1}"
  target_id2 = "${module.application.1.instance_id2}"
  target_id3 = "${module.application.2.instance_id3}"
}