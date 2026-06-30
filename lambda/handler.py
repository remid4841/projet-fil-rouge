import boto3
import os
import urllib.parse

s3_client = boto3.client('s3')
DEST_BUCKET = os.environ.get('DEST_BUCKET')

def lambda_handler(event, context):
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        object_key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        print(f"Détection de {object_key} dans le bucket {source_bucket}")
        
    return {
        'statusCode': 200,
        'body': 'Traitement terminé avec succès.'
    }
