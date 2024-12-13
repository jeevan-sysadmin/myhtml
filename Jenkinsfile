pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/html01"
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
        KUBERNETES_DEPLOYMENT = "html-my"
        KUBERNETES_NAMESPACE = "default"
        SERVICE_NAME = "html-service"
        PORT = "80"  // Adjust based on your app's port
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

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    // Create Kubernetes deployment using kubectl
                    sh """
                    kubectl apply -f - <<EOF
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: ${KUBERNETES_DEPLOYMENT}
                      namespace: ${KUBERNETES_NAMESPACE}
                    spec:
                      replicas: 1
                      selector:
                        matchLabels:
                          app: ${KUBERNETES_DEPLOYMENT}
                      template:
                        metadata:
                          labels:
                            app: ${KUBERNETES_DEPLOYMENT}
                        spec:
                          containers:
                          - name: html-container
                            image: ${DOCKER_IMAGE}
                            ports:
                            - containerPort: 80
                    EOF
                    """
                    
                    // Expose the deployment using a Kubernetes service
                    sh """
                    kubectl expose deployment ${KUBERNETES_DEPLOYMENT} --name=${SERVICE_NAME} --port=80 --target-port=80 --type=LoadBalancer --namespace=${KUBERNETES_NAMESPACE}
                    """
                    
                    // Wait for the external IP of the service
                    echo 'Waiting for the external IP of the service...'
                    def serviceIP = sh(script: """
                    kubectl get svc ${SERVICE_NAME} -n ${KUBERNETES_NAMESPACE} -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
                    """, returnStdout: true).trim()

                    // Print the website URL
                    echo "The website is available at: http://${serviceIP}:${PORT}"
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
