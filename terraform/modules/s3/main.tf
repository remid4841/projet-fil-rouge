resource "aws_s3_bucket" "source" {
  bucket = "source-image-fadi-azzouz-2025"
  force_destroy = true 
}

resource "aws_s3_bucket" "destination" {
  bucket = "dest-pdf-fadi-azzouz-2025"
  force_destroy = true
}
