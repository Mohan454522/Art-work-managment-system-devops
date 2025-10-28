# Create a security group allowing inbound port 5000 and SSH (22)
resource "aws_security_group" "lostfound_sg" {
  name        = "lostfound-sg"
  description = "Allow HTTP 5000 and SSH"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# IAM role / policy for EC2 to pull from ECR (allows GetAuthorizationToken and Pull)
resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "attach_ecr_pull" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_instance" "lostfound_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.lostfound_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # optional keypair
  dynamic "key_name" {
    for_each = var.key_name == "" ? [] : [var.key_name]
    content {
      key_name = key_name.value
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io awscli
              systemctl enable docker
              systemctl start docker
              aws --version
              # login to ECR using instance role (or fallback to awscli if credentials available)
              REGION="${var.aws_region}"
              REPO="${var.ecr_repo}"
              ACCOUNT="${var.aws_account_id}"
              $(aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com) || true
              docker pull ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo}:latest || true
              docker run -d -p 5000:5000 --name lostfound ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo}:latest || true
              EOF

  tags = {
    Name = "LostFoundAppServer"
  }
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-instance-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# Latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
