#!/bin/sh

# Verifica que el token esté configurado
if [ -z "$1" ]; then
     echo "Error: El token de Vercel no está configurado."
     exit 1
fi

# Configura el token como variable de entorno para Vercel CLI
export VERCEL_TOKEN=$1

# Realiza el despliegue usando Vercel CLI
vercel --prod --yes --name jenkins_project --token $VERCEL_TOKEN || {
     echo "Error durante el despliegue en Vercel."
     exit 1
}

echo "Despliegue realizado correctamente en Vercel."
exit 0
