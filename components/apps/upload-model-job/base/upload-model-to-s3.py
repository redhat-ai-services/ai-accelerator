import os

import botocore
import boto3

bucket_name = os.getenv("AWS_S3_BUCKET")
aws_access_key_id = os.environ.get("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.environ.get("AWS_SECRET_ACCESS_KEY")
endpoint_url = os.getenv("AWS_S3_ENDPOINT")
region_name = os.environ.get("AWS_DEFAULT_REGION")

session = boto3.session.Session(
    aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key
)

s3_resource = session.resource(
    "s3",
    config=botocore.client.Config(signature_version="s3v4"),
    endpoint_url=endpoint_url,
    region_name=region_name,
)

bucket = s3_resource.Bucket(bucket_name)

local_directory = os.getenv("MODEL_PATH")
s3_prefix = os.getenv("PREFIX_PATH")

print(f"Attempting to upload files from {local_directory}")
print(os.listdir(local_directory))

print("Uploading to s3: ")
for root, dirs, files in os.walk(local_directory):
    for filename in files:
        file_path = os.path.join(root, filename)
        relative_path = os.path.relpath(file_path, local_directory)
        if ".git" in relative_path:
            continue
        s3_key = os.path.join(s3_prefix, relative_path)
        print(f"{file_path} -> {s3_key}")
        bucket.upload_file(file_path, s3_key)

prefix = os.getenv("PREFIX_PATH")
filter = bucket.objects.filter(Prefix=prefix)
print("Listing Objects: ")
for obj in filter.all():
    print(obj.key)
print("done")
