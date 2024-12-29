@echo off
setlocal

echo "envie un mensaje a telegram"
REM token
echo %~1
REM chat_id
echo %2
echo %3

REM Verificar que se proporcionaron el token y el chat ID
if "%~1"=="" (
     echo Error: Token no proporcionado.
     exit /b 1
)

if "%~2"=="" (
     echo Error: Chat ID no proporcionado.
     exit /b 1
)

REM Variables
set TOKEN=%1
set CHAT_ID=%2
REM set CHAT_ID="192580428"
@REM set MESSAGE="Todo funciona correctamente"
set MESSAGE=%3

echo %MESSAGE%

REM Enviar mensaje a Telegram
curl -s -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" ^
     -d chat_id="%CHAT_ID%" ^
     -d text="%MESSAGE%"

REM Verificar si el mensaje se envió correctamente
if %ERRORLEVEL% == 0 (
     echo Mensaje enviado correctamente a Telegram.
) else (
     echo Error al enviar el mensaje a Telegram.
     exit /b 1
)

exit /b 0
