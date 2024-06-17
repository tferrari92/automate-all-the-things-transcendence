variable "project" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
}

variable "system" {
  description = "The system the Elasticache DBs will be deployed for"
  type        = string
}

# variable "aws_access_key" {
#   description = "AWS access key"
#   type        = string
# }

# variable "aws_secret_key" {
#   description = "AWS secret key"
#   type        = string
# }
