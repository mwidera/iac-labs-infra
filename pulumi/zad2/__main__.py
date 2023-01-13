import pulumi
import pulumi_docker as docker
from pulumi_command import local

# resource "null_resource" "git_submodule" {
#   provisioner "local-exec" {
#     command = "git submodule update --remote"
#     working_dir = "../.."
#   }
# }
# random = local.Command("submodule", "git submodule update --remote", dir="../..")

example_app = docker.RemoteImage("exampleApp",
    name="example-app",
    build=docker.RemoteImageBuildArgs(
        path="../../iac-labs/example-app",
        tags=["example-app:latest"],
        build_arg={
            "platform": "linux/amd64",
        },
    ),
    force_remove=True)

postgres_registry_image = docker.get_registry_image(name="postgres:latest")

postgres_remote_image = docker.RemoteImage("postgresRemoteImage",
    name=postgres_registry_image.name,
    pull_triggers=[postgres_registry_image.sha256_digest],
    force_remove=True)

shared = docker.Network("shared",
    name="tfnet",
    attachable=True)

example_app = docker.Container("example-app",
    name="example-app",
    image=example_app.image_id,
    networks_advanced=[docker.ContainerNetworksAdvancedArgs(
        name=shared.name,
    )],
    envs=[
        "DB_ENGINE=postgresql",
        "DB_HOST=db",
        "DB_NAME=app",
        "DB_USERNAME=app_user",
        "DB_PASS=app_pass",
        "DB_PORT=5432",
    ],
    ports=[docker.ContainerPortArgs(
        internal=8000,
        external=8000,
    )])

db = docker.Container("db",
    name="db",
    image=postgres_remote_image.image_id,
    networks_advanced=[docker.ContainerNetworksAdvancedArgs(
        name=shared.name,
    )],
    envs=[
        "POSTGRES_DB=app",
        "POSTGRES_USER=app_user",
        "POSTGRES_PASSWORD=app_pass",
    ])
