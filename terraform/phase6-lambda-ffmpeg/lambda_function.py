
import boto3
import os
import subprocess

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    for record in event['Records']:
        input_bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        output_key = key.replace('.mp4', '_transcoded.mp4')
        tmp_file = f'/tmp/{os.path.basename(key)}'
        s3.download_file(input_bucket, key, tmp_file)

        transcoded = f'/tmp/transcoded.mp4'
        subprocess.run(['ffmpeg', '-i', tmp_file, transcoded])

        s3.upload_file(transcoded, input_bucket, f'transcoded/{output_key}')
    return {"statusCode": 200, "body": "Video transcoded and uploaded."}
