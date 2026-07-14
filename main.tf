provider "aws" {
  region = "us-east-1"
}

# 1. Llamada a tu Módulo de Redes
module "redes" {
  source = "github.com/Bas557169/Examen-ET-C-digo-BastianRubio-prueba-2-1-?ref=v1.0.0"

  # Sincronizado con tus recursos reales de AWS:
  vpc_cidr          = "10.1.0.0/16"               # Antes era 10.0.0.0/16
  subnet_cidr       = "10.1.1.0/24"               # Antes era 10.0.1.0/24
  availability_zone = "us-east-1a"
  vpc_name          = "AUY1105-duocapp-vpc"       # Nombre real en AWS
  subnet_name       = "AUY1105-duocapp-subnet"    # Nombre real en AWS
  sg_name           = "AUY1105-duocapp-sg"        # Nombre real en AWS
}

# 2. Llamada a tu Módulo de Cómputo (EC2)
module "computo" {
  source = "github.com/Bas557169/Examen-ET-Bastianrubio-2--2--EC2?ref=v1.0.1"

  # Sincronizado con tus recursos reales de AWS:
  ami_id        = "ami-0fc5d935ebf8bc3bc"         # Antes era ami-0bb84b8ffd87024d8
  instance_type = "t2.micro" 
  instance_name = "AUY1105-duocapp-ec2"           # Nombre real en AWS
  
  # Conexión dinámica usando los outputs de tu módulo de red
  subnet_id         = module.redes.subnet_id
  security_group_id = module.redes.security_group_id
}