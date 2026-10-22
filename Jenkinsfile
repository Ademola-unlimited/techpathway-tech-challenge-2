
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
    }

    post {
        success {
            echo 'Initial Jenkins pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }
    }
}
