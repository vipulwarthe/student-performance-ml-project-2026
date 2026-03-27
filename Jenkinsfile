pipeline {
    agent any

    environment {
        AWS_REGION   = 'us-east-1'
        ACCOUNT_ID   = '459499397844'
        ECR_REPO     = 'student-app'
        IMAGE_TAG    = "${BUILD_NUMBER}"
        IMAGE_URI    = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
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

        // 🔐 TRIVY FS SCAN
        stage('Trivy FS Scan') {
            steps {
                sh '''
                echo "Running Trivy FS Scan..."
                trivy fs \
                --format template \
                --template "@/usr/local/share/trivy/templates/html.tpl" \
                --output trivy-fs-report.html \
                . || true
                '''
            }
        }

        // 🐳 BUILD IMAGE
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
            }
        }

        // 🔐 TRIVY IMAGE SCAN
        stage('Trivy Image Scan') {
            steps {
                sh '''
                echo "Running Trivy Image Scan..."
                trivy image \
                --format template \
                --template "@/usr/local/share/trivy/templates/html.tpl" \
                --output trivy-image-report.html \
                $ECR_REPO:$IMAGE_TAG || true
                '''
            }
        }

        // 📦 ARCHIVE REPORTS
        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: '*.html', fingerprint: true
            }
        }

        // 🚨 SECURITY GATE
        stage('Security Gate') {
            steps {
                sh '''
                echo "Checking CRITICAL vulnerabilities..."
                trivy image \
                --severity CRITICAL \
                --exit-code 1 \
                $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        // 🔐 ECR LOGIN + CREATE REPO
        stage('ECR Login & Setup') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    echo "Logging into ECR..."
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS \
                    --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                    echo "Checking/Creating ECR repo..."
                    aws ecr describe-repositories --repository-names $ECR_REPO \
                    || aws ecr create-repository --repository-name $ECR_REPO
                    '''
                }
            }
        }

        // 📤 PUSH IMAGE
        stage('Push Image') {
            steps {
                sh '''
                echo "Tagging image..."
                docker tag $ECR_REPO:$IMAGE_TAG $IMAGE_URI

                echo "Pushing image to ECR..."
                docker push $IMAGE_URI
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Image successfully pushed to ECR'
        }
        failure {
            echo '❌ Pipeline failed'
        }
        always {
            script {
                echo '🧹 Cleaning Docker...'
                sh 'docker system prune -f || true'
            }
        }
    }
}
