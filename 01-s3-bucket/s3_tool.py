import logging
import os

import boto3
from botocore.exceptions import ClientError

defined_bucket = "tf-test-maxi-2026"
s3_client = boto3.client("s3")
logger = logging.getLogger()


def upload_file(file_name, bucket, object_name=None, metadata=None):
    if object_name is None:
        object_name = os.path.basename(file_name)

    try:
        s3_client.upload_file(
            file_name,
            bucket,
            object_name,
            ExtraArgs={"ServerSideEncryption": "AES256", "Metadata": metadata},
        )
    except ClientError as e:
        logger.error(e)
        return False
    return True


def get_pages_and_files(bucket):
    paginator = s3_client.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, PaginationConfig={"PageSize": 1}):
        print("-------")
        for obj in page.get("Contents", []):
            url = s3_client.generate_presigned_url(
                "get_object",
                Params={"Bucket": bucket, "Key": obj["Key"]},
                ExpiresIn=3600,
            )
            print(obj["Key"], url)


if __name__ == "__main__":
    get_pages_and_files(defined_bucket)
