Simple Java Maven Project developed in Jenkins Declarative Pipeline



DevOps Tools used

Pipeline CI/CD - GitHub, Maven, Jenkins, Artifactory, SonarQube, Docker, Tomcat, [Kubernetes Deploy through SSH Agent]


Kubernetes Resources Used - Pods and Services


Access to the tomcat after successfully deploying: 

Ex: http://35.65.45.127:30035/webapp/

Note: In the service.yml, I have mentioned nodePort to 30035

Format: http://<aws_ip>:<nodePort_of_Kubernetes>/webapp/

Note: Tomcat was made to access in the port 8090. It was changed in the Dockerfile's RUN command.
