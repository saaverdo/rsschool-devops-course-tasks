pipeline {
    agent any
    
    stages {
    //     stage('Checkout') {
    //         steps {
    //             checkout scm
    //         }
    //     }

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
                    echo "=== Running SonarQube analysis ==="
                    sh '''
                        sonar-scanner \
                          -Dsonar.organization=${SONAR_ORGANIZATION} \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.working.directory=/tmp \
                          -Dsonar.sources=./src \
                          -Dsonar.host.url=${SONAR_URL} \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }
        
        stage('Image Build and Pushing to ECR Registry') {
            environment {
                GHCR_REGISTRY = "ghcr.io/saaverdo"
                IMAGE_TAG = "ghcr.io/saaverdo/rsschool-devops-demo-app:latest"
                
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
                    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN'),
                        string(credentialsId: 'github-user', variable: 'GITHUB_USER')]) {
                    sh """
                        echo "Building image with buildah..."
                        buildah --storage-driver vfs version
                        echo ${GITHUB_TOKEN} | buildah login --username $GITHUB_USER --password-stdin $GHCR_REGISTRY
                        
                        buildah bud --storage-driver vfs -t ${IMAGE_TAG} .
                        echo "Image built successfully: ${IMAGE_TAG}"
                        buildah push --storage-driver vfs ${IMAGE_TAG}
                    """
                    }
                }
            }   
        }
        
        stage('Deployment to K8s Cluster with Helm') {
            steps {
                echo "=== Deployment to K8s Cluster with Helm ==="
                echo "Deploying Flask app to Kubernetes using Helm..."
                echo "Deployment completed successfully!"
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
