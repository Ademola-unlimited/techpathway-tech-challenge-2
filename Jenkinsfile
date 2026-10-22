
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '130299713508.dkr.ecr.us-east-1.amazonaws.com'
        BACKEND_REPO = 'techpathway-challenge-2-backend'
        FRONTEND_REPO = 'techpathway-challenge-2-frontend'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short=7 HEAD',
                        returnStdout: true
                    ).trim()
                }
                echo "Docker image tag: ${env.IMAGE_TAG}"
            }
        }

        stage('Verify Build Environment') {
            steps {
                sh '''
                    git --version
                    docker --version
                    aws --version
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t "$ECR_REGISTRY/$BACKEND_REPO:$IMAGE_TAG" \
                      ./backend
                '''
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t "$ECR_REGISTRY/$FRONTEND_REPO:$IMAGE_TAG" \
                      ./frontend
                '''
            }
        }

        stage('Push Docker Images to ECR') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail

                    export DOCKER_CONFIG="$(mktemp -d)"
                    trap 'docker logout "$ECR_REGISTRY" >/dev/null 2>&1 || true; rm -rf "$DOCKER_CONFIG"' EXIT

                    aws ecr get-login-password --region "$AWS_REGION" |
                      docker login --username AWS --password-stdin "$ECR_REGISTRY"

                    docker push "$ECR_REGISTRY/$BACKEND_REPO:$IMAGE_TAG"
                    docker push "$ECR_REGISTRY/$FRONTEND_REPO:$IMAGE_TAG"
                '''
            }
        }

        stage('Verify ECR Images') {
            steps {
                sh '''
                    aws ecr describe-images \
                      --repository-name "$BACKEND_REPO" \
                      --image-ids imageTag="$IMAGE_TAG" \
                      --region "$AWS_REGION"

                    aws ecr describe-images \
                      --repository-name "$FRONTEND_REPO" \
                      --image-ids imageTag="$IMAGE_TAG" \
                      --region "$AWS_REGION"

                    echo "Both Docker images uploaded successfully."
                '''
            }
        }
    }

    post {
        success {
            echo 'Jenkins ECR pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }
    }
}
