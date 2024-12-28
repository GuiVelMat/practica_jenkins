@echo off

REM Verifica que el token esté configurado
if "%1"=="" (
    echo Error: El token de Vercel no está configurado.
    exit /b 1
)

REM Configura el token como variable de entorno para Vercel CLI
set VERCEL_TOKEN=%1

REM Realiza el despliegue usando Vercel CLI
vercel --prod --yes --name jenkins_project --token %VERCEL_TOKEN%
if %errorlevel% neq 0 (
    echo Error durante el despliegue en Vercel.
    exit /b 1
)

echo Despliegue realizado correctamente en Vercel.
exit /b 0