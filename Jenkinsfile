pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID     = 'be1133e0-d5ac-4f24-bab1-9a5e0c7e43bf'
        NETLIFY_AUTH_TOKEN  = credentials('netlify-token')
        NPM_CONFIG_CACHE    = '/tmp/.npm'
    }

    stages {

        /* =======================
           1) BUILD
        ======================= */
        stage('Build') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root:root'
                }
            }
            steps {
                sh '''
                    mkdir -p $NPM_CONFIG_CACHE
                    npm ci --omit=optional
                    npm run build
                '''
            }
        }

        /* =======================
           2) TESTS (Parallel)
        ======================= */
        stage('Tests') {
            parallel {

                /* ---- Unit Tests ---- */
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:20-alpine'
                            args '-u root:root'
                        }
                    }
                    steps {
                        sh 'npm test --if-present'
                    }
                    post {
                        always {
                            junit allowEmptyResults: true,
                                  testResults: 'test-results/junit.xml'
                        }
                    }
                }

                /* ---- Playwright E2E LOCAL ---- */
                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.57.0-jammy'
                            args '-u root:root'
                        }
                    }
                    steps {
                        sh '''
                            mkdir -p $NPM_CONFIG_CACHE

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
                                reportName: 'Playwright Local Tests',
                                allowMissing: true,
                                keepAll: true,
                                alwaysLinkToLastBuild: true
                            ])
                        }
                    }
                }
            }
        }

        /* =======================
           3) DEPLOY STAGING
        ======================= */
        stage('Deploy staging') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root:root'
                }
            }
            steps {
                script {
                    sh '''
                        npm install -g netlify-cli
                        netlify deploy --dir=build --json > deploy.json
                    '''

                    // parse deploy result with Jenkins native utility
                    def data = readJSON file: 'deploy.json'
                    env.STAGING_URL = data.deploy_url

                    echo "🚀 Staging deployed successfully: ${env.STAGING_URL}"
                }
            }
        }

        /* =======================
           4) APPROVAL
        ======================= */
        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: "Review staging site:\n${env.STAGING_URL}\n\nDeploy to production?"
                }
            }
        }

        /* =======================
           5) DEPLOY PRODUCTION
        ======================= */
        stage('Deploy prod') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root:root'
                }
            }
            steps {
                sh '''
                    npm install -g netlify-cli
                    netlify deploy --dir=build --prod
                '''
            }
        }

        /* =======================
           6) PROD E2E TESTS
        ======================= */
        stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.57.0-jammy'
                    args '-u root:root'
                }
            }

            environment {
                CI_ENVIRONMENT_URL = "${env.STAGING_URL}" // you can change this to real prod URL
            }

            steps {
                sh '''
                    echo "Running E2E on Production: $CI_ENVIRONMENT_URL"
                    npx playwright test --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Playwright Production Tests',
                        allowMissing: true,
                        keepAll: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }
    }
}
