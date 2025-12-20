pipeline {
    agent any

    triggers {
        pollSCM('* * * * *')
    }

    environment {
        PATH         = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
        AWS_REGION   = "ap-south-1"
        CLUSTER_NAME = "capstone-eks-cluster"
    }

    stages {

        stage('Checkout DevOps Repository') {
            steps {
                echo "Checking out capstone-devops repository"
                git branch: 'main',
                    url: 'https://github.com/abhiroopGL/capstone-devops'
            }
        }

        stage('Checkout Frontend Repository') {
            steps {
                echo "Checking out frontend (UI) repository"
                dir('frontend') {
                    git branch: 'test_deploy',
                        url: 'https://github.com/abhiroopGL/chimsales'
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('infra') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'aws-creds']
                    ]) {
                        sh '''
                        echo "Initializing Terraform..."
                        terraform init

                        echo "Applying Terraform configuration..."
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Read Terraform Outputs') {
            steps {
                dir('infra') {
                    script {
                        env.ECR_REPO = sh(
                            script: "terraform output -raw ecr_repository_url",
                            returnStdout: true
                        ).trim()
                    }
                    echo "Using ECR Repository: ${env.ECR_REPO}"
                }
            }
        }


        stage('Docker Build & Push') {
            steps {
                dir('frontend/frontend') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'aws-creds']
                    ]) {
                        sh '''
                        echo "Current directory:"
                        pwd
                        echo "Listing files:"
                        ls -la

                        echo "Logging into Amazon ECR..."
                        aws ecr get-login-password --region $AWS_REGION \
                          | docker login --username AWS --password-stdin $ECR_REPO

                        echo "Building Docker image..."
                        docker buildx build --platform linux/amd64 \
                          -t frontend-app:latest .

                        echo "Tagging and pushing image to ECR..."
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
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-creds']
                ]) {
                    sh '''
                    echo "Updating kubeconfig..."
                    aws eks update-kubeconfig \
                      --region $AWS_REGION \
                      --name $CLUSTER_NAME

                    echo "Deploying application to Kubernetes..."
                    kubectl apply -f app/deployment.yaml
                    kubectl apply -f app/service.yaml
                    '''
                }
            }
        }

        stage('SAST Scan (Optional)') {
            steps {
                echo "SAST stage placeholder (e.g., Trivy / SonarQube)"
            }
        }

        stage('DAST Scan (Optional)') {
            steps {
                echo "DAST stage placeholder (e.g., OWASP ZAP)"
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully 🚀"
        }
        failure {
            echo "Pipeline failed ❌ - Check logs for details"
        }
    }
}
