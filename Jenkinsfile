pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID     = 'be1133e0-d5ac-4f24-bab1-9a5e0c7e43bf'
        NETLIFY_AUTH_TOKEN  = credentials('netlify-token')
    }

    stages {

        /* =======================
           BUILD STAGE
        ======================= */
        stage('Build') {
            agent {
                docker {
                    image 'node:20-alpine'
                    args '-u root:root'        // <<< FIX: מריץ כ־root
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "=== Node & NPM Versions ==="
                    node --version
                    npm --version

                    echo "=== Fixing NPM Cache Path ==="
                    export NPM_CONFIG_CACHE=/tmp/.npm
                    mkdir -p /tmp/.npm

                    echo "=== Installing dependencies ==="
                    npm ci --omit=optional

                    echo "=== Building project ==="
                    npm run build

                    echo "=== Build directory ==="
                    ls -la build/
                '''
            }
        }


        /* =======================
           PARALLEL TESTING
        ======================= */
        stage('Tests') {
            parallel {

                /* ---- UNIT TESTS ---- */
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
                            mkdir -p /tmp/.npm

                            npm test --if-present
                        '''
                    }

                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'test-results/junit.xml'
                        }
                    }
                }


                /* ---- E2E TESTS LOCAL ---- */
                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.48.2-jammy'
                            args '-u root:root'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            export NPM_CONFIG_CACHE=/tmp/.npm
                            mkdir -p /tmp/.npm

                            echo "=== Installing serve ==="
                            npm install serve

                            echo "=== Starting local server ==="
                            npx serve -s build & 
                            sleep 10

                            echo "=== Running Playwright tests ==="
                            npx playwright test --reporter=html
                        '''
                    }

                    post {
                        always {
                            publishHTML([
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Playwright Local',
                                allowMissing: false,
                                keepAll: true,
                                alwaysLinkToLastBuild: true,
                                useWrapperFileDirectly: true
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
                sh '''
                    export NPM_CONFIG_CACHE=/tmp/.npm
                    mkdir -p /tmp/.npm

                    echo "=== Installing Netlify CLI ==="
                    npm install -g netlify-cli

                    echo "Deploying to Staging..."
                    netlify --version
                    netlify status
                    netlify deploy --dir=build
                '''
            }
        }


        /* =======================
           APPROVAL BEFORE PRODUCTION
        ======================= */
        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Do you wish to deploy to production?', ok: 'Yes, Deploy Now!'
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
                    mkdir -p /tmp/.npm

                    npm install -g netlify-cli

                    echo "Deploying to Production..."
                    netlify --version
                    netlify status
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

            environment {
                CI_ENVIRONMENT_URL = 'PUT YOUR NETLIFY SITE URL HERE'
            }

            steps {
                sh '''
                    export NPM_CONFIG_CACHE=/tmp/.npm
                    mkdir -p /tmp/.npm

                    echo "Running Playwright tests against PRODUCTION: $CI_ENVIRONMENT_URL"
                    npx playwright test --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([
                        reportDir: 'playwright-report',
                        reportFiles: 'index.html',
                        reportName: 'Playwright E2E (Production)',
                        allowMissing: false,
                        keepAll: true,
                        alwaysLinkToLastBuild: true,
                        useWrapperFileDirectly: true
                    ])
                }
            }
        }
    }
}
