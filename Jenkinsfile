pipeline {
    agent any
    triggers {
        pollSCM('* * * * *') // or rely on webook (preferred)
    }

    environment {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
        AWS_REGION   = 'ap-south-1'
        ECR_REPO     = '463655182088.dkr.ecr.ap-south-1.amazonaws.com/capstone-web-app-ecr'
        CLUSTER_NAME = 'capstone-eks-cluster'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'test_deploy', url: 'https://github.com/abhiroopGL/chimsales/frontend'
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
                dir('frontend') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                    ]) {
                        sh """
                        aws ecr get-login-password --region $AWS_REGION \
                        | docker login --username AWS --password-stdin $ECR_REPO

                        docker buildx build --platform linux/amd64 -t frontend-app:latest .
                        docker tag frontend-app:latest $ECR_REPO:latest
                        docker push $ECR_REPO:latest
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
                    sh """
                    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
                    kubectl apply -f frontend/deployment.yaml --record
                    kubectl apply -f frontend/service.yaml --record
                    """
                }
            }
        }

        stage('SAST Scan (Optional)') {
            steps {
                sh 'echo "Run SAST tool here (SonarQube / Trivy fs)"'
            }
        }

        stage('DAST Scan (Optional)') {
            steps {
                sh 'echo "Run DAST tool here (OWASP ZAP)"'
            }
        }
    }
}
