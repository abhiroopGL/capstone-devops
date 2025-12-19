pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
        AWS_REGION   = 'ap-south-1'
        ECR_REPO     = '463655182088.dkr.ecr.ap-south-1.amazonaws.com/capstone-web-app-ecr'
        CLUSTER_NAME = 'capstone-eks-cluster'
    }

    stages {

        stage('Terraform Init & Apply') {
            steps {
                dir('infra') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                dir('app') {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                      | docker login --username AWS --password-stdin 463655182088.dkr.ecr.ap-south-1.amazonaws.com

                    docker buildx build --platform linux/amd64 -t capstone-web-app:latest .
                    docker tag capstone-web-app:latest $ECR_REPO:latest
                    docker push $ECR_REPO:latest
                    '''
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                sh '''
                aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
                kubectl apply -f app/deployment.yaml
                kubectl apply -f app/service.yaml
                '''
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
