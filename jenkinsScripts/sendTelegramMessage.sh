#!/bin/sh

# Verificar que se proporcionaron el token y el chat ID
if [ -z "$1" ] || [ -z "$2" ]; then
     echo "Error: Token o Chat ID no proporcionados."
     exit 1
fi

# Variables
TOKEN=$1
CHAT_ID=$2
MESSAGE=$3

# Enviar mensaje a Telegram
curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
     -d chat_id="${CHAT_ID}" \
     -d text="${MESSAGE}" > /dev/null

# Verificar si el mensaje se envió correctamente
if [ $? -eq 0 ]; then
     echo "Mensaje enviado correctamente a Telegram."
else
     echo "Error al enviar el mensaje a Telegram."
     exit 1
fi

exit 0
