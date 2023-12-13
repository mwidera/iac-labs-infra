output "webserver" {
  value = module.webserver.instance.public_ip
}
output "webserver2" {
  value = module.webserver2.instance.public_ip
}