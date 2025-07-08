pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    CLUSTER_NAME = 'my-eks-cluster'
    HELM_NAMESPACE = 'default'
    TERRAFORM_DIR = 'terraform/phase2-eks'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/Rajeshgupta123456789/Videotube.git', branch: 'main'
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        dir("${TERRAFORM_DIR}") {
          withCredentials([[ 
            $class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: 'aws-creds',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]) {
            sh '''
              export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
              export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

              terraform init
              terraform plan -out=tfplan
            '''
          }
        }
      }
    }

    stage('Terraform Apply (Manual Approval)') {
      steps {
        timeout(time: 10, unit: 'MINUTES') {
          input message: 'Do you want to proceed with terraform apply?'
        }
        dir("${TERRAFORM_DIR}") {
          withCredentials([[ 
            $class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: 'aws-creds',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]) {
            sh '''
              export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
              export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

              terraform apply -auto-approve tfplan
            '''
          }
        }
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

    stage('Login to ECR') {
      steps {
        withCredentials([[ 
          $class: 'AmazonWebServicesCredentialsBinding', 
          credentialsId: 'aws-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh '''
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 208496905340.dkr.ecr.$AWS_REGION.amazonaws.com/videotube-backend
          '''
        }
      }
    }

    stage('Build & Push Backend Image') {
      steps {
        dir('docker/backend') {
          script {
            def tag = "53"
            def repo = "208496905340.dkr.ecr.${env.AWS_REGION}.amazonaws.com/videotube-backend"
            def imageExists = sh(
              script: "aws ecr describe-images --repository-name videotube-backend --image-ids imageTag=${tag} --region ${env.AWS_REGION}",
              returnStatus: true
            ) == 0

            if (!imageExists) {
              sh """
                docker build -t ${repo}:${tag} .
                docker tag ${repo}:${tag} ${repo}:latest
                docker push ${repo}:${tag}
                docker push ${repo}:latest
              """
            } else {
              echo "✅ Backend image with tag ${tag} already exists in ECR. Skipping build."
            }
          }
        }
      }
    }

    stage('Build & Push Frontend Image') {
      steps {
        dir('docker/frontend') {
          script {
            def tag = "53"
            def repo = "208496905340.dkr.ecr.${env.AWS_REGION}.amazonaws.com/videotube-frontend"
            def imageExists = sh(
              script: "aws ecr describe-images --repository-name videotube-frontend --image-ids imageTag=${tag} --region ${env.AWS_REGION}",
              returnStatus: true
            ) == 0

            if (!imageExists) {
              sh """
                docker build -t ${repo}:${tag} .
                docker tag ${repo}:${tag} ${repo}:latest
                docker push ${repo}:${tag}
                docker push ${repo}:latest
              """
            } else {
              echo "✅ Frontend image with tag ${tag} already exists in ECR. Skipping build."
            }
          }
        }
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        withCredentials([[ 
          $class: 'AmazonWebServicesCredentialsBinding', 
          credentialsId: 'aws-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          dir('helm/frontend') {
            sh '''
              export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
              export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

              aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

              helm upgrade --install frontend . \
                --namespace $HELM_NAMESPACE --create-namespace \
                --set image.repository=208496905340.dkr.ecr.us-east-1.amazonaws.com/videotube-frontend \
                --set image.tag=53
            '''
          }
        }
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        withCredentials([[ 
          $class: 'AmazonWebServicesCredentialsBinding', 
          credentialsId: 'aws-creds',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          dir('helm/backend') {
            sh '''
              export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
              export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

              aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

              helm upgrade --install backend . \
                --namespace $HELM_NAMESPACE --create-namespace \
                --set image.repository=208496905340.dkr.ecr.us-east-1.amazonaws.com/videotube-backend \
                --set image.tag=53
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo '✅ Successfully deployed infrastructure, frontend & backend!'
    }
    failure {
      echo '❌ Pipeline failed. Please check the logs.'
    }
  }
}
