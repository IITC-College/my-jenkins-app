pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'be1133e0-d5ac-4f24-bab1-9a5e0c7e43bf'
    }

    stages {
        // This is a comment
        /*
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
                    echo $RENDER_API_KEY_CRED
                    ls -la
                    node -v
                    npm -v
                    npm ci
                    npm run build
                    ls -la build/
                '''
            }
        }
        stage('Run Test') {
            parallel {
                stage('Unit Tests') {
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
                    
                    post {
                        always {
                            junit '**/junit.xml'
                        }
                    }
                }
                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.57.0-noble'
                            reuseNode true
                        }
                    }
                    
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
        stage('Deploy to Netlify') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Installing Netlify CLI..."
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Triggering Netlify Deploy... site id: $NETLIFY_SITE_ID"
                '''
            }
        }

    }
}