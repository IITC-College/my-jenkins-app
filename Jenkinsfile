pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID    = 'be1133e0-d5ac-4f24-bab1-9a5e0c7e43bf'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {

        /* =======================
           BUILD
        ======================= */
        stage('Build') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root:root'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    export NPM_CONFIG_CACHE=/tmp/.npm
                    npm ci --omit=optional
                    npm run build
                '''
            }
        }

        /* =======================
           TESTS
        ======================= */
        stage('Tests') {
            parallel {

                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:20-alpine'
                            args '-u root:root'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            export NPM_CONFIG_CACHE=/tmp/.npm
                            npm test --if-present
                        '''
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'test-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.57.0-jammy'
                            args '-u root:root'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            export NPM_CONFIG_CACHE=/tmp/.npm
                            
                            npm install serve
                            npx serve -s build & 
                            sleep 10
                            
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Playwright Local',
                                keepAll: true,
                                alwaysLinkToLastBuild: true
                            ])
                        }
                    }
                }
            }
        }

        /* =======================
           DEPLOY TO STAGING
        ======================= */
        stage('Deploy staging') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root:root'
                    reuseNode true
                }
            }
            steps {
                script {
                    sh '''
                        export NPM_CONFIG_CACHE=/tmp/.npm
                        npm install -g netlify-cli

                        netlify deploy --dir=build --json > deploy.json
                    '''

                    // Parse simple JSON inside Jenkins without jq
                    def json = readJSON file: 'deploy.json'
                    env.STAGING_URL = json.deploy_url

                    echo "🚀 Staging deployed: ${env.STAGING_URL}"
                }
            }
        }

        /* =======================
           APPROVAL
        ======================= */
        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: "🔍 Review staging:\n${env.STAGING_URL}\n\nDeploy to production?"
                }
            }
        }

        /* =======================
           DEPLOY TO PRODUCTION
        ======================= */
        stage('Deploy prod') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root:root'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    export NPM_CONFIG_CACHE=/tmp/.npm
                    npm install -g netlify-cli

                    netlify deploy --dir=build --prod
                '''
            }
        }

        /* =======================
           PROD E2E TESTS
        ======================= */
        stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.57.0-jammy'
                    args '-u root:root'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    export NPM_CONFIG_CACHE=/tmp/.npm

                    echo "Testing production site..."
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Playwright E2E (Production)',
                        keepAll: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }
    }
}
