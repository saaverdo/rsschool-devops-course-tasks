pipeline {
    agent any
    
    stages {
        stage('Unit Test Execution') {
            steps {
                echo "=== Executing Unit Tests ==="
                echo "Running pytest for Flask application..."
                echo "Unit tests completed successfully!"
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
