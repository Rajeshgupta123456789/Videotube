pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    CLUSTER_NAME = 'my-eks-cluster'
    HELM_NAMESPACE = 'default'
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
          credentialsId: 'aws-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
          '''
        }
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        sh '''
          export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
          export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
        '''
        dir('helm/frontend') {
          sh '''
            helm upgrade --install frontend . \
              --namespace $HELM_NAMESPACE --create-namespace
          '''
        }
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        sh '''
          export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
          export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
        '''
        dir('helm/backend') {
          sh '''
            helm upgrade --install backend . \
              --namespace $HELM_NAMESPACE --create-namespace
          '''
        }
      }
    }
  }

  post {
    failure {
      echo '❌ Deployment failed. Please check the logs.'
    }
    success {
      echo '✅ Deployment successful!'
    }
  }
}
