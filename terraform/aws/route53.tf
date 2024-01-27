data "aws_caller_identity" "current" {}

# This resource MUST be created in us-east-1 region for it to work!!! 
resource "aws_kms_key" "domaindnssec" {
  description              = "Key for DNSSEC"
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy = jsonencode({
    Statement = [
      {
        Sid      = "Enable IAM User Permissions"
        Effect = "Allow"
        Action = "kms:*"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
      },
      {
        Sid      = "Allow Route 53 DNSSEC Service",
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ],
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Sid      = "Allow Route 53 DNSSEC to CreateGrant",
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action = "kms:CreateGrant",
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
    ]
    Version = "2012-10-17",
    Id = "dnssec-policy1"
  })
}

resource "aws_kms_alias" "alias" {
  name          = "alias/dnssec-key"
  target_key_id = aws_kms_key.domaindnssec.key_id
}


resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_key_signing_key" "dnssecksk" {
  name = "dnssec-sign-key"
  hosted_zone_id = aws_route53_zone.main.zone_id
  key_management_service_arn = aws_kms_key.domaindnssec.arn
}


output "aws_route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "aws_route53_zone_name_servers" {
  value = aws_route53_zone.main.name_servers
}

output "aws_route53_key_signing_key" {
  value = aws_route53_key_signing_key.dnssecksk.public_key
}
