pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/jeeva"
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
        KUBERNETES_DEPLOYMENT = "my-nodejs-app-deployment"
        KUBERNETES_NAMESPACE = "default"
        KUBERNETES_CREDENTIALS_ID = 'minikube-service-account' // Jenkins credentials ID for Minikube service account token
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching code from GitHub...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/jeevan-sysadmin/CICD.git',
                        credentialsId: 'b38f3c3c-bbdf-4543-86f7-9197ac9117e1'
                    ]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Setting up Kubernetes authentication..."
                script {
                    withCredentials([string(credentialsId: "${KUBERNETES_CREDENTIALS_ID}", variable: 'KUBE_TOKEN')]) {
                        sh '''
                            kubectl config set-credentials jenkins-user --token=$KUBE_TOKEN
                            kubectl config set-context minikube --cluster=minikube --user=jenkins-user
                            kubectl config use-context minikube
                        '''
                    }
                }
                echo "Applying deployment..."
                sh 'kubectl apply -f deployment.yml'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
