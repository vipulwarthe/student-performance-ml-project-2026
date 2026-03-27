pipeline {
    agent any

    environment {
        AWS_REGION   = 'us-east-1'
        ACCOUNT_ID   = '459499397844'
        ECR_REPO     = 'student-app'
        IMAGE_TAG    = "${BUILD_NUMBER}"
        IMAGE_URI    = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
        TF_DIR       = 'terraform'
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/vipulwarthe/student-performance-ml-project-2026.git'
            }
        }

        // 🔐 TRIVY FILE SYSTEM SCAN
        stage('Trivy FS Scan') {
            steps {
                sh '''
                echo "Running Trivy FS Scan..."
                trivy fs --severity HIGH,CRITICAL --exit-code 1 .
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
            }
        }

        // 🔐 TRIVY IMAGE SCAN (IMPORTANT)
        stage('Trivy Image Scan') {
            steps {
                sh '''
                echo "Running Trivy Image Scan..."
                trivy image --severity HIGH,CRITICAL --exit-code 1 $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('ECR Login') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS \
                    --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker tag $ECR_REPO:$IMAGE_TAG $IMAGE_URI
                docker push $IMAGE_URI
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("$TF_DIR") {
                    sh '''
                    terraform init
                    terraform apply -auto-approve -var="image_uri=$IMAGE_URI"
                    '''
                }
            }
        }

        stage('Deploy ECS') {
            steps {
                sh '''
                aws ecs update-service \
                --cluster student-cluster \
                --service student-service \
                --force-new-deployment
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful'
        }
        failure {
            echo 'Deployment Failed'
        }
    }
}
