variable "aws_region" {
  default = "eu-west-3"
}
variable "assume_role_arn" {
  description = "ARN du rôle IAM restreint à assumer"
  type        = string
}
