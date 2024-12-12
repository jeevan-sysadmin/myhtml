pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/html01"
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"  // Docker image tagged with build number
        DOCKER_REGISTRY = 'docker.io'  // Docker registry
        KUBERNETES_DEPLOYMENT = "myhtml"
        KUBERNETES_NAMESPACE = "default"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching code from GitHub...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/jeevan-sysadmin/myhtml.git',
                        credentialsId: 'b38f3c3c-bbdf-4543-86f7-9197ac9117e1'  // Ensure this credential ID exists in Jenkins
                    ]])
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    // Build the Docker image using the Dockerfile in the root of the repository
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    // Docker login and push the image
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    // Ensure kubectl is installed and configured with the right credentials
                    withKubeConfig([credentialsId: 'jenkinsminikube	']) {
                        // Apply Kubernetes deployment file
                        sh 'kubectl apply -f deployment.yml'
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
