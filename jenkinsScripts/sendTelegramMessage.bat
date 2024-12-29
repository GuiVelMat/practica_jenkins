@echo off
setlocal

echo "envie un mensaje a telegram"
echo %~1
echo %~2

REM Verificar que se proporcionaron el token y el chat ID
if "%~1"=="" (
     echo Error: Token no proporcionado.
     exit /b 1
)

if "%~2"=="" (
     echo Error: Chat ID no proporcionado.
     exit /b 1
)

echo "pasa los if"

REM Variables
set TOKEN=%1
set CHAT_ID=%2
set MESSAGE="hola"

REM Enviar mensaje a Telegram
curl -s -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" ^
     -d chat_id="%CHAT_ID%" ^
     -d text="%MESSAGE%" >nul

REM Verificar si el mensaje se envió correctamente
if %ERRORLEVEL% == 0 (
     echo Mensaje enviado correctamente a Telegram.
) else (
     echo Error al enviar el mensaje a Telegram.
     exit /b 1
)

exit /b 0
