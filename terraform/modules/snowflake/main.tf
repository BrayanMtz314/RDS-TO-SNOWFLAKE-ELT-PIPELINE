terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.0"
    }
  }
}

locals {
  sf_name = upper(replace(var.project_name, "-", "_"))
}



resource "aws_iam_policy" "s3_snowflake_policy" {
  name = "${var.project_name}-s3-snowflake-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/raw_data/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}"
        Condition = {
          StringLike = {
            "s3:prefix" = ["raw_data/", "raw_data/*"]
          }
        }
      }
    ]
  })
}


# 2. Tu rol de IAM modificado
resource "aws_iam_role" "s3_snowflake_role" {
  name = "${var.project_name}-s3-snowflake-role"

  # Si las variables tienen datos, aplicamos la política de Snowflake. 
  # Si están vacías (primera ejecución), aplicamos una política temporal.
  assume_role_policy = var.snowflake_iam_user_arn != "" ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.snowflake_iam_user_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.snowflake_external_id
          }
        }
      }
    ]
  }) : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "${var.account_id}" 
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}




resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.s3_snowflake_role.name
  policy_arn = aws_iam_policy.s3_snowflake_policy.arn
}


resource "snowflake_storage_integration" "s3_int" {
  name    = "${local.sf_name}_S3_INT"
  type    = "EXTERNAL_STAGE"
  enabled = true

  storage_provider     = "S3"
  storage_aws_role_arn = aws_iam_role.s3_snowflake_role.arn

  storage_allowed_locations = [
    "s3://${var.bucket_name}/raw_data/"
  ]
}


resource "snowflake_database" "my_db" {
  name    = "${local.sf_name}_DB"
  comment = "DATASET PIPELINE"
}

resource "snowflake_schema" "public_schema" {
  database = snowflake_database.my_db.name
  name     = "${local.sf_name}_SCHEMA"
  comment  = "public schema to stage and tables"
}


resource "snowflake_file_format" "parquet_format" {
  name     = "${local.sf_name}_PARQUET_FORMAT"
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name

  format_type = "PARQUET"
}

resource "snowflake_stage" "my_s3_stage" {
  name                = "${local.sf_name}_STAGE"
  database            = snowflake_database.my_db.name
  schema              = snowflake_schema.public_schema.name
  url                 = "s3://${var.bucket_name}/raw_data/"
  storage_integration = snowflake_storage_integration.s3_int.name
  file_format         = "FORMAT_NAME = ${snowflake_file_format.parquet_format.fully_qualified_name}"
}


# --------------- Table definitions ----------------

locals {
  tables = [
    "ALBUM", "ARTIST", "CUSTOMER", "EMPLOYEE", "GENRE", 
    "INVOICE", "INVOICE_LINE", "MEDIA_TYPE", "PLAYLIST", 
    "PLAYLIST_TRACK", "TRACK"
  ]
}

# --- ALBUM ---
resource "snowflake_table" "Album" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "ALBUM"

  column { 
    name = "ALBUM_ID" 
    type = "NUMBER" 
    nullable = false 
  }

  column { 
    name = "TITLE" 
    type = "VARCHAR(160)"
    nullable = true 
  }
  column { 
    name = "ARTIST_ID"
    type = "NUMBER" 
    nullable = true 
  }
}

resource "snowflake_table_constraint" "pk_album" {
  name     = "PK_ALBUM"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Album.fully_qualified_name
  columns  = ["ALBUM_ID"]
}

# --- ARTIST ---
resource "snowflake_table" "Artist" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "ARTIST"

  column { 
    name = "ARTIST_ID" 
    type = "NUMBER"
    nullable = false 
  }
  
  column { 
    name = "NAME" 
    type = "VARCHAR(120)"
    nullable = true 
  }
}

resource "snowflake_table_constraint" "pk_artist" {
  name     = "PK_ARTIST"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Artist.fully_qualified_name
  columns  = ["ARTIST_ID"]
}

