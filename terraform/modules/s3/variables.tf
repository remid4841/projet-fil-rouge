variable "source_bucket_name" {
  description = "Nom du bucket S3 source pour l'upload des images"
  type        = string
  default     = "ynov-iac-2025-source-g3"
}

variable "destination_bucket_name" {
  description = "Nom du bucket S3 de destination pour les fichiers PDF"
  type        = string
  default     = "ynov-iac-2025-dest-g3"
}