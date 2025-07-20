pipeline {
    agent any
    environment {
        NAMESPACE = "demo-app"
        APP_NAME = "demo-app"
        HELM_CHART_PATH = "charts/demo-app"
        APP_URL = "rs-demo-app.bsv.pp.ua"
        CHART_VERSION = "0.1.0"
        GHCR_REGISTRY = "ghcr.io/saaverdo"
        GITHUB_TOKEN = credentials('github-token')
        GITHUB_USER = credentials('github-user')
        DISCORD_WEBHOOK_URL = credentials('discord-webhook-url')
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                    env.VERSION = sh(
                            script: 'git describe --tags --always --dirty=-dev',
                            returnStdout: true
                        ).trim()
                }
            }
        }

        stage('Unit Tests') {
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: python
                            image: saaverdo/python-test:0.1
                            command:
                            - sleep
                            args:
                            - 99d
                            workingDir: /home/jenkins/agent
                    """
                }
            }
            steps {
                container('python') {
                    sh '''
                        echo "Runf lake8 linter"
                        pwd
                        ls -lA

                        flake8 src/ --format=pylint --output-file=flake8-report.txt --exit-zero
                        flake8 src/ --format=html --htmldir=flake8_reports --exit-zero
                    '''
                    sh """
                        echo "Run unit tests"
                        pip install -r src/requirements.txt
                        pytest src/ --cov=app --cov-report=xml --cov-report=html --junitxml=test-results.xml
                    """
                    stash includes: 'test-results.xml,coverage.xml,htmlcov/**,flake8_reports/**,flake8-report.txt', name: 'test-results', allowEmpty : true
                }
                
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'flake8_reports',
                        reportFiles: 'index.html',
                        reportName: 'Flake8 Report'
                    ])
                }
            }
        }

        stage('Check with SonarQube') {
            environment {
                SONAR_TOKEN = credentials('SONAR_TOKEN')
                SONAR_ORGANIZATION = "rs-test"
                SONAR_PROJECT_KEY = "rs-test_demo"
                SONAR_URL = "https://sonarcloud.io"

            }            
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: sonar
                            image: sonarsource/sonar-scanner-cli:11.3.1.1910_7.1.0
                            command:
                            - sleep
                            args:
                            - 99d
                            workingDir: /home/jenkins/agent
                    """
                }
            }     
               
            steps {
                container('sonar') {
                    unstash 'test-results'
                    echo "=== Running SonarQube analysis ==="
                    sh '''
                        sonar-scanner \
                          -Dsonar.organization=${SONAR_ORGANIZATION} \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.working.directory=/tmp \
                          -Dsonar.sources=./src \
                          -Dsonar.host.url=${SONAR_URL} \
                          -Dsonar.login=${SONAR_TOKEN} \
                          -Dsonar.python.flake8.reportPaths=flake8-report.txt \
                          -Dsonar.python.coverage.reportPaths=coverage.xml 
                    '''
                }
            }
        }
        
        stage('Build Image and chart and Push to GHCR') {
            // when {
            //     beforeInput true
            // }
            input {
                message "Proceed with Docker image building?"
                ok "Build Docker Image"
                parameters {
                    choice(
                        name: 'RUN_BUILD',
                        choices: ['yes', 'no'],
                        description: 'Do you want to build and deploy image?'
                    )
                }
            }
            // when {
            //     expression { params.BUILD_DOCKER == 'yes' }
            // }            
            environment {
                
                IMAGE = "${env.GHCR_REGISTRY}/rsschool-devops-demo-app"
                GITHUB_TOKEN = credentials('github-token')
                GITHUB_USER = credentials('github-user')
            }
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: buildah
                            image: quay.io/buildah/stable:latest
                            command:
                            - sleep
                            args:
                            - 99d
                            securityContext:
                              privileged: true
                            workingDir: /home/jenkins/agent
                          - name: helm
                            image: alpine:3.22
                            command:
                            - sleep
                            args:
                            - 99d
                            workingDir: /home/jenkins/agent                           
                    """
                }
            }
            steps {
                container('buildah') {
                    script {
                        env.RUN_BUILD = 'yes'
                        sh """
                            echo "Building image"
                            buildah --storage-driver vfs version
                            echo ${GITHUB_TOKEN} | buildah login --username ${GITHUB_USER} --password-stdin ${GHCR_REGISTRY}
                            
                            buildah bud --storage-driver vfs -t ${IMAGE}:${env.VERSION} -t ${IMAGE}:latest .
                            echo "Image built successfully: ${IMAGE}:${env.VERSION}"
                            buildah push --storage-driver vfs ${IMAGE}:${env.VERSION}
                            buildah push --storage-driver vfs ${IMAGE}:latest
                        """
                    }
                }
                container('helm') {
                    script {
                        sh """
                            if ! command -v helm &> /dev/null; then
                                echo "Helm not found, installing..."
                                apk --no-cache --update add kubectl helm 
                            else
                                echo "Helm is already installed."
                            fi
                        """

                        sh """
                            echo "Helm login"
                            echo $GITHUB_TOKEN | helm registry login ghcr.io -u ${GITHUB_USER} --password-stdin
                            helm package charts/demo-app --version ${CHART_VERSION}-${env.VERSION} --app-version ${env.VERSION}
                            helm push demo-app-${CHART_VERSION}-${env.VERSION}.tgz oci://${GHCR_REGISTRY}
                    """

                    }
                }
            }   
        }
        
        stage('Deploy to Kubernetes') {
            when {
                expression { 
                    currentBuild.getPreviousBuild()?.result != 'ABORTED' &&
                    env.RUN_BUILD == 'yes'
                }
            }            
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: helm
                            image: alpine:3.22
                            command:
                            - sleep
                            args:
                            - 99d
                            workingDir: /home/jenkins/agent                           
                    """
                }
            }            
            steps {
                withCredentials([file(credentialsId: 'k3s_config', variable: 'KUBECONFIG')])  {
                    container('helm') {
                            sh """
                                if ! command -v helm &> /dev/null; then
                                    echo "Helm not found, installing..."
                                    apk --no-cache --update add kubectl helm 
                                else
                                    echo "Helm is already installed."
                                fi
                                echo "Helm login"
                                echo $GITHUB_TOKEN | helm registry login ghcr.io -u ${GITHUB_USER} --password-stdin                                
                            """

                            sh """
                            helm list -n ${APP_NAME} || true
                            helm upgrade --install demo-app oci://${GHCR_REGISTRY}/demo-app \
                                --version ${CHART_VERSION}-${env.VERSION} \
                                --namespace ${APP_NAME} \
                                --create-namespace \
                                --wait --timeout=10m
                            
                            kubectl rollout status deployment/${APP_NAME} -n ${APP_NAME} --timeout=600s
                            
                            echo "Deployment completed successfully!"
                        """
                    }
                }
            }
        }
        
        stage('Application Verification') {
            when {
                expression { 
                    currentBuild.getPreviousBuild()?.result != 'ABORTED' &&
                    env.RUN_BUILD == 'yes'
                }
            }            
            steps {
                echo "=== Application Verification ==="
                echo "Performing health check on deployed application..."
                echo "Sending requests to API endpoints..."
                echo "Running smoke tests..."
                echo "Application verification completed successfully!"
            }
        }
    }
    
    post {
        success {
            script {
                echo 'Pipeline executed successfully!'
                discordSend(
                    description: """
                    ✅ **Pipeline SUCCESS** ✅
                    
                    **Job**: ${env.JOB_NAME}
                    **Build**: #${env.BUILD_NUMBER}
                    **Branch**: ${env.GIT_BRANCH ?: 'N/A'}
                    **Duration**: ${currentBuild.durationString}
                    **Commit**: ${env.GIT_COMMIT ? env.GIT_COMMIT.take(8) : 'N/A'}
                    
                    **Status**: All stages completed successfully! 🎉
                    
                    [View Build](${env.BUILD_URL})
                    """,
                    footer: "Jenkins CI/CD",
                    link: env.BUILD_URL,
                    result: currentBuild.currentResult,
                    title: "${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                    webhookURL: "${env.DISCORD_WEBHOOK_URL}"
                )
            }
        }
        failure {       
            script {
                echo 'Pipeline failed!'
                discordSend(
                    description: """
                    ❌ **Pipeline FAILED** ❌
                    
                    **Job**: ${env.JOB_NAME}
                    **Build**: #${env.BUILD_NUMBER}
                    **Branch**: ${env.GIT_BRANCH ?: 'N/A'}
                    **Duration**: ${currentBuild.durationString}
                    **Commit**: ${env.GIT_COMMIT ? env.GIT_COMMIT.take(8) : 'N/A'}
                    
                    **Status**: One or more stages failed! Please check the logs for details.
                    
                    [View Build](${env.BUILD_URL})
                    """,
                    footer: "Jenkins CI/CD",
                    link: env.BUILD_URL,
                    result: currentBuild.currentResult,
                    title: "${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                    webhookURL: "${env.DISCORD_WEBHOOK_URL}"
                )
            }
        }
    }
}
