import boto3
import os
import urllib.parse
from PIL import Image

s3_client = boto3.client('s3')
DEST_BUCKET = os.environ.get('DEST_BUCKET')

def lambda_handler(event, context):
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        object_key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        
        # 1. Télécharger l'image depuis S3
        download_path = f"/tmp/{os.path.basename(object_key)}"
        s3_client.download_file(source_bucket, object_key, download_path)
        
        # 2. Convertir l'image en PDF (et la renommer)
        image = Image.open(download_path)
        pdf_filename = f"{os.path.splitext(os.path.basename(object_key))}.pdf"
        pdf_path = f"/tmp/{pdf_filename}"
        
        # Sauvegarde au format PDF
        image.convert('RGB').save(pdf_path)
        
        # 3. Uploader le PDF dans le bucket de destination
        s3_client.upload_file(pdf_path, DEST_BUCKET, pdf_filename)
        
        print(f"Succès : {object_key} converti et uploadé en tant que {pdf_filename} dans {DEST_BUCKET}")
        
    return {
        'statusCode': 200,
        'body': 'Conversion terminée avec succès.'
    }
