# Provider Block

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# Variables

# Create EC2 Instance
resource "aws_instance" "TestInstance1" {
  ami           = "${data.aws_ami.TestAMI.id}"
  instance_type = "${var.instance_type}"
  count = 1
  key_name = "awskey1"
  vpc_security_group_ids  = [
     "${aws_security_group.webSG.id}"
  ]
  tags = {
    Name = "TestInstance1"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
    private_key = "${file("awskey1.pem")}"
  }


# Provisioners File

  provisioner "file" {
    source = "playbook.yaml"
    destination = "/tmp/playbook.yaml"

 }

  # Provisioners - remote-exec
  provisioner "remote-exec" {
  inline = [
    "sudo amazon-linux-extras install ansible2 -y",
    "sleep 10s",
    "sudo ansible-playbook -i localhost /tmp/playbook.yaml",
    "sudo chmod 777 /var/www/html"
  ]

}

 provisioner "file" {
   source = "index.html"
   destination = "/var/www/html/index.html"

 }
 
  }



# Data Source - AMI

data "aws_ami" "TestAMI" {
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-2.0.*" ]
  }
}

# Resources

# Create Security Group
resource "aws_security_group" "webSG" {
  name = "webSG"
  description = "Allo ssh inbound traffic"
  vpc_id = "vpc-0eea5f279f4499112"

  ingress {
    # TLS (Change to whatever ports you need)
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # TLS (Change to whatever ports you need)
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # TLS (Change to whatever ports you need)
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




# Outputs

output "TestInstance1_pub_ip" {
  value = "${aws_instance.TestInstance1.0.public_ip}"
}

output "TestInstance1" {
  value = "${aws_instance.TestInstance1.0.id}"
}