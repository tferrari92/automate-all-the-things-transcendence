resource "aws_iam_policy" "external_dns_controller" {
  policy = file("./templates/ExternalDNSController.json")
  name   = "AllowExternalDNSUpdates"
}
