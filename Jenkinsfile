pipeline {
    agent any

    environment {
        RENDER_API_KEY = credentials('RENDER_API_KEY_CRED')
    }

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
        stage('Deploy to Render') {

            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    # Install curl if not available (should be in alpine, but just in case)
                    apk add --no-cache curl || true
                    
                    echo "Triggering Render Deployment..."
                    SERVICE_ID="srv-d4olkdvpm1nc73eags80"
                    API_KEY="${RENDER_API_KEY}"
                    
                    if [ -z "${API_KEY}" ]; then
                        echo "Error: RENDER_API_KEY is not set"
                        exit 1
                    fi
                    
                    # Trigger deployment
                    DEPLOY_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
                        -H "Authorization: Bearer ${API_KEY}" \
                        -H "Accept: application/json" \
                        "https://api.render.com/v1/services/${SERVICE_ID}/deploys")
                    
                    HTTP_CODE=$(echo "${DEPLOY_RESPONSE}" | tail -n1)
                    RESPONSE_BODY=$(echo "${DEPLOY_RESPONSE}" | sed '$d')
                    
                    echo "HTTP Status Code: ${HTTP_CODE}"
                    echo "Response: ${RESPONSE_BODY}"
                    
                    if [ "${HTTP_CODE}" != "201" ] && [ "${HTTP_CODE}" != "200" ]; then
                        echo "Error: Failed to trigger deployment. HTTP ${HTTP_CODE}"
                        exit 1
                    fi
                    
                    # Extract deploy ID from response (try multiple patterns)
                    DEPLOY_ID=$(echo "${RESPONSE_BODY}" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
                    
                    if [ -z "${DEPLOY_ID}" ]; then
                        # Try alternative pattern
                        DEPLOY_ID=$(echo "${RESPONSE_BODY}" | grep -o '"deployId":"[^"]*' | head -1 | cut -d'"' -f4)
                    fi
                    
                    if [ -z "${DEPLOY_ID}" ]; then
                        echo "Warning: Could not extract deploy ID from response"
                        echo "Deployment may have been triggered, but cannot monitor status"
                        echo "Please check Render dashboard for deployment status"
                        exit 0
                    fi
                    
                    echo "Deploy ID: ${DEPLOY_ID}"
                    echo "Waiting for deployment to complete..."
                    
                    # Poll deployment status
                    MAX_ATTEMPTS=60
                    ATTEMPT=0
                    while [ ${ATTEMPT} -lt ${MAX_ATTEMPTS} ]; do
                        STATUS_RESPONSE=$(curl -s -X GET \
                            -H "Authorization: Bearer ${API_KEY}" \
                            -H "Accept: application/json" \
                            "https://api.render.com/v1/deploys/${DEPLOY_ID}")
                        
                        STATUS=$(echo "${STATUS_RESPONSE}" | grep -o '"status":"[^"]*' | head -1 | cut -d'"' -f4)
                        
                        if [ -z "${STATUS}" ]; then
                            echo "Warning: Could not determine deployment status"
                            sleep 10
                            ATTEMPT=$((ATTEMPT + 1))
                            continue
                        fi
                        
                        echo "Deployment status: ${STATUS} (attempt ${ATTEMPT}/${MAX_ATTEMPTS})"
                        
                        if [ "${STATUS}" = "live" ]; then
                            echo "Deployment completed successfully!"
                            exit 0
                        elif [ "${STATUS}" = "build_failed" ] || [ "${STATUS}" = "update_failed" ] || [ "${STATUS}" = "canceled" ]; then
                            echo "Deployment failed with status: ${STATUS}"
                            exit 1
                        fi
                        
                        sleep 10
                        ATTEMPT=$((ATTEMPT + 1))
                    done
                    
                    echo "Deployment did not complete within expected time (${MAX_ATTEMPTS} attempts)"
                    echo "Please check Render dashboard for current status"
                    exit 1
                '''
            }
        }

    }
}