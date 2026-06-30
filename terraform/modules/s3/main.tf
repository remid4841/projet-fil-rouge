resource "aws_s3_bucket" "source" {
  bucket = "source-image-fadi-azzouz-2025"
  force_destroy = true 

  # checkov:skip=CKV2_AWS_6: Public access block non requis pour le périmètre du projet
  # checkov:skip=CKV_AWS_144: Cross-region replication non requise
  # checkov:skip=CKV_AWS_145: Chiffrement KMS non requis
  # checkov:skip=CKV2_AWS_61: Lifecycle configuration non requise pour ce projet
  # checkov:skip=CKV_AWS_21: Versioning non requis
  # checkov:skip=CKV2_AWS_62: Event notifications globales non requises
  # checkov:skip=CKV_AWS_18: Access logging non requis
}

resource "aws_s3_bucket" "destination" {
  bucket = "dest-pdf-fadi-azzouz-2025"
  force_destroy = true

  # checkov:skip=CKV2_AWS_6: Public access block non requis pour le périmètre du projet
  # checkov:skip=CKV_AWS_144: Cross-region replication non requise
  # checkov:skip=CKV_AWS_145: Chiffrement KMS non requis
  # checkov:skip=CKV2_AWS_61: Lifecycle configuration non requise pour ce projet
  # checkov:skip=CKV_AWS_21: Versioning non requis
  # checkov:skip=CKV2_AWS_62: Event notifications globales non requises
  # checkov:skip=CKV_AWS_18: Access logging non requis
}
