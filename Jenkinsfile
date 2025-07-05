pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    CLUSTER_NAME = 'my-eks-cluster'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/Rajeshgupta123456789/Videotube.git'
      }
    }

    stage('Update kubeconfig') {
      steps {
        withAWS(credentials: 'd465032a-772e-4c90-9d2e-789476cb2af0', region: "${env.AWS_REGION}") {
          sh 'aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME'
        }
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        withAWS(credentials: 'd465032a-772e-4c90-9d2e-789476cb2af0', region: "${env.AWS_REGION}") {
          dir('helm/frontend') {
            sh '''
              export AWS_REGION=$AWS_REGION
              export AWS_PROFILE=default
              export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
              export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

              helm upgrade --install frontend . --namespace default --create-namespace
            '''
          }
        }
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        withAWS(credentials: 'd465032a-772e-4c90-9d2e-789476cb2af0', region: "${env.AWS_REGION}") {
          dir('helm/backend') {
            sh '''
              export AWS_REGION=$AWS_REGION
              export AWS_PROFILE=default
              export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
              export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

              helm upgrade --install backend . --namespace default --create-namespace
            '''
          }
        }
      }
    }
  }

  post {
    failure {
      echo '❌ Deployment failed. Please check the logs.'
    }
    success {
      echo '✅ Deployment completed successfully!'
    }
  }
}
