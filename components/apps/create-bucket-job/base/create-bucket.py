import boto3, os

s3_endpoint = os.getenv("AWS_S3_ENDPOINT")
bucket_name = os.getenv("AWS_S3_BUCKET")

s3 = boto3.client(
    "s3",
    endpoint_url=s3_endpoint,
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
)
bucket = bucket_name
print("creating " + bucket + " bucket in minio")
if bucket not in [bu["Name"] for bu in s3.list_buckets()["Buckets"]]:
    s3.create_bucket(Bucket=bucket)
