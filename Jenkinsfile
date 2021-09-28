pipeline{
    agent any
    stages{
        stage('Clone git repo'){
            steps{
                sh 'echo "###################### Clone Git Repo ######################"'
                cleanWs()
                git branch: 'main', credentialsId: '100', url: 'https://github.com/makschihin/SS_task_3.git'
                sh 'echo "###################### DONE ######################"'
            }
        }
        stage('Build app'){
            steps{
            sh 'echo "###################### BUILD APP ######################"'
            sh './mvnw package'
            sh 'echo "###################### DONE ######################"'
            }
        }
        stage('Building our image and Push to the Registry') { 
            steps { 
                script {
                    sh 'echo "###################### BUILD & PUSH IMAGE ######################"'
                    docker.withRegistry(
                        'https://324933475859.dkr.ecr.us-east-2.amazonaws.com', 'ecr:us-east-2:my.aws.credentials'){
                        def myImage=docker.build('test-petclinic-image')
                        myImage.push('latest')
                    sh 'echo "###################### DONE ######################"'
                    }
                }
            }
        } 
        
    }
    post {
        // Clean after build
        always {
            cleanWs()
            }
    }
}