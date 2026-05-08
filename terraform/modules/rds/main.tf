# 1. Security Group del RDS
resource "aws_security_group" "rds_sg" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.loader_sg.id] 
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.glue_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "loader_sg" {
  name   = "${var.project_name}-loader-sg"
  vpc_id = var.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-loader-sg" }
}


resource "aws_db_instance" "chinook" {
  identifier           = "${var.project_name}-db" 
  engine               = "mysql"
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  db_name              = "chinook"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false 
}

resource "aws_instance" "data_loader" {
  ami           = var.ec2_ami 
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.loader_sg.id]
  iam_instance_profile = aws_iam_instance_profile.loader_profile.name


  user_data = templatefile("${path.root}/scripts/setup_db.tftpl", {
    db_endpoint = aws_db_instance.chinook.address
    db_user     = var.db_username
    db_password = var.db_password
    bucket_name = var.bucket_name
  })

  tags = {
    Name = "${var.project_name}-data-loader"
  }
  depends_on = [aws_db_instance.chinook]
}


resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.loader_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role" "loader_role" {
  name = "${var.project_name}-loader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "s3_read_policy" {
  name = "S3ReadPolicy"
  role = aws_iam_role.loader_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Effect   = "Allow"
      Resource = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
    }]
  })
}

resource "aws_iam_instance_profile" "loader_profile" {
  name = "${var.project_name}-loader-profile"
  role = aws_iam_role.loader_role.name
}

