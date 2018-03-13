resource aws_route53_record minio-domain {
  zone_id = "${var.zone_id}"
  name    = "${var.subdomain}"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_instance.minio.public_dns}"]
}
