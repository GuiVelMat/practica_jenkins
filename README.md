# Introducción a Jenkins

## ¿Qué es Jenkins?

Jenkins es una herramienta de automatización de código abierto que facilita la implementación de la Integración Continua y la Entrega Continua (CI/CD). Jenkins permite a los desarrolladores automatizar la construcción, prueba y despliegue de sus aplicaciones, proporcionando una plataforma robusta y extensible con una gran cantidad de plugins para integrar diversas herramientas y tecnologías.

## ¿Qué son los Pipelines en Jenkins?

Los Pipelines en Jenkins son una serie de pasos que definen cómo se construye, prueba y despliega una aplicación. Un Pipeline puede ser tan simple o complejo como sea necesario, y se define utilizando un archivo de texto llamado `Jenkinsfile`. Este archivo contiene el código que describe las etapas del Pipeline, permitiendo a los equipos de desarrollo versionar y gestionar sus procesos de CI/CD de manera eficiente.

Con Jenkins y sus Pipelines, los equipos de desarrollo pueden automatizar y optimizar su flujo de trabajo, asegurando que el código se integre y despliegue de manera continua y confiable.


## Proyecto

### ¿Qué necesitamos?
1. **Software de Jenkins**
    - En mi caso lo he instalado directamente desde la página oficial, pero después de hacerlo recomiendo hacer la instalación mediante docker y utilizando Linux en vez de Windows.
2. **Plugin de NodeJS**
    - Una vez instalado, en las Tools debemos añadir una instalación y ponerle el nombre `Node` y la ultima versión.
3. **SSH de GitHub**
    - Lo guardo en las credenciales de Jenkins como `SSH Username with private key` con la ID `jenkins-stage-key`, el username el tuyo de Github y activamos el checkbox de private key para añadir nuestro SSH.
3. **Token de Vercel**
    - Lo guardo en las credenciales de Jenkins como `Secret Text` con la ID `vercel-deploy-token` y el Secret es el token.
4. **Token de Telegram**
    - Lo guardo en las credenciales de Jenkins como `Secret Text` con la ID `telegram-bot-token` y el Secret es el token.
5. **CURL**
    - Sin Curl instalado en nuestro sistema, no se podrán ejecutar los scripts de Telegram.


### Crear la Pipeline
1. `New Item` en el  dashboard de Jenkins.
2. Le ponemos nombre y de tipo Pipeline.
3. Le asignamos el repositorio de GitHub.
4. Seleccionamos `Pipeline script from SCM`.
5. Elegimos la rama sobre la que actúa, en mi caso `pruebas`

### Carpeta JenkinsScripts
> Los archivos de esta carpeta recogen los datos que envía el JenkinsFile.

**`deployToVercel.bat`**: Script para envíar los datos a Vercel y despliega el proyecto allí si el paso se ejecuta correctamente.

**`pushCanges.bat`**: Script para hacer commit + push con los cambios del readme en el repositorio remoto.

**`sendTelegramMessage.bat`**: Script para enviar los datos a telegram mediante un bot. El bot lo tenemos que crear nosotros hablando con `BotFather` y nos pasará el token del bot. A partir de eso necesitaremos conseguir la ID de nuestra conversiación, que es donde nos pasará los mensajes.

**`updateReadme.js`**: Script para actualizar el README.md del repositorio y marcar con una badge de Cypress que haya salido bien o mal los tests.

> En este caso los archivos son `.bat` y no `.sh` porque necesito que se puedan ejecutar en Windows.


### JenkinsFile (etapas)

>En algunos stages del archivo hay unas `credentialsId`, estos llaman al nombre que le hayamos puesto a las ID se los `Secret Text` y `SSH` que puse arriba.

- **Tools**: Llama a la tool de Node que configuramos antes. Debe llamarse igual que la tool.
- **parameters**: Creamos unas variables para usar a lo largo del archivo. (EXECUTOR, MOTIVO, CHAT_ID)
1. **Stage 1 `Dependencias`:** Instalamos dependencias.

2. **Stage 2 `Linter`:** Ejecuta Linter y busca errores. Envía los resultados a un `.txt`.
3. **Stage 3 `Jest`:** Ejecuta Jest y arranca los test del código. Envía los resultados a un `.txt`.
4. **Stage 4 `Update_Readme`:** Actualiza el readme con un script y asigna la badge pedida en el ejercicio. Envía los resultados a un `.txt`.
5. **Stage 5 `Push_Changes`:** Trae el SSH de las credentials de Jenkins y manda los datos a un `.bat` con el script que hace el commit + push al repositorio remoto. Envía los resultados a un `.txt`.
> La stage 5 no he conseguido que funcione, pero tengo en el código el `.bat` correspondiente y el stage comentado.
6. **Stage 6 `Build`:** Ejecutamos `npm run build` para construir el repositorio.

7. **Stage 7 `Vercel`:** Recogemos el token de las credentials y se lo enviamos al `.bat` para que haga el despliegue en Vercel. Envía los resultados a un `.txt`.
8. **Stage 8 `Notificaciones`:** Crea la notificación a telegram con los resultados en txt y los manda a un .bat para que haga el script de envío.
9. **Stage 9 `Petición_de_datos`:** Mostramos lo que hemos introducido en los parámetros.


### ¿Qué pasa si todo va bien?
En ese caso, recibiremos un mensaje de Telegram con el siguiente contenido:

> Se ha ejecutado la pipeline de Jenkins con los siguientes resultados: Linter_stage: Correcte, Test_stage: Correcte, Deploy_to_Vercel_stage: Correcto.