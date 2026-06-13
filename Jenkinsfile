pipeline {
    agent any
    triggers {
        githubPush()
    }
    environment {
        APP_NAME    = "abc_tech"
        DOCKER_REPO = "nabad600"
        CONTAINER   = "abc_tech"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                credentialsId: 'github-creds',
                    url: 'https://github.com/nabad600/pgdevops-project.git'
            }
        }

        stage('Set Build Variables') {
            steps {
                script {
                    env.TIMESTAMP = sh(
                        script: "date +'%Y%m%d-%H%M%S'",
                        returnStdout: true
                    ).trim()

                    env.IMAGE_TAG = "${env.TIMESTAMP}-b${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean package'
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.war',
                                 fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    cp target/*.war ${APP_NAME}.war

                    docker build \
                      -t ${DOCKER_REPO}/${APP_NAME}:${IMAGE_TAG} \
                      -t ${DOCKER_REPO}/${APP_NAME}:latest \
                      .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry(
                    credentialsId: 'dockerhub',
                    url: ''
                ) {
                    sh """
                        docker push ${DOCKER_REPO}/${APP_NAME}:${IMAGE_TAG}
                        docker push ${DOCKER_REPO}/${APP_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    docker run -d --name ${IMAGE_TAG}-${CONTAINER} -P ${DOCKER_REPO}/${APP_NAME}:${IMAGE_TAG}
                """
            }
        }
    }
}
