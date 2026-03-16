# Get the latest Amazon Linux 2 AMI automatically
# This means you always get the most recent patched version
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template
# Blueprint for every EC2 instance the ASG launches
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = "zamweather-key"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.app_sg_id]
  }

  # User data script - runs on every instance at boot
  # templatefile() reads the script and substitutes variables
  user_data = base64encode(templatefile("${path.root}/app/user_data.sh", {
    db_host     = var.db_host
    db_user     = var.db_user
    db_password = var.db_password
    db_name     = var.db_name
    api_key     = var.api_key
  }))

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project_name}-app-server" }
  }
}

# Auto Scaling Group
# Manages the fleet of EC2 instances
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = [var.public_subnet_1_id, var.public_subnet_2_id]

  # Connect ASG to ALB target group
  target_group_arns = [var.target_group_arn]

  # Use ELB health checks so ASG replaces
  # instances the ALB marks as unhealthy
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-server"
    propagate_at_launch = true
  }
}
