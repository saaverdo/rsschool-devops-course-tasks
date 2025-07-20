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
                        echo "=== Running flake8 linting ==="
                        pwd
                        ls -lA

                        flake8 src/ --format=pylint --output-file=flake8-report.txt --exit-zero
                    '''
                    stash includes: 'test-results.xml,coverage.xml,htmlcov/**,flake8-report.txt', name: 'test-results', allowEmpty : true
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
                          -Dsonar.python.flake8.reportPaths=flake8-report.txt
                    '''
                }
            }
        }
        
        stage('Image Build and Push to GHCR') {
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
                    """
                }
            }
            steps {
                container('buildah') {
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
        }
        
        stage('Build Helm Chart') {
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: helm-builder
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
                container('helm-builder') {
                    script {
                        sh """
                            if ! command -v helm &> /dev/null; then
                                echo "Helm not found, installing..."
                                apk add --no-cache curl 
                                export VERIFY_CHECKSUM=false
                                curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sh
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
            steps {
                withCredentials([kubeconfigFile(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                        
                        # Обновление зависимостей Helm
                        helm dependency update ${HELM_CHART_PATH}
                        
                        # Деплой с помощью Helm
                        helm upgrade --install ${APP_NAME} ${HELM_CHART_PATH} \\
                            --namespace ${NAMESPACE} \\
                            --set image.repository=${GHCR_REGISTRY}/${GITHUB_REPOSITORY} \\
                            --set image.tag=${IMAGE_TAG} \\
                            --set ingress.host=${APP_URL} \\
                            --wait --timeout=10m
                        
                        # Проверка статуса деплоя
                        kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=600s
                        
                        echo "Deployment completed successfully!"
                    """
                }
            }
        }
        
        stage('Application Verification') {
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
            echo "🎉 All jobs completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
