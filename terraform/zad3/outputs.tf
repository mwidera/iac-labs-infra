output "address" {
  value = "http://localhost:${docker_container.example-app.ports[0].external}"
}
