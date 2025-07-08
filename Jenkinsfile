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

    stage('Terraform Init & Plan') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          dir('terraform/phase2-eks') {
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
    }

    stage('Terraform Apply (Manual Approval)') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          script {
            def userApproval = input(
              message: 'Terraform Plan Complete. Apply?',
              parameters: [choice(name: 'APPROVE', choices: ['No', 'Yes'], description: 'Apply Terraform changes?')]
            )
            if (userApproval == 'Yes') {
              dir('terraform/phase2-eks') {
                withCredentials([[
                  $class: 'AmazonWebServicesCredentialsBinding',
                  credentialsId: 'aws-creds',
                  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                  sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                    terraform apply tfplan
                  '''
                }
              }
            } else {
              echo '⏩ Terraform Apply was skipped by user.'
            }
          }
        }
      }
    }

    stage('Update kubeconfig') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
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
    }

    stage('Login to ECR') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
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
    }

    stage('Build & Push Backend Image') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
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
                echo "✅ Backend image with tag ${tag} already exists. Skipping build."
              }
            }
          }
        }
      }
    }

    stage('Build & Push Frontend Image') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
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
                echo "✅ Frontend image with tag ${tag} already exists. Skipping build."
              }
            }
          }
        }
      }
    }

    stage('Deploy Frontend with Helm') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          dir('helm/frontend') {
            withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'aws-creds',
              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
            ]]) {
              sh '''
                export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                helm upgrade --install frontend . \
                  --namespace $HELM_NAMESPACE --create-namespace \
                  --set image.repository=208496905340.dkr.ecr.us-east-1.amazonaws.com/videotube-frontend \
                  --set image.tag=53
              '''
            }
          }
        }
      }
    }

    stage('Deploy Backend with Helm') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          dir('helm/backend') {
            withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: 'aws-creds',
              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
            ]]) {
              sh '''
                export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

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

    stage('Terraform Destroy (Manual)') {
      when {
        beforeInput true
        expression {
          return input(
            message: "⚠️ Do you want to destroy all Terraform resources?",
            parameters: [
              choice(name: 'DESTROY_ENV', choices: ['No', 'Yes'], description: 'Select Yes to destroy infrastructure')
            ]
          ) == 'Yes'
        }
      }
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          dir('terraform/phase2-eks') {
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
                terraform destroy -auto-approve
              '''
            }
          }
        }
      }
    }
  }

  post {
    always {
      echo '📦 Pipeline finished. Check logs above.'
    }
  }
}
