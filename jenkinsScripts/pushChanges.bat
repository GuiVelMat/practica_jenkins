@echo off
setlocal

REM Personalizar el mensaje del commit
set "COMMIT_MSG=Pipeline ejecutada por %1. Motivo: %2"

REM Configurar el acceso a GitHub
ssh-keyscan -t rsa github.com >> %USERPROFILE%\.ssh\known_hosts

REM Configurar el usuario y correo de Git
git config --global user.name "%1"
git config --global user.email "jenkins@pipeline.local"

REM Preparar los cambios para el commit
git add README.md

REM Crear el commit con el mensaje proporcionado
git commit -m "%COMMIT_MSG%" || echo "Nada que commitear."

REM Hacer push a la rama especificada (ci_jenkins en tu caso)
git push origin HEAD:ci_jenkins || (
    echo "Error al hacer push. Intentando hacer pull con rebase..."
    git pull --rebase origin ci_jenkins
    git push origin HEAD:ci_jenkins
)

exit /b 0