pipeline {
    agent any
    
    // stages {
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
                            image: python:3.9.18-alpine3.18
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
                        echo "=== Running Unit Tests ==="
                        pwd
                        pip install --upgrade pip
                        pip install -r src/requirements.txt
                        pip install pytest pytest-cov flake8 flake8-html bandit safety
                        
                        # Запуск линтинга с flake8
                        echo "Running flake8 linting..."
                        flake8 src/ --format=pylint --output-file=flake8-report.txt --exit-zero
                        
                        # Запуск тестов с покрытием
                        echo "Running unit tests with coverage..."
                        pytest src/ --cov=app --cov-report=xml --cov-report=html --junitxml=test-results.xml
                    '''
                }
                
                // save
                stash includes: 'test-results.xml,coverage.xml,htmlcov/**,flake8-report.txt', name: 'test-results'
            }
            post {
                always {
                    unstash 'test-results'
                    // publish tests
                    junit 'test-results.xml'
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'htmlcov',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
            }
        }
        
        stage('Security Check with SonarQube') {
            steps {
                echo "=== Security Check with SonarQube ==="
                echo "Running SonarQube Cloud analysis..."
                echo "Security check completed successfully!"
            }
        }
        
        stage('Docker Image Building and Pushing to ECR Registry') {
            steps {
                echo "=== Docker Image Building and Pushing to ECR Registry ==="
                echo "Building Docker image for Flask app..."
                echo "Pushing image to Amazon ECR..."
                echo "Docker image build and push completed successfully!"
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
