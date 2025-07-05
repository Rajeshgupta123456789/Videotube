pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-1"
    CLUSTER_NAME = "my-eks-cluster"
    FRONTEND_HELM_DIR = "helm/frontend"
    BACKEND_HELM_DIR  = "helm/backend"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/Rajeshgupta123456789/Videotube.git', branch: 'main'
      }
    }

    stage('Update kubeconfig') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'd465032a-772e-4c90-9d2e-789476cb2af0'
        ]]) {
          sh '''
            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
            aws configure set region $AWS_REGION
            aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
          '''
        }
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        dir("${FRONTEND_HELM_DIR}") {
          sh '''
            helm upgrade --install frontend . --namespace default --create-namespace
          '''
        }
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        dir("${BACKEND_HELM_DIR}") {
          sh '''
            helm upgrade --install backend . --namespace default --create-namespace
          '''
        }
      }
    }
  }

  post {
    success {
      echo '✅ Deployment completed successfully!'
    }
    failure {
      echo '❌ Deployment failed. Please check the logs.'
    }
  }
}
