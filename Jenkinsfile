pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/html01" // Replace with your Docker Hub repository
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching code from GitHub...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/jeevan-sysadmin/myhtml.git', // Replace with your repository URL
                        credentialsId: 'b38f3c3c-bbdf-4543-86f7-9197ac9117e1' // Replace with your GitHub credentials ID
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

        stage('Apply Deployment') {
            steps {
                echo 'Applying Kubernetes deployment...'
                script {
                    def result = sh(script: 'kubectl apply -f deployment.yaml -n jenkins', returnStatus: true)
                    if (result != 0) {
                        error("Failed to apply deployment.yaml")
                    } else {
                        echo 'Deployment applied successfully.'
                    }
                }
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
