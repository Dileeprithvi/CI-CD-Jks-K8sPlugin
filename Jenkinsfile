pipeline {

  agent any

  stages {
    
      stage("Build image") {
            steps {
                script {
                    myapp = docker.build("dileep95/hellowhale:${env.BUILD_ID}")
                }
            }
        }
    
      stage("Push image") {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker') {
                            myapp.push("latest")
                            myapp.push("${env.BUILD_ID}")
                    }
                }
            }
        }

    
    //stage('Deploy App') {
     // steps{
   // script{
        //  kubernetesDeploy(configs: "hellowhale.yml", kubeconfigId: "/var/lib/jenkins/workspace/.kube/config")
      //  }
 // }
    //  }
    
    stage('Deploy App') {
     steps{
       kubernetesDeploy configs: 'hellowhale.yml', kubeConfig: [path: '/var/lib/jenkins/workspace/vsdvsv/config'], kubeconfigId: '', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']
     }
    }

  }

}
