pipeline {
  agent any

  environment {
    AWS_REGION      = 'us-east-1'
    CLUSTER_NAME    = 'my-eks-cluster'
    HELM_NAMESPACE  = 'default'
    BACKEND_IMAGE   = '208496905340.dkr.ecr.us-east-1.amazonaws.com/videotube-backend'
    FRONTEND_IMAGE  = '208496905340.dkr.ecr.us-east-1.amazonaws.com/videotube-frontend'
    IMAGE_TAG       = "${BUILD_NUMBER}"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/Rajeshgupta123456789/Videotube.git', branch: 'main'
      }
    }

    stage('Update kubeconfig') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

          sh '''
            aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
          '''
        }
      }
    }

    stage('Login to ECR') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

          sh '''
            aws ecr get-login-password --region $AWS_REGION | \
            docker login --username AWS --password-stdin $BACKEND_IMAGE
          '''
        }
      }
    }

    stage('Build & Push Backend Image') {
      steps {
        dir('docker/backend') {
          script {
            def imageExists = sh(
              script: """
                aws ecr describe-images \
                  --repository-name videotube-backend \
                  --image-ids imageTag=$IMAGE_TAG \
                  --region $AWS_REGION >/dev/null 2>&1
              """,
              returnStatus: true
            ) == 0

            if (imageExists) {
              echo "✅ Backend image already exists in ECR. Skipping build."
            } else {
              sh """
                docker build -t $BACKEND_IMAGE:$IMAGE_TAG .
                docker tag $BACKEND_IMAGE:$IMAGE_TAG $BACKEND_IMAGE:latest
                docker push $BACKEND_IMAGE:$IMAGE_TAG
                docker push $BACKEND_IMAGE:latest
              """
            }
          }
        }
      }
    }

    stage('Build & Push Frontend Image') {
      steps {
        dir('docker/frontend') {
          script {
            def imageExists = sh(
              script: """
                aws ecr describe-images \
                  --repository-name videotube-frontend \
                  --image-ids imageTag=$IMAGE_TAG \
                  --region $AWS_REGION >/dev/null 2>&1
              """,
              returnStatus: true
            ) == 0

            if (imageExists) {
              echo "✅ Frontend image already exists in ECR. Skipping build."
            } else {
              sh """
                docker build -t $FRONTEND_IMAGE:$IMAGE_TAG .
                docker tag $FRONTEND_IMAGE:$IMAGE_TAG $FRONTEND_IMAGE:latest
                docker push $FRONTEND_IMAGE:$IMAGE_TAG
                docker push $FRONTEND_IMAGE:latest
              """
            }
          }
        }
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        dir('helm/frontend') {
          sh '''
            helm upgrade --install frontend . \
              --namespace $HELM_NAMESPACE --create-namespace \
              --set image.repository=$FRONTEND_IMAGE \
              --set image.tag=$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        dir('helm/backend') {
          sh '''
            helm upgrade --install backend . \
              --namespace $HELM_NAMESPACE --create-namespace \
              --set image.repository=$BACKEND_IMAGE \
              --set image.tag=$IMAGE_TAG
          '''
        }
      }
    }
  }

  post {
    success {
      echo '✅ Successfully built, pushed, and deployed backend and frontend to EKS!'
    }
    failure {
      echo '❌ Pipeline failed. Please check the logs above.'
    }
  }
}
