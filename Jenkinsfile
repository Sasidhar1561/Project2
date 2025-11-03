pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'JDK_21'
    }

    environment {
        SONAR_URL = "https://sonarcloud.io"
        SONAR_TOKEN = credentials('sonarqube')   // Stored in Jenkins Credentials
        SONAR_ORGANIZATION = "vprofilesasi"
        SONAR_PROJECT_KEY = "vprofilesasi"
        registryCredential = 'ecr:us-east-1:awscred'
        appRegistry = "820672721556.dkr.ecr.us-east-1.amazonaws.com/vprofile"
        vprofileRegistry = "https://820672721556.dkr.ecr.us-east-1.amazonaws.com"
    }

        stage('Fetch code') {
            steps {
                git branch: 'main', url: 'https://github.com/hkhcoder/vprofile-action.git'
            }
        }

        stage('Artifact Build') {
            steps {
                // Don't skip tests here, we need compiled classes for Sonar
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        sonar-scanner \
                        -Dsonar.host.url=${SONAR_URL} \
                        -Dsonar.token=${SONAR_TOKEN} \
                        -Dsonar.organization=${SONAR_ORGANIZATION} \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
                    '''
                }
            }
        }
        stage("UploadArtifact"){
            steps{
                nexusArtifactUploader(
                  nexusVersion: 'nexus',
                  protocol: 'http',
                  nexusUrl: '172.31.11.68:8081/repository/vprofile/',
                  groupId: 'QA',
                  version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                  repository: 'vprofile',
                  credentialsId: 'nexus',
                  artifacts: [
                    [artifactId: 'vproapp',
                     classifier: '',
                     file: 'target/vprofile-v2.war',
                     type: 'war']
                  ]
                )
            }
        }
        stage('Build App Image') {
          steps {
            script {
                dockerImage = docker.build( appRegistry + ":$BUILD_NUMBER", ".")
                }
          }
        }
        
        stage('Upload App Image') {
          steps{
            script {
              docker.withRegistry( vprofileRegistry, registryCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
        }

        stage('Remove Container Images'){
            steps{
                sh 'docker rmi -f $(docker images -a -q)'
            }
        }
    }
}

