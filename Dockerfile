pipeline {
    agent any // 아무 에이전트에서 해당 파이프라인 또는 stage를 실행함.

    triggers {
        pollSCM('*/3 * * * *')
    }

    environment { // pipeline 블록의 환경 변수 지정, 모든 단계에 적용됨
        imagename = "test"
        registryCredential = '5f173fdd-057b-4b63-91ac-69cb5a12447f'
        dockerImage = ''
    }

    stages {
        // git에서 repository clone
        stage('Prepare') {
          steps {
            echo 'Clonning Repository'
            git url: 'https://github.com/sesac-final/jenkins',
              branch: 'main',
              credentialsId: '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'
            }
            post {
             success { 
               echo 'Successfully Cloned Repository'
             }
           	 failure {
               error 'This pipeline stops here...'
             }
          }
        }

        // gradle build
        stage('Bulid Gradle') {
          agent any
          steps {
            echo 'Bulid Gradle'
            dir ('.'){
                sh """
                ./gradlew clean build --exclude-task test
                """
            }
          }
          post {
            failure {
              error 'This pipeline stops here...'
            }
          }
        }
        
        // docker build
        stage('Bulid Docker') {
          agent any
          steps {
            echo 'Bulid Docker'
            script {
                dockerImage = docker.build imagename
            }
          }
          post {
            failure {
              error 'This pipeline stops here...'
            }
          }
        }

        // docker push
        stage('Push Docker') {
          agent any
          steps {
            echo 'Push Docker'
            script {
                docker.withRegistry( '', registryCredential) {
                    dockerImage.push("docker tag name")  // ex) "1.0"
                }
            }
          }
          post {
            failure {
              error 'This pipeline stops here...'
            }
          }
        }
    }
}
