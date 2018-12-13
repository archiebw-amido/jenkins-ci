output "jenkins-url" {
  value = "http://${aws_instance.jenkins-ec2.public_ip}:8080"
}

output "ssh-jenkins" {
  value =  "ssh -i 'C:\\Users\\Archie Brand\\.ssh\\abw-default.pem' ec2-user@${aws_instance.jenkins-ec2.public_ip}"
}