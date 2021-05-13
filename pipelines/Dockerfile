FROM jenkins/jenkins:2.277.4-slim

ENV CASC_JENKINS_CONFIG=/etc/jenkins_casc/
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false

USER root

RUN apt update && \
    apt install -y apt-transport-https ca-certificates curl gnupg && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian buster stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && \
    apt install -y docker-ce docker-ce-cli containerd.io && \
    usermod -aG docker jenkins

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt --verbose

COPY jenkins.yml /etc/jenkins_casc/