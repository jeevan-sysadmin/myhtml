pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/html01"
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
        KUBERNETES_DEPLOYMENT = "myhtml"
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
                        url: 'https://github.com/jeevan-sysadmin/myhtml.git',
                        credentialsId: 'b38f3c3c-bbdf-4543-86f7-9197ac9117e1'
                    ]])
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
                    // Use Jenkins credentials to authenticate with Minikube
                    withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBE_CONFIG')]) {
                        // Directly set the KUBECONFIG path for kubectl
                        echo "Using Minikube kubeconfig for kubectl authentication"
                        bat "set KUBECONFIG=${KUBE_CONFIG}"
                    }
                }

                echo "Applying Kubernetes deployment..."
                script {
                    // Apply the Kubernetes deployment
                    bat "kubectl apply -f deployment.yml --namespace=${KUBERNETES_NAMESPACE}"
                }
            }
        }

        stage('Port Forwarding') {
            steps {
                echo 'Setting up port forwarding for the application...'
                script {
                    // Get the name of the pod running the deployment
                    def podName = bat(script: "kubectl get pod -l app=${KUBERNETES_DEPLOYMENT} -n ${KUBERNETES_NAMESPACE} -o jsonpath='{.items[0].metadata.name}'", returnStdout: true).trim()
                    echo "Found pod: ${podName}"

                    // Set up port forwarding from the pod to the local machine (8082:80)
                    bat "start /B kubectl port-forward pod/${podName} 8082:80 -n ${KUBERNETES_NAMESPACE}"
                    echo 'Port forwarding is set up. Access the app at http://localhost:8082.'
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
