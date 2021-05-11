FROM jenkins/jenkins:2.277.4-slim

ENV CASC_JENKINS_CONFIG=/etc/jenkins_casc/
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt --verbose

COPY jenkins.yml /etc/jenkins_casc/