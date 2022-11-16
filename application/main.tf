# --- application/main.tf ---

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
}
resource "aws_iam_instance_profile" "ec2-profile" {
  name = var.instance_profile
  role = aws_iam_role.ec2-role.name
}
resource "aws_instance" "web_instance" {
  ami                    = data.aws_ami.linux.id
  instance_type          = var.web_instance
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [var.web_sg]
  subnet_id              = var.private_subnet
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile.name
  user_data = data.template_file.user_data.rendered
  # root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = var.kms_key_id      
    delete_on_termination = true
  }
  tags = {
    Name = var.ec2_tags
  }
}


