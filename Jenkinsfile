pipeline {
     agent any

     tools {
          nodejs "Node"
     }

     parameters {
          string(name: 'EXECUTOR', defaultValue: '', description: 'Nombre de la persona que ejecuta la pipeline')
          string(name: 'MOTIVO', defaultValue: '', description: 'Motivo por el cual se ejecuta la pipeline')
          string(name: 'CHAT_ID', defaultValue: '', description: 'Chat ID de Telegram para las notificaciones')
     }

     stages {
          stage('Dependencias') {
               steps {
                    script {
                         echo "Instalando dependencias..."
                         bat 'npm install'
                         echo "Instalando CLI de Vercel..."
                         bat 'npm install -g vercel'
                         echo "Verificando la instalación de la CLI de Vercel..."
                         bat 'vercel --version'
                    }
               }
          }

          stage('Linter') {
               steps {
                    script {
                         echo "Ejecutando ESLint para revisar el código..."
                         def lintResult = bat script: 'npx eslint .', returnStatus: true

                         if (lintResult != 0) {
                              writeFile file: 'linter_result.txt', text: 'Error'
                              error "Se encontraron errores en el linter. Por favor, corrígelos antes de continuar."
                         } else {
                              writeFile file: 'linter_result.txt', text: 'Correcte'
                         }
                         echo "Linter ejecutado correctamente, no se encontraron errores."
                    }
               }
          }

          stage('Jest') {
               steps {
                    script {
                         echo "Ejecutando tests con Jest..."
                         def testResult = bat(script: 'npm test', returnStatus: true)

                         if (testResult != 0) {
                              writeFile file: 'test_result.txt', text: 'Error'
                              error "Se encontraron errores en los tests. Por favor, corrígelos antes de continuar."
                         } else {
                              writeFile file: 'test_result.txt', text: 'Correcto'
                         }
                         echo "Todos los tests pasaron correctamente."
                    }
               }
          }

          stage('Update_Readme') {
               steps {
                    script {
                         def testResult = readFile('test_result.txt').trim()

                         echo "Actualizando el README.md con el resultado de los tests (${testResult})..."

                         bat """
                         echo "Ejecutando el script updateReadme.js con TEST_RESULT=${testResult}..."
                         node ./jenkinsScripts/updateReadme.js ${testResult}
                         """

                         writeFile file: 'update_readme_result.txt', text: 'Correcto'
                    }
               }
          }

          // stage('Push_Changes') {
          //      steps {
          //           script {
          //                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-stage-key', keyFileVariable: 'SSH_KEY')]) {
          //                     echo "Realizando el push al repositorio remoto..."

          //                     def pushResult = bat(
          //                          script: """
          //                          ssh-add %SSH_KEY%
          //                          call jenkinsScripts\\pushChanges.bat "${params.EXECUTOR}" "${params.MOTIVO}"
          //                          """,
          //                          returnStatus: true
          //                     )

          //                     if (pushResult != 0) {
          //                          error "El push falló. Revisa el log para más detalles."
          //                     }
          //                }
          //           }
          //      }
          // }

          stage('Build') {
               steps {
                    script {
                         echo "Realizando el build del proyecto..."
                         def buildResult = bat script: 'npm run build', returnStatus: true

                         if (buildResult != 0) {
                              error "El proceso de build falló."
                         }
                         echo "Build realizada correctamente."
                    }
               }
          }

          stage('Vercel') {
               when {
                    expression {
                         currentBuild.result == null || currentBuild.result == 'SUCCESS'
                    }
               }
               steps {
                    script {
                         withCredentials([string(credentialsId: 'vercel-deploy-token', variable: 'VERCEL_TOKEN')]) {
                              echo "Iniciando el despliegue en Vercel..."
                              def deployResult = bat(
                                   script: """
                                   call jenkinsScripts\\deployToVercel.bat %VERCEL_TOKEN%
                                   """,
                                   returnStatus: true
                              )
                              if (deployResult != 0) {
                                   writeFile file: 'deploy_to_vercel_result.txt', text: 'Error'
                                   error "El despliegue en Vercel falló. Revisa el log para más detalles."
                              } else {
                                   writeFile file: 'deploy_to_vercel_result.txt', text: 'Correcto'
                              }
                         }
                    }
               }
          }

          stage('Notificaciones') {
               steps {
                    script {
                         withCredentials([string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_TOKEN')]) {
                              def linterResult = readFile('linter_result.txt').trim()
                              def testResult = readFile('test_result.txt').trim()
                              def deployToVercelResult = readFile('deploy_to_vercel_result.txt').trim()

                              def message = "Se ha ejecutado la pipeline de Jenkins con los siguientes resultados: " +
                                   "Linter_stage: ${linterResult}, " +
                                   "Test_stage: ${testResult}, " +
                                   "Deploy_to_Vercel_stage: ${deployToVercelResult}"

                              def envioTelegram = bat (
                                   script: """
                                   call jenkinsScripts\\sendTelegramMessage.bat %TELEGRAM_TOKEN% ${params.CHAT_ID} "${message}"
                                   """,
                                   returnStatus: true
                              )
                              if (envioTelegram != 0) {
                                   error "El envío de la notificación a Telegram falló. Revisa el log para más detalles."
                              } else {
                                   echo "Notificación enviada correctamente."
                              }
                         }
                    }
               }
          }

          stage('Petición_de_datos') {
               steps {
                    script {
                         echo "Executor: ${params.EXECUTOR}"
                         echo "Motivo: ${params.MOTIVO}"
                         echo "Chat ID: ${params.CHAT_ID}"
                    }
               }
          }
     }
}
