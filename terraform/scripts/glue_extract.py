import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import re

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'DB_HOST', 'DB_USER', 'DB_PASSWORD', 'S3_BUCKET'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

db_host = args['DB_HOST']
db_user = args['DB_USER']
db_password = args['DB_PASSWORD']
s3_bucket = args['S3_BUCKET']


jdbc_url = f"jdbc:mysql://{db_host}:3306/chinook?useSSL=false&allowPublicKeyRetrieval=true"

    
def to_snake_case(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).upper()

def extract_table_to_s3(table_name):
    print(f"Extrayendo tabla: {table_name}")
    
    df = spark.read \
        .format("jdbc") \
        .option("url", jdbc_url) \
        .option("dbtable", table_name) \
        .option("user", db_user) \
        .option("password", db_password) \
        .option("driver", "com.mysql.cj.jdbc.Driver") \
        .load()
    
    for col_name in df.columns:
        df = df.withColumnRenamed(col_name, to_snake_case(col_name))
    
    s3_path = f"s3://{s3_bucket}/raw_data/{table_name}/"
    df.write.mode("overwrite").parquet(s3_path)
    print(f"Tabla {table_name} guardada en {s3_path}")


tables_to_extract = [
    "Artist", 
    "Album", 
    "Track", 
    "MediaType", 
    "Playlist", 
    "PlaylistTrack", 
    "Genre",
    "InvoiceLine",
    "Invoice",
    "Customer",
    "Employee"
    ]

for table in tables_to_extract:
    extract_table_to_s3(table)

job.commit()