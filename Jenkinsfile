pipeline {
    agent any
    environment{
        NETLIFY_SITE_ID ='be1133e0-d5ac-4f24-bab1-9a5e0c7e43bf'
        NETLIFY_AUTH_TOKEN= credentials('netlify-token')
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
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                    '''
               }
        }
        
        stage('Unit_test'){
            agent{
                 docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps{
                sh '''
                    test -f build/index.html
                    npm test
                    '''
            }
        }
         stage('ETE'){
            agent{
                 docker {
                    image 'mcr.microsoft.com/playwright:v1.56.1-noble'
                    reuseNode true
                }
            }
            steps{
                sh '''
                    npm install serve
                    chmod +x node_modules/serve
                    nohup ./node_modules/.bin/serve -s build -l 3000 &
                    sleep 10
                    npx playwright test
                    '''
            }
        }
        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli 
                    node_modules/.bin/netlify --version
                    echo ' Deploying to prod. Site ID: $NETLIFY_SITE_ID'
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --no-build
                    '''
               }
        }
    }
    post{
        always{
            junit 'jest-results/junit.xml'
        }
    }
}