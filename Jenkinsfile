pipeline {
    agent any

    environment {
        IMAGE_NAME = "banking-app"
        REGISTRY   = "saisreeyadav1703-lgt"
        IMAGE_TAG  = "${env.GIT_COMMIT[0..6]}"
        FULL_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.BRANCH_NAME} | Commit: ${IMAGE_TAG}"
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${FULL_IMAGE} ."
            }
        }

        stage('Test') {
            steps {
                sh "docker run --rm -e APP_ENV=test ${FULL_IMAGE} python -m pytest -v"
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${FULL_IMAGE}"
                }
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh "APP_ENV=staging APP_VERSION=${IMAGE_TAG} docker compose up -d"
                sh "sleep 10"
                sh "curl -f http://localhost:8080/health || exit 1"
            }
        }

        stage('Deploy to Production') {
            when { branch 'main' }
            input { message "Deploy to production?" }
            steps {
                sh "./scripts/deploy.sh ${IMAGE_TAG} prod"
            }
        }

        stage('Verify') {
            steps {
                sh "curl -f http://localhost:8080/health || exit 1"
                echo "Deployment verified successfully"
            }
        }
    }

    post {
        failure { echo "Pipeline failed — check logs and consider rollback" }
        success { echo "Pipeline succeeded — ${FULL_IMAGE} is live" }
    }
}