# --- CUSTOMER ---
resource "snowflake_table" "Customer" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "CUSTOMER"

  column { 
    name = "CUSTOMER_ID" 
    type = "NUMBER"
    nullable = false 
  }
  
  column { 
    name = "FIRST_NAME"
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "LAST_NAME"
    type = "VARCHAR(20)"
    nullable = true 
  }

  column { 
    name = "COMPANY" 
    type = "VARCHAR(80)"
    nullable = true 
  }

  column { 
    name = "ADDRESS" 
    type = "VARCHAR(70)"
    nullable = true
  }

  column { 
    name = "CITY" 
    type = "VARCHAR(40)" 
    nullable = true 
  }

  column { 
    name = "STATE"
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "COUNTRY"
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "POSTAL_CODE"
    type = "VARCHAR(10)"
    nullable = true 
  }

  column { 
    name = "PHONE"
    type = "VARCHAR(24)" 
    nullable = true 
  }

  column { 
    name = "FAX" 
    type = "VARCHAR(24)"
    nullable = true 
  }

  column { 
    name = "EMAIL"  
    type = "VARCHAR(60)"
    nullable = true 
  }

  column { 
    name = "SUPPORT_REP_ID"
    type = "NUMBER" 
    nullable = true 
  }
}

resource "snowflake_table_constraint" "pk_customer" {
  name     = "PK_CUSTOMER"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Customer.fully_qualified_name
  columns  = ["CUSTOMER_ID"]
}

# --- EMPLOYEE ---
resource "snowflake_table" "Employee" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "EMPLOYEE"

  column { 
    name = "EMPLOYEE_ID" 
    type = "NUMBER" 
    nullable = false 
  }

  column { 
    name = "LAST_NAME" 
    type = "VARCHAR(20)" 
    nullable = true 
  }

  column { 
    name = "FIRST_NAME" 
    type = "VARCHAR(20)"
    nullable = true 
  }

  column { 
    name = "TITLE" 
    type = "VARCHAR(30)"
    nullable = true
  }

  column { 
    name = "REPORTS_TO" 
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "BIRTH_DATE" 
    type = "TIMESTAMP_NTZ"
    nullable = true
  }

  column { 
    name = "HIRE_DATE" 
    type = "TIMESTAMP_NTZ"
    nullable = true
  }

  column { 
    name = "ADDRESS" 
    type = "VARCHAR(70)"
    nullable = true 
  }

  column { 
    name = "CITY" 
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "STATE" 
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "COUNTRY" 
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "POSTAL_CODE" 
    type = "VARCHAR(10)"
    nullable = true 
  }

  column { 
    name = "PHONE" 
    type = "VARCHAR(24)"
    nullable = true 
  }

  column { 
    name = "FAX" 
    type = "VARCHAR(24)"
    nullable = true 
  }

  column { 
    name = "EMAIL" 
    type = "VARCHAR(60)"
    nullable = true 
  }

}

resource "snowflake_table_constraint" "pk_employee" {
  name     = "PK_EMPLOYEE"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Employee.fully_qualified_name
  columns  = ["EMPLOYEE_ID"]
}

# --- INVOICE ---
resource "snowflake_table" "Invoice" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "INVOICE"

  column { 
    name = "INVOICE_ID" 
    type = "NUMBER"
    nullable = false
  }

  column { 
    name = "CUSTOMER_ID" 
    type = "NUMBER"
    nullable = true
  }

  column { 
    name = "INVOICE_DATE" 
    type = "TIMESTAMP_NTZ"
    nullable = true 
  }

  column { 
    name = "BILLING_ADDRESS" 
    type = "VARCHAR(70)"
    nullable = true 
  }

  column { 
    name = "BILLING_CITY" 
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "BILLING_STATE" 
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "BILLING_COUNTRY" 
    type = "VARCHAR(40)"
    nullable = true 
  }

  column { 
    name = "BILLING_POSTAL_CODE" 
    type = "VARCHAR(10)"
    nullable = true 
  }

  column { 
    name = "TOTAL" 
    type = "NUMBER(10,2)" 
    nullable = true 
  }
}

resource "snowflake_table_constraint" "pk_invoice" {
  name     = "PK_INVOICE"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Invoice.fully_qualified_name
  columns  = ["INVOICE_ID"]
}

