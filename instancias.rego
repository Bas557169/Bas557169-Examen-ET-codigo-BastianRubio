package terraform.analysis

# Regla 1: Bloquear si hay SSH público (puerto 22 abierto a 0.0.0.0/0)
violation[msg] {
    recurso := input.resource_changes[_]
    recurso.type == "aws_security_group"
    ingress := recurso.change.after.ingress[_]
    
    ingress.from_port <= 22
    ingress.to_port >= 22
    
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    
    msg := "ERROR: No se permite acceso SSH público (0.0.0.0/0) en el Security Group."
}

# Regla 2: Bloquear si la instancia no es t2.micro
violation[msg] {
    recurso := input.resource_changes[_]
    recurso.type == "aws_instance"
    recurso.change.actions[_] == "create"
    recurso.change.after.instance_type != "t2.micro"
    
    msg := sprintf("ERROR: Tipo de instancia '%v' no permitido. Solo se permite 't2.micro'.", [recurso.change.after.instance_type])
}