pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/html01" // Replace with your Docker Hub repository
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
        KUBERNETES_DEPLOYMENT = "html-my" // Replace with your Kubernetes deployment name
        KUBERNETES_NAMESPACE = "default"
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

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    // Ensure kubectl is installed and configured
                    withKubeConfig([credentialsId: 'mykube', serverUrl: 'http://127.0.0.1:62413']) { // Replace with your kubeconfig details
                        sh '''
                        echo "Applying deployment..."
                        if kubectl get deployment ${KUBERNETES_DEPLOYMENT} -n ${KUBERNETES_NAMESPACE} >/dev/null 2>&1; then
                            echo "Updating existing deployment..."
                            kubectl apply -f deployment.yaml -n ${KUBERNETES_NAMESPACE}
                        else
                            echo "Creating new deployment..."
                            kubectl apply -f deployment.yaml -n ${KUBERNETES_NAMESPACE}
                        fi
                        '''
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
