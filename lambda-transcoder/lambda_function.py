import json
import boto3
import psycopg2
import os
from datetime import datetime

s3_client = boto3.client('s3')
secrets_client = boto3.client('secretsmanager')

# Read from environment variables
BUCKET_NAME = os.environ['BUCKET_NAME']
DB_SECRET_ARN = os.environ['DB_SECRET_ARN']
DB_NAME = os.environ['DB_NAME']

def get_db_credentials():
    secret_value = secrets_client.get_secret_value(SecretId=DB_SECRET_ARN)
    secret = json.loads(secret_value['SecretString'])
    return secret

def lambda_handler(event, context):
    try:
        filename = event['queryStringParameters']['filename']
        content_type = event['queryStringParameters'].get('contentType', 'video/mp4')
        
        # Generate pre-signed URL
        presigned_url = s3_client.generate_presigned_url(
            'put_object',
            Params={'Bucket': BUCKET_NAME, 'Key': filename, 'ContentType': content_type},
            ExpiresIn=3600
        )

        # Save metadata in RDS
        creds = get_db_credentials()
        conn = psycopg2.connect(
            host=creds['host'],
            database=DB_NAME,
            user=creds['username'],
            password=creds['password'],
            port=5432
        )
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO video_uploads (filename, upload_url, created_at) VALUES (%s, %s, %s)",
            (filename, presigned_url, datetime.utcnow())
        )
        conn.commit()
        cur.close()
        conn.close()

        return {
            'statusCode': 200,
            'body': json.dumps({'upload_url': presigned_url}),
            'headers': {'Content-Type': 'application/json'}
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
