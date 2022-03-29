resource "aws_key_pair" "terraform-keys" {
  key_name = "terraform-keys"
  public_key = "${file("${path.module}/ec2_id_ed25519.pub")}"
}

resource "aws_instance" "web" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = "terraform-keys"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]
  user_data = "${file("apache_mod.txt")}"
  tags = {
    Name = "akamai_web_instance"
  }
  volume_tags = {
    Name = "akamai_web_instance"
  }
}
