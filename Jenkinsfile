pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "appi12/html01"
        DOCKER_IMAGE = "${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
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
    image: jenkins/inbound-agent:latest
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_AGENT_NAME)']
    env:
    - name: DOCKER_HOST
      value: "tcp://docker:2375"
    tty: true
"""
                }
            }

            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    withKubeConfig([credentialsId: 'kube']) {
                        sh '''
                        echo "Applying deployment..."
                        if kubectl apply -f deployment.yml; then
                            echo "Deployment applied successfully."
                        else
                            echo "Failed to apply deployment. Please check the logs."
                            exit 1
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
