pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/html01"
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${BUILD_NUMBER}"
        KUBERNETES_DEPLOYMENT = "html-my"
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

        stage('Deploy to Kubernetes') {
            agent {
                kubernetes {
                    label 'k8s-agent'
                    defaultContainer 'jnlp'
                    yaml """
apiVersion: v1
kind: Pod
metadata:
  name: jenkins-agent
spec:
  containers:
  - name: jnlp
    image: 'jenkins/inbound-agent:latest'
  - name: kubectl
    image: 'bitnami/kubectl:latest'
    command:
    - cat
    tty: true
    """
                }
            }

            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    withKubeConfig([credentialsId: 'sa-k8s-tocken', serverUrl: 'https://127.0.0.1:49780']) {
                        sh """
                        kubectl set image deployment/${KUBERNETES_DEPLOYMENT} \
                        html-container=${DOCKER_IMAGE} \
                        -n ${KUBERNETES_NAMESPACE} --record
                        kubectl rollout status deployment/${KUBERNETES_DEPLOYMENT} -n ${KUBERNETES_NAMESPACE}
                        """
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
