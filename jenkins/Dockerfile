FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo libltdl-dev
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
EXPOSE 8080
USER jenkins
