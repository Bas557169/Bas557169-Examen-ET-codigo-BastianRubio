provider "aws" {
  region = "us-east-1"
}

# 1. Llamada a tu Módulo de Redes
module "redes" {
  source = "github.com/Bas557169/Examen-ET-C-digo-BastianRubio-prueba-2-1-?ref=v1.0.0"

  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  vpc_name          = "duoc_vpc_principal"
  subnet_name       = "duoc_subnet_principal"
  sg_name           = "duoc_sg_principal"
}

# 2. Llamada a tu Módulo de Cómputo (EC2)
module "computo" {
  source = "github.com/Bas557169/Examen-ET-Bastianrubio-2--2--EC2?ref=v1.0.0"

  ami_id            = "ami-0bb84b8ffd87024d8"
  instance_type     = "t2.micro" # Requisito OPA: t2.micro
  instance_name     = "duoc_ec2_principal"
  
  # Conexión dinámica usando los outputs de tu módulo de red
  subnet_id         = module.redes.subnet_id
  security_group_id = module.redes.security_group_id
}