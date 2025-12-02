pipeline {
    agent any

    stages {
        // This is a comment
        /*
            This is a multi-line comment
            This is a multi-line comment
            stage('Commented stage') {
                steps {
                    echo 'This is a commented stage'
                }
            }
        */
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node -v
                    npm -v
                    npm ci
                    npm run build
                    ls -la build/
                '''
            }
        }
        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            steps {
                sh '''
                    # This is a single line comment
                    test -f build/index.html
                    npm run test
                '''
            }
        }
        stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright/test:v1.39.0-jammy'
                    reuseNode true
                }
            }
            
            steps {
                sh '''
                    npm install -g serve
                    serve -s build
                    npx playwright test
                '''
            }
        }
    }

    post {
        always {
            junit 'test-results/junit.xml'
        }
    }
}