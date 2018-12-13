# Improvements
- Ansible ec2 instance for orchestration
- Modulalarise terraform
- Secret handling for ansible/jenkins. (eg. AD)
- Dynamic variables
- Terraform AD in azure [https://wiki.jenkins.io/display/JENKINS/Azure+AD+Plugin]
- AD need admin account to complete - authentication not turned on
- DNS for jenkins
- Dynamically load choice of jenkins plugins - add to Dockerfile and config to jenkins.yaml


#JCasC tips
- Check for examples on official github
[https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos]

- Check java files for plugin to find variables [https://github.com/jenkinsci/slack-plugin/blob/master/src/main/java/jenkins/plugins/slack/SlackNotifier.java]

- Check plugin page java code 
[https://wiki.jenkins.io/display/JENKINS/Amazon+EC2+Plugin]


# Provision steps
cd .\jenkins-ci\provisioning\
terraform init
terraform apply

# orchestrate (using linux subsystem) - copy files for ansible
- install ansible
- sudo cp /mnt/c/dev/jenkins/jenkins-ci/orchestration/ansible/abw-default.pem /home/archie/abw-default.pem
- sudo cp /mnt/c/dev/jenkins/jenkins-ci/orchestration/ansible/hosts /etc/ansible/hosts
- ansible-playbook /mnt/c/dev/jenkins/jenkins-ci/orchestration/ansible/main.yml