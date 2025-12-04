pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'be1133e0-d5ac-4f24-bab1-9a5e0c7e43bf'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
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
            post {
                always {
                    stash includes: 'build/**,netlify.toml', name: 'build-artifacts'
                }
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
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright QA Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
        stage('Deploy STAGING') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                unstash 'build-artifacts'
                sh '''
                    npm install netlify-cli jq
                    node_modules/.bin/netlify deploy \
                        --dir=build \
                        --site=$NETLIFY_SITE_ID \
                        --json > deploy-output.json
                    node_modules/.bin/jq -r '.deploy_url' deploy-output.json
                '''
            }
        }
                
        stage('Approval STAGING') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Do you wish to deploy to production?', ok: 'Yes, I am sure!'
                }
            }
        }
        stage('Deploy PROD') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                unstash 'build-artifacts'
                sh '''
                    npm install netlify-cli

                    # netlify.toml inside workspace controls build command = ""
                    node_modules/.bin/netlify deploy \
                        --dir=build \
                        --prod \
                        --site=$NETLIFY_SITE_ID
                '''
            }
        }
        stage('Prod E2E') {
            
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.57.0-noble'
                    reuseNode true
                }
            }
            
            environment {
                CI_ENVIRONMENT_URL = 'https://tangerine-lollipop-cafc67.netlify.app'
            }

            steps {
                sh '''
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright PROD Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }


    }
}