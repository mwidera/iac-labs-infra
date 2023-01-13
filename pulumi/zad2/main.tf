
# resource "null_resource" "git_submodule" {
#   provisioner "local-exec" {
#     command = "git submodule update --remote"
#     working_dir = "../.."
#   }
# }

resource "docker_image" "example_app" {
  name = "example-app"
  build {
    path = "../../iac-labs/example-app"
    tag  = ["example-app:latest"]
    build_arg = {
      platform : "linux/amd64"
    }
  }
  force_remove = true
}

data "docker_registry_image" "postgres" {
  name = "postgres:latest"
}

resource "docker_image" "postgres" {
  name          = data.docker_registry_image.postgres.name
  pull_triggers = [data.docker_registry_image.postgres.sha256_digest]
  force_remove = true
}

resource "docker_network" "shared" {
  name       = "tfnet"
  attachable = true
}

resource "docker_container" "example-app" {
  name  = "example-app"
  image = docker_image.example_app.image_id
  networks_advanced {
    name = docker_network.shared.name
  }
  env = [
    "DB_ENGINE=postgresql",
    "DB_HOST=db", "DB_NAME=app",
    "DB_USERNAME=app_user",
    "DB_PASS=app_pass",
    "DB_PORT=5432"
  ]
  ports {
    internal = 8000
    external = 8000
  }
}


resource "docker_container" "db" {
  name  = "db"
  image = docker_image.postgres.image_id
  networks_advanced {
    name = docker_network.shared.name
  }
  env = [
    "POSTGRES_DB=app",
    "POSTGRES_USER=app_user",
    "POSTGRES_PASSWORD=app_pass"
  ]
}
