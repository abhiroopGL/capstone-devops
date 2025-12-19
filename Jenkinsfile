pipeline {
    agent any
    triggers {
        pollSCM('* * * * *')
    }

    environment {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
        AWS_REGION   = 'ap-south-1'
        ECR_REPO     = '463655182088.dkr.ecr.ap-south-1.amazonaws.com/capstone-web-app-ecr'
        CLUSTER_NAME = 'capstone-eks-cluster'
        FRONTEND_DIR = 'frontend'
    }

    stages {

        stage('Checkout Main Repo') {
            steps {
                echo "Checking out main repo (capstone-devops)"
                git branch: 'main', url: 'https://github.com/abhiroopGL/capstone-devops'
            }
        }

        stage('Checkout Frontend Repo') {
            steps {
                echo "Checking out frontend repo (chimsales)"
                dir("${FRONTEND_DIR}") {
                    git branch: 'main', url: 'https://github.com/abhiroopGL/chimsales'
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('infra') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                    ]) {
                        sh 'aws sts get-caller-identity'
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                dir("${FRONTEND_DIR}/frontend") {
                    script {
                        COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        echo "Current commit SHA: ${COMMIT_SHA}"

                        sh """
                        echo 'Logging in to ECR...'
                        aws ecr get-login-password --region $AWS_REGION \
                        | docker login --username AWS --password-stdin $ECR_REPO

                        echo 'Listing files before Docker build:'
                        ls -la

                        echo 'Building Docker image from frontend repo...'
                        docker buildx build --platform linux/amd64 -t frontend-app:${COMMIT_SHA} -f Dockerfile .

                        echo 'Tagging and pushing Docker image...'
                        docker tag frontend-app:${COMMIT_SHA} $ECR_REPO:${COMMIT_SHA}
                        docker push $ECR_REPO:${COMMIT_SHA}
                        """
                    }
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                ]) {
                    dir("${FRONTEND_DIR}/frontend") {
                        sh """
                        echo 'Updating kubeconfig...'
                        aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                        echo 'Listing deployment files:'
                        ls -la

                        echo 'Deploying frontend to Kubernetes...'
                        # Update deployment image with commit SHA
                        kubectl set image deployment/capstone-web-app capstone-web-app=$ECR_REPO:${COMMIT_SHA} --record

                        # Apply service in case it has changes
                        kubectl apply -f service.yaml
                        """
                    }
                }
            }
        }

        stage('SAST Scan (Optional)') {
            steps {
                echo "Run SAST tool here (e.g., SonarQube / Trivy fs)"
            }
        }

        stage('DAST Scan (Optional)') {
            steps {
                echo "Run DAST tool here (e.g., OWASP ZAP)"
            }
        }

        stage('Vault Secrets Fetch (Optional)') {
            steps {
                echo "Fetch secrets from Vault if configured"
            }
        }
    }
}
