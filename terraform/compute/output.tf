output "public_ip" {
  value = "${aws_eip.runahr.public_ip}"
}
