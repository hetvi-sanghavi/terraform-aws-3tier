#We will now head over to the compute module. For our main.tf file, we will obtain the latest AMI using the AWS SSM parameter store. Next, to be able to access our Bastion host, we will need a key pair.
# --- compute/main.tf ---

//Generate RSA key
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}
//Save private key file for instance login
resource "local_file" "private_file" {
  filename        = "id_rsa.pem"
  content         = tls_private_key.private_key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
  tags = {
    Name = "key_pair"
  }
}

#Now we will create our auto scaling groups in the private subnets. We will attach our scripts to the appropriate group. The bastion auto scaling group could be set as a single instance, but we will create an autoscaling group because a failed host will be replaced automatically if EC2 health checks are failed. Finally we will attach the frontend group to the internet facing load balancer.


# LATEST AMI FROM PARAMETER STORE

data "aws_ssm_parameter" "three-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BASTION

resource "aws_launch_template" "three_tier_bastion" {
  name_prefix            = "three_tier_bastion"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [var.bastion_sg]
  key_name               = aws_key_pair.key_pair.key_name

  tags = {
    Name = "three_tier_bastion"
  }
}

resource "aws_autoscaling_group" "three_tier_bastion" {
  name                = "three_tier_bastion"
  vpc_zone_identifier = var.public_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_bastion.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR FRONTEND APP TIER

resource "aws_launch_template" "three_tier_app" {
  name_prefix            = "three_tier_app"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [var.frontend_app_sg]
  user_data              = filebase64("install_apache.sh")
  key_name               = aws_key_pair.key_pair.key_name

  tags = {
    Name = "three_tier_app"
  }
}


resource "aws_autoscaling_group" "three_tier_app" {
  name                = "three_tier_app"
  vpc_zone_identifier = var.private_subnets
  min_size            = 1
  max_size            = 2
  desired_capacity    = 2

  target_group_arns = var.lb_tg

  launch_template {
    id      = aws_launch_template.three_tier_app.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BACKEND

resource "aws_launch_template" "three_tier_backend" {
  name_prefix            = "three_tier_backend"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [var.backend_app_sg]
  key_name               = aws_key_pair.key_pair.key_name
  user_data              = filebase64("install_node.sh")

  tags = {
    Name = "three_tier_backend"
  }
}

resource "aws_autoscaling_group" "three_tier_backend" {
  name                = "three_tier_backend"
  vpc_zone_identifier = var.private_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_backend.id
    version = "$Latest"
  }
}

# AUTOSCALING ATTACHMENT FOR APP TIER TO LOADBALANCER

resource "aws_autoscaling_attachment" "asg_attach" {
  count = length(var.lb_tg)
  autoscaling_group_name = aws_autoscaling_group.three_tier_app.id
  lb_target_group_arn    = var.lb_tg[count.index]
}