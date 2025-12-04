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
                    echo "Triggering Render Deployment..."
                    SERVICE_ID="srv-d4olkdvpm1nc73eags80"
                    API_KEY="${RENDER_API_KEY}"
                    
                    if [ -z "${API_KEY}" ]; then
                        echo "Error: RENDER_API_KEY is not set"
                        exit 1
                    fi
                    
                    # Use Node.js to trigger deployment and poll status
                    SERVICE_ID="${SERVICE_ID}" API_KEY="${API_KEY}" node << 'EOF'
                    const https = require('https');
                    
                    const SERVICE_ID = process.env.SERVICE_ID;
                    const API_KEY = process.env.API_KEY;
                    
                    function makeRequest(options, data) {
                        return new Promise((resolve, reject) => {
                            const req = https.request(options, (res) => {
                                let body = '';
                                res.on('data', (chunk) => body += chunk);
                                res.on('end', () => {
                                    try {
                                        const parsed = JSON.parse(body);
                                        resolve({ statusCode: res.statusCode, data: parsed });
                                    } catch (e) {
                                        resolve({ statusCode: res.statusCode, data: body });
                                    }
                                });
                            });
                            
                            req.on('error', reject);
                            if (data) {
                                req.write(JSON.stringify(data));
                            }
                            req.end();
                        });
                    }
                    
                    async function triggerDeployment() {
                        const options = {
                            hostname: 'api.render.com',
                            path: `/v1/services/${SERVICE_ID}/deploys`,
                            method: 'POST',
                            headers: {
                                'Authorization': `Bearer ${API_KEY}`,
                                'Accept': 'application/json',
                                'Content-Type': 'application/json'
                            }
                        };
                        
                        console.log('Triggering deployment...');
                        const response = await makeRequest(options);
                        
                        console.log(`HTTP Status Code: ${response.statusCode}`);
                        console.log(`Response: ${JSON.stringify(response.data, null, 2)}`);
                        
                        if (response.statusCode !== 201 && response.statusCode !== 200) {
                            console.error(`Error: Failed to trigger deployment. HTTP ${response.statusCode}`);
                            process.exit(1);
                        }
                        
                        const deployId = response.data.deploy?.id || response.data.id || response.data.deployId;
                        
                        if (!deployId) {
                            console.log('Warning: Could not extract deploy ID from response');
                            console.log('Deployment may have been triggered, but cannot monitor status');
                            console.log('Please check Render dashboard for deployment status');
                            process.exit(0);
                        }
                        
                        console.log(`Deploy ID: ${deployId}`);
                        console.log('Waiting for deployment to complete...');
                        
                        // Poll deployment status
                        const MAX_ATTEMPTS = 60;
                        for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
                            await new Promise(resolve => setTimeout(resolve, 10000)); // Wait 10 seconds
                            
                            const statusOptions = {
                                hostname: 'api.render.com',
                                path: `/v1/deploys/${deployId}`,
                                method: 'GET',
                                headers: {
                                    'Authorization': `Bearer ${API_KEY}`,
                                    'Accept': 'application/json'
                                }
                            };
                            
                            const statusResponse = await makeRequest(statusOptions);
                            const status = statusResponse.data.deploy?.status || statusResponse.data.status;
                            
                            if (!status) {
                                console.log(`Warning: Could not determine deployment status (attempt ${attempt + 1}/${MAX_ATTEMPTS})`);
                                continue;
                            }
                            
                            console.log(`Deployment status: ${status} (attempt ${attempt + 1}/${MAX_ATTEMPTS})`);
                            
                            if (status === 'live') {
                                console.log('Deployment completed successfully!');
                                process.exit(0);
                            } else if (status === 'build_failed' || status === 'update_failed' || status === 'canceled') {
                                console.error(`Deployment failed with status: ${status}`);
                                process.exit(1);
                            }
                        }
                        
                        console.error(`Deployment did not complete within expected time (${MAX_ATTEMPTS} attempts)`);
                        console.log('Please check Render dashboard for current status');
                        process.exit(1);
                    }
                    
                    triggerDeployment().catch((error) => {
                        console.error('Error:', error.message);
                        process.exit(1);
                    });
                    EOF
                '''
            }
        }

    }
}