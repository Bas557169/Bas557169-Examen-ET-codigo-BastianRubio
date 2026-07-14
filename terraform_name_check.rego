package terraform.authz

default allow = false

# Permitimos el despliegue si no existen violaciones en el análisis de seguridad
allow = respuesta {
    # Si la lista de violaciones del archivo anterior está vacía, se autoriza
    count(data.terraform.analysis.violation) == 0
    respuesta := {
        "status": true,
        "message": "Politicas aprobadas. Despliegue autorizado."
    }
}