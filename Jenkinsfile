pipeline {
     agent any

     tools {
          nodejs "Node" // Asegúrate de que "Node" coincida con el nombre configurado en Jenkins
     }

     parameters {
          string(name: 'EXECUTOR', defaultValue: '', description: 'Nombre de la persona que ejecuta la pipeline')
          string(name: 'MOTIVO', defaultValue: '', description: 'Motivo por el cual se ejecuta la pipeline')
          string(name: 'CHAT_ID', defaultValue: '', description: 'Chat ID de Telegram para las notificaciones')
     }

     stages {
          stage('Install Dependencies') {
               steps {
                    script {
                         echo "Instalando dependencias..."
                         sh 'npm install'
                         echo "Instalando CLI de Vercel..."
                         sh 'npm install -g vercel' // Instalación global de la CLI de Vercel
                         echo "Verificando la instalación de la CLI de Vercel..."
                         sh 'vercel --version' // Esto debe devolver la versión instalada de la CLI de Vercel
                    }
               }
          }

          stage('Linter') {
               steps {
                    script {
                         echo "Ejecutando ESLint para revisar el código..."
                         def lintResult = sh script: 'npx eslint .', returnStatus: true

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

          stage('Test') {
               steps {
                    script {
                         echo "Ejecutando tests con Jest..."
                         def testResult = sh(script: 'npm test', returnStatus: true)

                         if (testResult != 0) {
                              writeFile file: 'test_result.txt', text: 'Error'
                              error "Se encontraron errores en los tests. Por favor, corrígelos antes de continuar."
                         } else {
                              writeFile file: 'test_result.txt', text: 'Correcte'
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

                         sh """
                         echo "Ejecutando el script updateReadme.js con TEST_RESULT=${testResult}..."
                         node ./jenkinsScripts/updateReadme.js ${testResult}
                         """

                         writeFile file: 'update_readme_result.txt', text: 'Correcte'
                    }
               }
          }

          stage('Push_Changes') {
               steps {
                    script {
                         withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-stage-key', keyFileVariable: 'SSH_KEY')]) {
                              echo "Realizando el push al repositorio remoto..."

                              def pushResult = sh(
                                   script: """
                                   chmod 600 $SSH_KEY
                                   eval \$(ssh-agent -s)
                                   ssh-add $SSH_KEY
                                   sh ./jenkinsScripts/pushChanges.sh '${params.EXECUTOR}' '${params.MOTIVO}'
                                   """,
                                   returnStatus: true
                              )

                              if (pushResult != 0) {
                                   error "El push falló. Revisa el log para más detalles."
                              }
                         }
                    }
               }
          }

          stage('Build') {
               steps {
                    script {
                         echo "Realizando el build del proyecto..."
                         def buildResult = sh script: 'npm run build', returnStatus: true

                         if (buildResult != 0) {
                              error "El proceso de build falló. Por favor, revisa los errores antes de continuar."
                         }
                         echo "Build realizado correctamente. El proyecto está listo para desplegarse."
                    }
               }
          }

          stage('Deploy to Vercel') {
               when {
                    expression {
                         currentBuild.result == null || currentBuild.result == 'SUCCESS'
                    }
               }
               steps {
                    script {
                         withCredentials([string(credentialsId: 'vercel-deploy-token', variable: 'VERCEL_TOKEN')]) {
                              echo "Iniciando el despliegue en Vercel..."
                              def deployResult = sh(
                                   script: """
                                   chmod +x ./jenkinsScripts/deployToVercel.sh
                                   sh ./jenkinsScripts/deployToVercel.sh $VERCEL_TOKEN
                                   """,
                                   returnStatus: true
                              )
                              if (deployResult != 0) {
                                   writeFile file: 'deploy_to_vercel_result.txt', text: 'Error'
                                   error "El despliegue en Vercel falló. Revisa el log para más detalles."
                              } else {
                                   writeFile file: 'deploy_to_vercel_result.txt', text: 'Correcte'
                              }
                         }
                    }
               }
          }

          stage('Notificació') {
               steps {
                    script {
                         withCredentials([string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_TOKEN')]) {
                              def linterResult = readFile('linter_result.txt').trim()
                              def testResult = readFile('test_result.txt').trim()
                              def updateReadmeResult = readFile('update_readme_result.txt').trim()
                              def deployToVercelResult = readFile('deploy_to_vercel_result.txt').trim()

                              def message = """
                              S'ha executat la pipeline de Jenkins amb els següents resultats:
                              - Linter_stage: ${linterResult}
                              - Test_stage: ${testResult}
                              - Update_readme_stage: ${updateReadmeResult}
                              - Deploy_to_Vercel_stage: ${deployToVercelResult}
                              """.stripIndent()

                              sh """
                              chmod +x ./jenkinsScripts/sendTelegramMessage.sh
                              ./jenkinsScripts/sendTelegramMessage.sh "$TELEGRAM_TOKEN" "${params.CHAT_ID}" "${message}"
                              """
                         }
                    }
               }
          }

          stage('Petició de dades') {
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
