

locals {
  cidr_block = "10.0.0.0/16"
  subnet_count = "${length(var.availability_zones)}"
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  attributes = "${var.attributes}"
}

terraform {
  backend "s3" {
    bucket = "abw-terraform-state"
    key = "state/"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
  version = "1.49.0"
}

resource "aws_vpc" "default" {
  cidr_block = "${local.cidr_block}"
  tags       = "${module.label.tags}"

}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags   = "${module.label.tags}"
}

resource "aws_subnet" "default" {
  count             = 1
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  cidr_block        = "${cidrsubnet(local.cidr_block, 8, count.index)}"
  tags              = "${module.label.tags}"
}

resource "aws_route" "default" {
  route_table_id            = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.default.id}"
}

resource "aws_security_group" "default" {
  name        = "tf-public-sg"
  description = "Allow incoming SSH and HTTP, all outgoing traffic"
  vpc_id      = "${aws_vpc.default.id}"
  tags        = "${module.label.tags}"
  

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "85.92.217.166/32",
      "81.20.51.2/32"
    ]
  }

  # HTTP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [
      "85.92.217.166/32",
      "81.20.51.2/32"
    ]
  }

  # Outbound Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

data "template_file" "jenkins_userdata" {
  template = "${file("userdata.tpl")}"
}

resource "aws_iam_user" "jenkins" {
  name = "jenkins-ec2-plugin"
  tags = "${module.label.tags}"
}

resource "aws_iam_access_key" "jenkins" {
  user = "${aws_iam_user.jenkins.name}"
}

resource "aws_iam_user_policy" "jenkins" {
  name = "Jenkins-ec2-plugin"
  user = "${aws_iam_user.jenkins.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*",
        "iam:ListInstanceProfilesForRole",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_instance" "jenkins-ec2" {
  ami                         = "ami-0307e8ce88a8245d4"
  instance_type               = "t2.micro"
  key_name                    = "abw-default"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.default.id}"
  source_dest_check           = false
  tags                        = "${module.label.tags}"
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  depends_on = ["aws_internet_gateway.default"]

  /*
  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_type = "standard"
    volume_size = "100"
    delete_on_termination = "false"
  }
  */
}

/*
resource "aws_instance" "ansible-ec2" {
  ami                         = "ami-0307e8ce88a8245d4"
  instance_type               = "t2.micro"
  key_name                    = "abw-default"
  subnet_id                   = "${aws_subnet.default.id}"
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${data.template_file.jenkins_userdata.rendered}"
  tags                        = "${module.label.tags}"
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  depends_on = ["aws_internet_gateway.default"]
}
*/
