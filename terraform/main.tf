module "s3_buckets" {
  source = "./modules/s3"
}

module "lambda_function" {
  source            = "./modules/lambda"
  source_bucket_id  = module.s3_buckets.source_bucket_id
  source_bucket_arn = module.s3_buckets.source_bucket_arn
  dest_bucket_id    = module.s3_buckets.dest_bucket_id
}
