resource "docker_image" "example_app" {
  name = "example_app"
  build {
    path = "${path.cwd}/../../iac-labs/example-app"
    tag     = ["example_app:latest"]
    build_arg = {
      platform : "linux/amd64"
    }
    label = {
      author : "student"
    }
  }
}

# resource "docker_image" "postgres" {
  
# }