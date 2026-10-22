
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

                                    '''
            }
        }

    }

        stage('Register ECS Task Definitions') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail

                    f
for APP in frontend backend; do
    FAMILY="techpathway-challenge-2-$APP"

    if [ "$APP" = "frontend" ]; then
        REPO="$FRONTEND_REPO"
    else
        REPO="$BACKEND_REPO"
    fi

    IMAGE="${ECR_REGISTRY}/${REPO}:${IMAGE_TAG}"


                        echo "Preparing new task definition for $APP"

                        aws ecs describe-task-definition \
                          --task-definition "$FAMILY" \
                          --region "$AWS_REGION" \
                          --query taskDefinition \
                          --output json > "$APP-current.json"

                        jq --arg NAME "$APP" --arg IMAGE "$IMAGE" '
                          .containerDefinitions |= map(
                            if .name == $NAME
                            then .image = $IMAGE
                            else .
                            end
                          )
                          | del(
                              .taskDefinitionArn,
                              .revision,
                              .status,
                              .requiresAttributes,
                              .compatibilities,
                              .registeredAt,
                              .registeredBy,
                              .deregisteredAt
                            )
                        ' "$APP-current.json" > "$APP-new.json"

                        aws ecs register-task-definition \
                          --cli-input-json "file://$APP-new.json" \
                          --region "$AWS_REGION" \
                          --query 'taskDefinition.taskDefinitionArn' \
                          --output text > "$APP-task-arn.txt"

                        echo "Registered new $APP task definition:"
                        cat "$APP-task-arn.txt"
                    done
                '''
            }
        }

        stage('Deploy Applications to ECS') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail

                    CLUSTER="techpathway-challenge-2-cluster"

                    for APP in backend frontend; do
                        SERVICE="techpathway-challenge-2-$APP-service"
                        TASK_ARN="$(cat "$APP-task-arn.txt")"

                        echo "Deploying $APP to ECS"

                        aws ecs update-service \
                          --cluster "$CLUSTER" \
                          --service "$SERVICE" \
                          --task-definition "$TASK_ARN" \
                          --region "$AWS_REGION" \
                          --query 'service.[serviceName,taskDefinition]' \
                          --output table
                    done

                    for APP in backend frontend; do
                        SERVICE="techpathway-challenge-2-$APP-service"

                        echo "Waiting for $SERVICE to stabilize..."

                        aws ecs wait services-stable \
                          --cluster "$CLUSTER" \
                          --services "$SERVICE" \
                          --region "$AWS_REGION"

                        echo "$SERVICE is stable."
                    done

                    echo "Both ECS deployments completed successfully."
                '''
            }
        }


    } // End of stages

    post {
        success {
            echo 'Full Jenkins CI/CD pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }
    }
}

