resource "aws_iam_role" "lambda_exec" {
  name = "lambda_s3_processor_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../lambda/"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "processor" {
  # checkov:skip=CKV_AWS_116: DLQ non requise pour le périmètre de ce projet
  # checkov:skip=CKV_AWS_50: X-Ray tracing non requis pour le périmètre de ce projet
  # checkov:skip=CKV_AWS_115: Limite de concurrence non requise
  # checkov:skip=CKV_AWS_117: Déploiement dans un VPC non requis
  # checkov:skip=CKV_AWS_272: Validation code-signing non requise
  # checkov:skip=CKV_AWS_173: Chiffrement KMS des variables d'environnement non requis

  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "image_to_pdf_processor"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = { DEST_BUCKET = var.dest_bucket_id }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.source_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.source_bucket_id
  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_read_write_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = "${var.source_bucket_arn}/*"
      },
      {
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = "arn:aws:s3:::${var.dest_bucket_id}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
