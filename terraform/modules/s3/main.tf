resource "aws_s3_bucket" "source" {
  bucket = "source-image-bucket-ynov"
  force_destroy = true 
}

resource "aws_s3_bucket" "destination" {
  bucket = "dest-pdf-bucket-ynov"
  force_destroy = true
}
