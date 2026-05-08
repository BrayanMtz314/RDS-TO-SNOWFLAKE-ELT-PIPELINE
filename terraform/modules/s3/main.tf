resource "aws_s3_bucket" "data_lake" {
  bucket        = "${var.project_name}-landing-${var.account_id}"
  force_destroy = true 

  tags = { Name = "${var.project_name}-landing" }
}

resource "aws_s3_object" "db_setup_script" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "scripts/Chinook_MySql.sql"
  source = "${path.root}/scripts/Chinook_MySql.sql"
  etag   = filemd5("${path.root}/scripts/Chinook_MySql.sql")
}

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "scripts/glue_extract.py"
  source = "${path.root}/scripts/glue_extract.py"
  etag   = filemd5("${path.root}/scripts/glue_extract.py")
}

