resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "GlueS3Policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }]
  })
}

resource "aws_security_group" "glue_sg" {
  name   = "${var.project_name}-glue-sg"
  vpc_id = var.vpc_id


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_subnet" "selected" {
  id = var.private_subnet_id
}


resource "aws_glue_connection" "rds_connection" {
  name = "${var.project_name}-rds-connection"
  
  connection_properties = {
    "JDBC_CONNECTION_URL" = "jdbc:mysql://${var.db_endpoint}:3306/chinook"
    "USERNAME"            = var.db_username
    "PASSWORD"            = var.db_password
  }
  
  connection_type = "JDBC"

  physical_connection_requirements {
    availability_zone = data.aws_subnet.selected.availability_zone
    security_group_id_list = [aws_security_group.glue_sg.id]
    subnet_id              = var.private_subnet_id
  }
}


resource "aws_glue_job" "extract_job" {
  name     = "${var.project_name}-extract-job"
  role_arn = aws_iam_role.glue_role.arn

 
  glue_version      = "4.0"
  worker_type       = "G.1X"  
  connections = [aws_glue_connection.rds_connection.name]
  number_of_workers = 2        

  max_retries       = 0      

  timeout           = 20

  command {
    name            = "glueetl"
    script_location = "s3://${var.bucket_name}/scripts/glue_extract.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"   = "python"
    "--TempDir"        = "s3://${var.bucket_name}/chinook/"
    "--DB_HOST"        = var.db_endpoint
    "--DB_USER"        = var.db_username
    "--DB_PASSWORD"    = var.db_password
    "--S3_BUCKET"      = var.bucket_name
  }
}