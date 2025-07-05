pipeline {
  agent { label "vinod" }

  environment {
    AWS_REGION = 'us-east-1'
    CLUSTER_NAME = 'my-eks-cluster'
    FRONTEND_CHART = 'charts/frontend'
    BACKEND_CHART = 'charts/backend'
  }

    stage('Update kubeconfig') {
      steps {
        sh """
        aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
        """
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        sh """
        helm upgrade --install frontend ${FRONTEND_CHART} --namespace default
        """
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        sh """
        helm upgrade --install backend ${BACKEND_CHART} --namespace default
        """
      }
    }
  }
}
