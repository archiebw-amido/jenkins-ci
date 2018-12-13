FROM jenkins/jenkins:2.154

USER root
RUN apt-get update \
      && apt-get install -y sudo \
      && apt-get install -y sudo libltdl-dev \
      && apt-get install -y python \
      && apt-get install -y python-pip

RUN pip install awscli

USER jenkins
RUN /usr/local/bin/install-plugins.sh azure-ad configuration-as-code configuration-as-code-support ec2 git \
workflow-aggregator slack job-dsl docker-workflow \
> /usr/share/jenkins/ref/plugins.txt

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
