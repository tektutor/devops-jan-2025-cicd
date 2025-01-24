provider "aws" {
}

locals {
	vpc_id 		= aws_vpc.tektutor_vpc.id
	subnet_id	= aws_subnet.tektutor_subnet_1.id
	ssh_user	= "ubuntu"
	key_name	= var.key_name
	private_key_path= "./${var.key_name}.pem"
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
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
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

# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami                         = "ami-019d9dc96246b7eb9" 
  instance_type               = "t2-small" 
  key_name = var.key_name
	
  network_interface {
 	network_interface_id = aws_network_interface.tektutor_nic.id
    	device_index         = 0
  }

  tags = {
	Name = "${var.resource_name_prefix}-windows"
  }

}
