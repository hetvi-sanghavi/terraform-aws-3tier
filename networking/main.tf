# --- networking/main.tf ---
#This is the first module we will want to compose. It will contain the VPC, subnets, internet gateway, route tables, NAT gateways, security groups, and database subnet group. I will break it down into sections. First, we will create the VPC using the random integer resource to supply our VPC with a unique name. A data block to refer to our availability zones, and Internet Gateway follow.
### CUSTOM VPC CONFIGURATION

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "three_tier_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "three_tier_vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "available" {
}

### INTERNET GATEWAY

resource "aws_internet_gateway" "three_tier_internet_gateway" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "three_tier_igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}

#Next up we will create the public subnets using a count variable to control the number we want. We will set up the cidr_block so that the subnets can exist within the specified VPC cidr range. The public subnet route table will route to the internet gateway. We will also create the NAT gateway that will connect with our private instances.


### PUBLIC SUBNETS (WEB TIER) AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "three_tier_public_subnets" {
  count                   = length(var.public_sn_cidr)
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.public_sn_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_public_${count.index + 1}"
  }
}

resource "aws_route_table" "three_tier_public_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "three_tier_public"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.three_tier_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.three_tier_internet_gateway.id
}

resource "aws_route_table_association" "three_tier_public_assoc" {
  count          = length(var.public_sn_cidr)
  subnet_id      = aws_subnet.three_tier_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.three_tier_public_rt.id
}


### EIP AND NAT GATEWAY

resource "aws_eip" "three_tier_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "three_tier_ngw" {
  allocation_id = aws_eip.three_tier_nat_eip.id
  subnet_id     = aws_subnet.three_tier_public_subnets[1].id
}

#We will create the private subnets next that will reside in the application tier and database tier. Here will will associate a private route table with the NAT Gateway.

### PRIVATE SUBNETS (APP TIER & DATABASE TIER) AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "three_tier_private_subnets" {
  count                   = length(var.private_sn_cidr)
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.private_sn_cidr[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_private_${count.index + 1}"
  }
}

resource "aws_route_table" "three_tier_private_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "three_tier_private"
  }
}

resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.three_tier_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.three_tier_ngw.id
}


resource "aws_route_table_association" "three_tier_private_assoc" {
  count          = length(var.private_sn_cidr)
  route_table_id = aws_route_table.three_tier_private_rt.id
  subnet_id      = aws_subnet.three_tier_private_subnets.*.id[count.index]
}


resource "aws_subnet" "three_tier_private_subnets_db" {
  count                   = length(var.private_sn_cidr_db)
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.private_sn_cidr_db[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_private_db${count.index + 1}"
  }
}

#For the last part of the main.tf networking file, we will make security groups (sg) to allow proper permissions for each level. The bastion sg will allow you to connect to the bastion EC2 instance. Ideally, you would set the access_ip variable to your IP address. I have set it to allow any IP address, but that is not most secure. We have the load balancer sg, frontend app sg, backend app sg, and database sg. The description in each block tells us their purpose. I have also thrown in a database subnet group so that we can add it to our database subnets we created earlier.


### SECURITY GROUPS

resource "aws_security_group" "three_tier_bastion_sg" {
  name        = "three_tier_bastion_sg"
  description = "Allow SSH Inbound Traffic From Set IP"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "three_tier_lb_sg" {
  name        = "three_tier_lb_sg"
  description = "Allow Inbound HTTP Traffic"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_frontend_app_sg" {
  name        = "three_tier_frontend_app_sg"
  description = "Allow SSH inbound traffic from Bastion, and HTTP inbound traffic from loadbalancer"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_backend_app_sg" {
  name        = "three_tier_backend_app_sg"
  vpc_id      = aws_vpc.three_tier_vpc.id
  description = "Allow Inbound HTTP from FRONTEND APP, and SSH inbound traffic from Bastion"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_frontend_app_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_rds_sg" {
  name        = "three-tier_rds_sg"
  description = "Allow MySQL Port Inbound Traffic from Backend App Security Group"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_backend_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### DATABASE SUBNET GROUP

resource "aws_db_subnet_group" "three_tier_rds_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "three_tier_rds_subnetgroup"
  subnet_ids = [aws_subnet.three_tier_private_subnets_db[0].id, aws_subnet.three_tier_private_subnets_db[1].id]

  tags = {
    Name = "three_tier_rds_sng"
  }
}