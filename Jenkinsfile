import hudson.Util;
import java.time.*;

def now = new Date()

pipeline {
    
    agent any

    environment{
        PROJECT_ID="javaapp"
        REGISTRY_PATH="rohith369"
        TAG=now.format("yyyyMMddHHmm")
        HELM_TEMPLATES_PATH="ci/deploy/helm/micro-service"
        VOLUME="maven-repo"
        BUILD_ARTIFACT_PATH="/root/dist/webapp.war"
        KUBE_CONFIG_PATH="$HOME/.kube/config"
        NAMESPACE="dev"
    }

    stages{
      // This step is optional, in real time we create a separate pipeline to 
      // create build containers
      stage('build-container'){
        environment {
          MAVEN_VERSION = "3.6.3"
        }
        steps{
            sh """
            cd ci/maven/

            docker build --no-cache --pull -t maven \
            --build-arg MAVEN_VERSION=${MAVEN_VERSION} \
            -f Dockerfile.maven .

            docker tag maven:latest maven:${MAVEN_VERSION}

            """   
        }
      }

      stage('build'){
          steps{
              sh """

              docker volume create --name maven-repo

              docker build --no-cache --pull -t ${PROJECT_ID}.build \
              -f ci/Dockerfile.build .

              docker run -itd -v ${VOLUME}:/root/.m2 \
              --name ${PROJECT_ID}.build ${PROJECT_ID}.build

              docker cp -a ${PROJECT_ID}.build:${BUILD_ARTIFACT_PATH} .

              docker rm -f ${PROJECT_ID}.build

              # Build the Dockerfile
              docker build --no-cache --pull -t ${PROJECT_ID} .

              """   
          }
      }
      
      stage('publish'){
          steps{
              sh """
              
              docker tag ${PROJECT_ID}:latest ${REGISTRY_PATH}/${PROJECT_ID}:latest
              docker push ${REGISTRY_PATH}/${PROJECT_ID}:latest
              sudo docker tag ${REGISTRY_PATH}/${PROJECT_ID}:latest ${REGISTRY_PATH}/${PROJECT_ID}:${TAG}
              docker push ${REGISTRY_PATH}/${PROJECT_ID}:${TAG}

              """
          }
      }

      stage('deploy'){
          steps{
              sh """
              helm --kubeconfig ${KUBE_CONFIG_PATH} \
                   --namespace ${NAMESPACE} \
                   upgrade --install ${PROJECT_ID} \
                   -f ci/deploy/helm/${PROJECT_ID}-values.yaml \
                   --debug --dry-run ${HELM_TEMPLATES_PATH} \
                   --set deployment.image=${REGISTRY_PATH}/${PROJECT_ID}:${TAG} \
                   --set namespace=${NAMESPACE} > helm_template

              cat helm_template

              helm --kubeconfig ${KUBE_CONFIG_PATH} \
              --namespace ${NAMESPACE} \
              upgrade --install ${PROJECT_ID} \
              -f ci/deploy/helm/${PROJECT_ID}-values.yaml \
              ${HELM_TEMPLATES_PATH} \
              --set deployment.image=${REGISTRY_PATH}/${PROJECT_ID}:${TAG} \
              --set namespace=${NAMESPACE} > helm_template

              """
          }
      }
    }

    post {
    always {
        archiveArtifacts artifacts: "helm_template", fingerprint: true
    }
  }
}
