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
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'd465032a-772e-4c90-9d2e-789476cb2af0',
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
          '''
        }
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'd465032a-772e-4c90-9d2e-789476cb2af0',
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          dir('helm/frontend') {
            sh '''
              export AWS_REGION=$AWS_REGION
              helm upgrade --install frontend . --namespace default --create-namespace
            '''
          }
        }
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'd465032a-772e-4c90-9d2e-789476cb2af0',
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          dir('helm/backend') {
            sh '''
              export AWS_REGION=$AWS_REGION
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
