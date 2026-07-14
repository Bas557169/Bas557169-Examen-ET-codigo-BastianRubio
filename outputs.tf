output "vpc_id" {
  description = "ID de la VPC creada por el modulo de redes"
  value       = module.redes.vpc_id
}

output "subnet_id" {
  description = "ID de la subnet creada por el modulo de redes"
  value       = module.redes.subnet_id
}

output "instancia_id" {
  description = "ID de la EC2 creada por el modulo de computo"
  value       = module.computo.instance_id
}

output "instancia_ip_privada" {
  description = "IP privada de la EC2 creada por el modulo de computo"
  value       = module.computo.instance_private_ip
}