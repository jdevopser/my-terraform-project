provider "aws" {
  region = var.region

}
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "${var.environment}-my-vpc"
  }

}
module "subnet" {
  source = "./modules/subnet"
  subnet_cidr_blocks=var.subnet_cidr_blocks
  vpc_id=aws_vpc.my-vpc.id
  environment=var.environment
}

module "web-server" {
  source = "./modules/web-server"
  vpc_id=aws_vpc.my-vpc.id
  my_ip=var.my_ip
  instance_type=var.instance_type
  environment=var.environment
  subnet_id=module.subnet.subnet.id
}