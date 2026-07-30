resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.key_name

  tags = {
    Name = "${var.env}-web-${count.index}"
    Role = "app-server"
  }
}