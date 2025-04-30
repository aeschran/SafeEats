import boto3
from botocore.exceptions import NoCredentialsError
import os
import uuid
from core.config import settings

# You should ideally load these from environment variables
 # e.g., 'safeeats-menus'


class S3Client:
    def __init__(self):
        self.s3_client = boto3.client(
            "s3",
            region_name=settings.AWS_REGION,
            aws_access_key_id=settings.AWS_ACCESS_KEY,
            aws_secret_access_key=settings.AWS_SECRET_KEY,
        )

    def upload_image_to_s3(self, local_path: str, folder: str) -> str:
        """
        Upload an image file to S3 and return its public URL.
        """
        file_ext = os.path.splitext(local_path)[-1]
        unique_filename = f"{folder}/{uuid.uuid4()}{file_ext}"

        try:
            self.s3_client.upload_file(
                local_path,
                settings.AWS_BUCKET_NAME,
                unique_filename,
                ExtraArgs={"ContentType": "image/jpeg"},
            )

            public_url = f"https://{settings.AWS_BUCKET_NAME}.s3.amazonaws.com/{unique_filename}"
            return public_url

        except NoCredentialsError:
            raise Exception("AWS credentials not found. Check your environment.")