pipeline {
  agent any
  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    CLUSTER_NAME = 'my-eks-cluster'
  }
  stages {
    stage('Update kubeconfig') {
      steps {
        sh 'aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name $CLUSTER_NAME'
      }
    }

stage('Deploy Frontend with Helm') {
  steps {
    sh 'helm upgrade --install frontend ./helm/frontend'
  }
}

stage('Deploy Backend with Helm') {
  steps {
    sh 'helm upgrade --install backend ./helm/backend'
  }
}
  }
}
