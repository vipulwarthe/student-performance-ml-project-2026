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

        // 🔐 TRIVY FS SCAN (HTML)
        stage('Trivy FS Scan') {
            steps {
                sh '''
                trivy fs \
                --format template \
                --template "@/usr/local/share/trivy/templates/html.tpl" \
                --output trivy-fs-report.html \
                .
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
            }
        }

        // 🔐 TRIVY IMAGE SCAN (HTML)
        stage('Trivy Image Scan') {
            steps {
                sh '''
                trivy image \
                --format template \
                --template "@/usr/local/share/trivy/templates/html.tpl" \
                --output trivy-image-report.html \
                $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        // 📦 Archive Reports
        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: '*.html', fingerprint: true
            }
        }

        // 🚨 Security Gate (fail only on CRITICAL)
        stage('Security Gate') {
            steps {
                sh '''
                trivy image \
                --severity CRITICAL \
                --exit-code 1 \
                $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        // 🚀 ECR LOGIN + CREATE REPO + PUSH IMAGE
        stage('Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    sh '''
                    echo "🔐 Logging into ECR..."
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS \
                    --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                    echo "📦 Creating ECR repo if not exists..."
                    aws ecr describe-repositories --repository-names $ECR_REPO \
                    || aws ecr create-repository --repository-name $ECR_REPO

                    echo "🏷 Tagging Docker Image..."
                    docker tag $ECR_REPO:$IMAGE_TAG $IMAGE_URI

                    echo "🚀 Pushing Docker Image to ECR..."
                    docker push $IMAGE_URI
                    '''
                }
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

