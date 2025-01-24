# Day 4

## Installing Terraform in Ubuntu
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform
terraform -install-autocomplete
```

Checking terraform installation
```
terraform -version
```

## Info - Terraform commands
<pre>
terraform init - initializes the current directory
terraform refresh - refreshes the state file
terraform output - views Terraform outputs
terraform apply - applies the Terraform code and builds stuff
terraform destroy - destroys what has been built by Terraform
terraform graph - creates a DOT-formatted graph
terraform plan - a dry run to see what Terraform will do
</pre>

## Lab - Write your first terraform script

We need to create a folder to keep the terraform scripts
```
cd ~
mkdir -p create-docker-container
cd create-docker-container
```

Create a file name main.tf with the below content
```
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"

  ports {
    internal = 80
    external = 8000
  }
}
```

Next, we need to download the terraform docker_image provider 
```
terraform init
```

Next, we can run the terraform script
```
terraform apply
```

Now check if the containers are created
```
docker ps
```

Once you are done with the lab exercise, you can cleanup/discard the resources created by Terraform 
```
terraform destroy
```

Expected output
![image](https://github.com/user-attachments/assets/f0a706d1-b4cf-495f-ac7d-d338bbacffea)
![image](https://github.com/user-attachments/assets/fd61166a-c26a-4c03-bcbe-18709b0f7cb9)
![image](https://github.com/user-attachments/assets/0e16a024-c8e5-4740-8183-a42158945589)
![image](https://github.com/user-attachments/assets/328f9615-2369-4cc1-9506-ea902d73d7b3)
![image](https://github.com/user-attachments/assets/334c2a60-d910-44bd-a602-bf2921b6928c)

## Lab - Provisioning AWS ec2 instance via Terraform

We need to first export the AWS Access key and respective secret key
```
export AWS_ACCESS_KEY_ID="your-aws-access-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"
export AWS_REGION="ap-south-1"
```
Then create a folder 
```
mkdir -p ~/create-ec2-instance
```

Create a file name main.tf with the below code
```

provider "aws" {
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "./terraform.pem"
  content = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

locals {
	vpc_id 		= aws_vpc.tektutor_vpc.id
	subnet_id	= aws_subnet.tektutor_subnet_1.id
	ssh_user	= "ubuntu"
	key_name	= "terraform"
	private_key_path= "./terraform.pem"
}

resource "aws_vpc" "tektutor_vpc" {
	cidr_block = "192.168.0.0/16"
  	enable_dns_hostnames = true
  	enable_dns_support = true
	
	tags = {
		Name = "tektutor_vpc"
	}
}

resource "aws_security_group" "tektutor_security_group" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.tektutor_vpc.id

  ingress {
    description      = "https incoming requests"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http incoming requests"
    from_port        = 80 
    to_port          = 80 
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "All ICMP"
    from_port        = -1 
    to_port          = -1 
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22 
    to_port          = 22 
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_internet_gateway" "tektutor_internet_gateway" {
	vpc_id = aws_vpc.tektutor_vpc.id
	tags = {
		Name = "tektutor_internet_gateway"
	}
}

resource "aws_route_table" "tektutor_route_table" {
	vpc_id = aws_vpc.tektutor_vpc.id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.tektutor_internet_gateway.id
	}

	tags = {
		Name = "tektutor_route_table"
	}
}

resource "aws_route_table_association" "tektutor_route_table_association" {
	subnet_id = aws_subnet.tektutor_subnet_1.id
	route_table_id = aws_route_table.tektutor_route_table.id
}

resource "aws_subnet" "tektutor_subnet_1" {
	vpc_id = aws_vpc.tektutor_vpc.id
	cidr_block = "192.168.1.0/24"
  	availability_zone = "ap-south-1a"
  	map_public_ip_on_launch = "true"

	tags = {
		Name = "tektutor_subnet_1"
	}
}

resource "aws_network_interface" "tektutor_nic" {
	subnet_id  = aws_subnet.tektutor_subnet_1.id
	private_ips = ["192.168.1.100"] 

        security_groups = [aws_security_group.tektutor_security_group.id]	
	tags = {
		Name = "Primary Network Interface"
	}
}


resource "aws_instance" "ubuntu1" {
	ami = "ami-0026b1df9711a8567"
	instance_type = "t2.micro"
	key_name = "terraform"
	
	network_interface {
    		network_interface_id = aws_network_interface.tektutor_nic.id
    		device_index         = 0
  	}

	//user_data = file("install_apache.sh")

        provisioner "remote-exec" {
		inline = ["echo 'Waiting for ec2 for it is getting booted'"]
	    connection {
		type = "ssh"
		user = "${local.ssh_user}"
		private_key = file(local.private_key_path)
		host = aws_instance.ubuntu1.public_ip
	    }
        }

	provisioner "local-exec" {
		command = "ansible-playbook -i ${aws_instance.ubuntu1.public_ip}, --private-key ${local.private_key_path} install-tmux-playbook.yml" 
	}

	tags = {
		Name = "ubuntu1"
	}
}
```

Let's run the terraform script
```
terraform init
terraform apply 
```

Expected output
![image](https://github.com/user-attachments/assets/2e01bbe2-f3eb-4f5f-ba4a-d4b25287552f)
