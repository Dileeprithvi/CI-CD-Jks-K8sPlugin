def mvn
def server = Artifactory.server 'artifactory'
def rtMaven = Artifactory.newMavenBuild()
def buildInfo
def DockerTag() {
	def tag = sh script: 'git rev-parse HEAD', returnStdout:true
	return tag
	}
pipeline {
  agent { label 'master' }
    tools {
      maven 'Maven'
      jdk 'JAVA_HOME'
    }
  options { 
    timestamps () 
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '10', numToKeepStr: '5')	
// numToKeepStr - Max # of builds to keep
// daysToKeepStr - Days to keep builds
// artifactDaysToKeepStr - Days to keep artifacts
// artifactNumToKeepStr - Max # of builds to keep with artifacts	  
}	
  environment {
    SONAR_HOME = "${tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'}"
    DOCKER_TAG = DockerTag()	  
  }  
  stages {
    stage('Artifactory_Configuration') {
      steps {
        script {
		  rtMaven.tool = 'Maven'
		  rtMaven.resolver releaseRepo: 'libs-release', snapshotRepo: 'libs-snapshot', server: server
		  buildInfo = Artifactory.newBuildInfo()
		  rtMaven.deployer releaseRepo: 'libs-release-local', snapshotRepo: 'libs-snapshot', server: server
          buildInfo.env.capture = true
        }			                      
      }
    }
    stage('Execute_Maven') {
	  steps {
	    script {
		  rtMaven.run pom: 'pom.xml', goals: 'clean install', buildInfo: buildInfo
        }			                      
      }
    }	
    stage('SonarQube_Analysis') {
      steps {
	    script {
          scannerHome = tool 'sonar-scanner'
        }
        withSonarQubeEnv('sonar') {
      	  sh """${scannerHome}/bin/sonar-scanner"""
        }
      }	
    }	
	stage('Quality_Gate') {
	  steps {
	    timeout(time: 3, unit: 'MINUTES') {
		  waitForQualityGate abortPipeline: true
        }
      }
    }
    stage('Build Docker Image'){
      steps {
        sh 'docker build . -t dileep95/spring:${DOCKER_TAG}'
        }
      }  
     stage('Docker Push'){
       steps{
       withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'docker_pass', usernameVariable: 'docker_user')]) {
       	  sh 'docker login -u ${docker_user} -p ${docker_pass}'
          sh 'docker push dileep95/spring:${DOCKER_TAG}'
        }
      }
    }    	
    stage('ssh'){
	steps{
              sh "chmod +x replace.sh"
	      sh "./replace.sh ${DOCKER_TAG}"
                sshagent(['k8s']) {	      
		   sh "scp -o StrictHostKeyChecking=no services.yml changed-pod.yml services.yml prithdileep@104.154.78.159:/home/prithdileep"
		script{
			sh "ssh prithdileep@104.154.78.159 kubectl delete all --all"
		try{
		  sh "ssh prithdileep@104.154.78.159 kubectl create -f ."
		  }
		catch(error){
		sh "ssh prithdileep@104.154.78.159 kubectl apply -f ."
            }
        }
    }
   }
  } 
	}
post {
    always {
sh 'echo "This will always run"'
mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br>URL: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "Success: Project name -> ${env.JOB_NAME}", to: "prithdileep@gmail.com";
    }
    failure {
sh 'echo "This will run only if failed"'
      mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br>URL: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "ERROR: Project name -> ${env.JOB_NAME}", to: "prithdileep@gmail.com";
    }
  }
}