# --- INVOICE_LINE ---
resource "snowflake_table" "InvoiceLine" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "INVOICE_LINE"

  column { 
    name = "INVOICE_LINE_ID"
    type = "NUMBER" 
    nullable = false 
  }

  column { 
    name = "INVOICE_ID"
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "TRACK_ID"
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "UNIT_PRICE"
    type = "NUMBER(10,2)"
    nullable = true 
  }

  column { 
    name = "QUANTITY"
    type = "NUMBER" 
    nullable = true 
  }

}

resource "snowflake_table_constraint" "pk_invoice_line" {
  name     = "PK_INVOICE_LINE"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.InvoiceLine.fully_qualified_name
  columns  = ["INVOICE_LINE_ID"]
}

# --- TRACK ---
resource "snowflake_table" "Track" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "TRACK"

  column { 
    name = "TRACK_ID"
    type = "NUMBER" 
    nullable = false 
  }

  column { 
    name = "NAME"
    type = "VARCHAR(200)" 
    nullable = true 
  }

  column { 
    name = "ALBUM_ID"
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "MEDIA_TYPE_ID"
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "GENRE_ID"
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "COMPOSER"
    type = "VARCHAR(220)"
    nullable = true 
  }

  column { 
    name = "MILLISECONDS"
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "BYTES"
    type = "NUMBER" 
    nullable = true 
  }

  column { 
    name = "UNIT_PRICE"
    type = "NUMBER(10,2)"
    nullable = true 
  }
}

resource "snowflake_table_constraint" "pk_track" {
  name     = "PK_TRACK"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Track.fully_qualified_name
  columns  = ["TRACK_ID"]
}

# --- PLAYLIST_TRACK (PK Compuesta) ---
resource "snowflake_table" "PlaylistTrack" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.public_schema.name
  name     = "PLAYLIST_TRACK"

  column { 
    name = "PLAYLIST_ID"
    type = "NUMBER"
    nullable = false
  }

  column { 
    name = "TRACK_ID"
    type = "NUMBER"
    nullable = false
  }

}

resource "snowflake_table_constraint" "pk_playlist_track" {
  name     = "PK_PLAYLIST_TRACK"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.PlaylistTrack.fully_qualified_name
  columns  = ["PLAYLIST_ID", "TRACK_ID"]
}

# ---------- GENRE ---------------
resource "snowflake_table" "Genre" {
  database = snowflake_database.my_db.name
  schema = snowflake_schema.public_schema.name
  name = "GENRE"

  column {
    name = "GENRE_ID"
    type = "NUMBER"
    nullable = false
  }

  column {
    name = "NAME"
    type = "VARCHAR(80)"
    nullable = true
  }
}

resource "snowflake_table_constraint" "pk_genre" {
  name     = "PK_GENRE"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Genre.fully_qualified_name
  columns  = ["GENRE_ID"]
}


# ----------- MEDIA_TYPE --------------
resource "snowflake_table" "MediaType" {
  database = snowflake_database.my_db.name
  schema = snowflake_schema.public_schema.name
  name = "MEDIA_TYPE"

  column {
    name = "MEDIA_TYPE_ID"
    type = "NUMBER"
    nullable = false
  }

  column {
    name = "NAME"
    type = "VARCHAR(120)"
    nullable = true
  }
}

resource "snowflake_table_constraint" "pk_media_type" {
  name     = "PK_MEDIA_TYPE"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.MediaType.fully_qualified_name
  columns  = ["MEDIA_TYPE_ID"]
}

# ----------- PLAYLIST --------------
resource "snowflake_table" "Playlist" {
  database = snowflake_database.my_db.name
  schema = snowflake_schema.public_schema.name
  name = "PLAYLIST"

  column {
    name = "PLAYLIST_ID"
    type = "NUMBER"
    nullable = false
  }

  column {
    name = "NAME"
    type = "VARCHAR(120)"
    nullable = true
  }
}

resource "snowflake_table_constraint" "pk_playlist" {
  name     = "pk_playlist"
  type     = "PRIMARY KEY"
  table_id = snowflake_table.Playlist.fully_qualified_name
  columns  = ["PLAYLIST_ID"]
}




