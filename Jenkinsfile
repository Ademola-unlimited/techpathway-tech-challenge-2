
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Build Environment') {
            steps {
                sh '''
                    echo "Checking Jenkins build environment..."

                    git --version
                    docker --version
                    aws --version

                    echo "Build environment verified."
                '''
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t techpathway-backend:jenkins-test \
                      ./backend
                '''
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t techpathway-frontend:jenkins-test \
                      ./frontend
                '''
            }
        }

        stage('Verify Docker Images') {
            steps {
                sh '''
                    docker image inspect techpathway-backend:jenkins-test
                    docker image inspect techpathway-frontend:jenkins-test

                    echo "Both Docker images built successfully."
                '''
            }
        }
    }

    post {
        success {
            echo 'Jenkins Docker build pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }
    }
}
