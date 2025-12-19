pipeline {
    agent any
    triggers {
        // Polling SCM every minute (optional, can remove if using webhooks)
        pollSCM('* * * * *')
    }

    environment {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
        AWS_REGION   = 'ap-south-1'
        ECR_REPO     = '463655182088.dkr.ecr.ap-south-1.amazonaws.com/capstone-web-app-ecr'
        CLUSTER_NAME = 'capstone-eks-cluster'
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
                dir('frontend') {
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
                dir('frontend/frontend') {  // <-- points to folder containing Dockerfile
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                    ]) {
                        sh '''
                        aws ecr get-login-password --region $AWS_REGION \
                        | docker login --username AWS --password-stdin $ECR_REPO

                        docker buildx build --platform linux/amd64 -t frontend-app:latest -f frontend/frontend/Dockerfile frontend/frontend
                        docker tag frontend-app:latest $ECR_REPO:latest
                        docker push $ECR_REPO:latest
                        '''
                    }
                }
            }
        }


        stage('Kubernetes Deploy') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']
                ]) {
                    dir('frontend') {
                        sh '''
                        echo "Updating kubeconfig..."
                        aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                        echo "Deploying frontend to Kubernetes..."
                        kubectl apply -f deployment.yaml --record
                        kubectl apply -f service.yaml --record
                        '''
                    }
                }
            }
        }

        stage('SAST Scan (Optional)') {
            steps {
                echo "Run SAST tool here (SonarQube / Trivy fs)"
            }
        }

        stage('DAST Scan (Optional)') {
            steps {
                echo "Run DAST tool here (OWASP ZAP)"
            }
        }
    }
}
