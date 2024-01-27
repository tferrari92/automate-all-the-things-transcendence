resource "aws_acm_certificate" "wildcard" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

output wildcard_certificate_arn {
  value       = aws_acm_certificate.wildcard.arn
}

# resource "aws_acm_certificate" "argocd" {
#   domain_name       = "argocd.${var.domain}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate" "grafana" {
#   domain_name       = "grafana.${var.domain}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate" "harbor" {
#   domain_name       = "harbor.${var.domain}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate" "jaeger" {
#   domain_name       = "jaeger.${var.domain}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate" "kiali" {
#   domain_name       = "kiali.${var.domain}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }


# Records
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.main.zone_id
  name    = tolist(aws_acm_certificate.wildcard.domain_validation_options)[0].resource_record_name
  # type    = "CNAME"
  type    = tolist(aws_acm_certificate.wildcard.domain_validation_options)[0].resource_record_type
  ttl     = 300
  records = [tolist(aws_acm_certificate.wildcard.domain_validation_options)[0].resource_record_value]
}