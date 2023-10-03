resource "aws_instance" "inst-main" {
  ami                  = var.AMI[var.REGION]
  instance_type        = "t2.micro"
  availability_zone    = var.ZONE1
  key_name             = "new key"
  security_groups      = [aws_security_group.sg1.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "Instance_main"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.inst-main.id
}

resource "aws_ebs_volume" "ebs_vol" {
  availability_zone = var.ZONE1
  size              = 1
}

resource "aws_security_group" "sg1" {
  name        = "security-group1"
  description = "Security Group with ports 22, 80, and 443"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_s3_bucket" "s3bucket1" {
  bucket = "bucket123unique1"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-read-only-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "s3-read-only-policy"
  description = "Policy to grant read-only access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::bucket123unique1",
          "arn:aws:s3:::bucket123unique1/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read_only_attachment" {
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-s3-readonly-access-instance-profile"
  role = aws_iam_role.ec2_role.name
}
