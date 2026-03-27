pipeline {
agent any

```
tools {
    git 'Default'
}

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

    stage('Verify Tools') {
        steps {
            sh '''
            docker --version
            aws --version
            terraform version
            '''
        }
    }

    stage('Build Docker Image') {
        steps {
            sh '''
            echo "Building Docker Image..."
            docker build -t $ECR_REPO:$IMAGE_TAG .
            '''
        }
    }

    stage('Authenticate to AWS ECR') {
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
                '''
            }
        }
    }

    stage('Create ECR Repo (if not exists)') {
        steps {
            sh '''
            aws ecr describe-repositories --repository-names $ECR_REPO \
            || aws ecr create-repository --repository-name $ECR_REPO
            '''
        }
    }

    stage('Tag & Push Docker Image') {
        steps {
            sh '''
            docker tag $ECR_REPO:$IMAGE_TAG $IMAGE_URI
            docker push $IMAGE_URI
            '''
        }
    }

    stage('Terraform Init') {
        steps {
            dir("$TF_DIR") {
                sh 'terraform init'
            }
        }
    }

    stage('Terraform Validate') {
        steps {
            dir("$TF_DIR") {
                sh 'terraform validate'
            }
        }
    }

    stage('Terraform Plan') {
        steps {
            dir("$TF_DIR") {
                sh '''
                terraform plan \
                -var="image_uri=$IMAGE_URI" \
                -out=tfplan
                '''
            }
        }
    }

    stage('Terraform Apply') {
        steps {
            dir("$TF_DIR") {
                sh '''
                terraform apply -auto-approve tfplan
                '''
            }
        }
    }

    stage('Force ECS Deployment') {
        steps {
            sh '''
            echo "Triggering ECS rolling deployment..."
            aws ecs update-service \
            --cluster student-cluster \
            --service student-service \
            --force-new-deployment
            '''
        }
    }

    stage('Verify Deployment') {
        steps {
            sh '''
            echo "Waiting for service stabilization..."
            aws ecs wait services-stable \
            --cluster student-cluster \
            --services student-service

            echo "Fetching ALB URL..."
            aws elbv2 describe-load-balancers \
            --query "LoadBalancers[?contains(LoadBalancerName, 'student-alb')].DNSName" \
            --output text
            '''
        }
    }
}

post {
    success {
        echo '✅ Deployment Successful!'
    }
    failure {
        echo '❌ Deployment Failed!'
    }
    always {
        sh 'docker system prune -f'
    }
}
```

}
