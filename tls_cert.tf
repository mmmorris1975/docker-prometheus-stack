variable "key_algo" { default = "ECDSA" }
variable "rsa_bits" { default = 4096 }
variable "ecdsa_curve" { default = "P384" }
variable "key_file" { default = "" }
variable "cert_lifetime" { default = 43830 }

resource "tls_private_key" "priv_key" {
  algorithm = "${var.key_algo}"
  rsa_bits  = "${var.rsa_bits}"
  ecdsa_curve = "${var.ecdsa_curve}"
}

resource "tls_self_signed_cert" "tls_cert" {
  key_algorithm = "${var.key_algo}"
  private_key_pem = "${tls_private_key.priv_key.private_key_pem}"

  validity_period_hours = "${var.cert_lifetime}"
  early_renewal_hours = 672

  dns_names = ["raspberrypi"]
  ip_addresses = ["192.168.1.2", "204.12.189.20"]

  subject {
    organizational_unit = "Prometheus"
    organization = "Home"
    country = "US"
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "local_file" "priv_key" {
  content  = "${tls_private_key.priv_key.private_key_pem}"
  filename = "server.key"
}

resource "local_file" "tls_cert" {
  content  = "${tls_self_signed_cert.tls_cert.cert_pem}"
  filename = "server.crt"
}

output "cert_validity_start" { value = "${tls_self_signed_cert.tls_cert.validity_start_time}" }
output "cert_validity_end" { value = "${tls_self_signed_cert.tls_cert.validity_end_time}" }
