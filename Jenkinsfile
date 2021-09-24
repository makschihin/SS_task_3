pipeline{
    agent any
    stages{
        stage('Clone git repo'){
            steps{
                cleanWs()
                git branch: 'main', credentialsId: '100', url: 'https://github.com/makschihin/SS_task_3.git'
            }
        }
        stage('Build app'){
            steps{
            sh './mvnw package'
            }
        }
        stage('Building our image') { 
            steps { 
                script {
                    sh 'ls' 
                    docker.withRegistry(
                        'https://324933475859.dkr.ecr.us-east-2.amazonaws.com', 'ecr:us-east-2:my.aws.credentials'){
                        def myImage=docker.build('test-petclinic-image')
                        myImage.push('latest')
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