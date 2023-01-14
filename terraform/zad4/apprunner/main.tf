
resource "aws_apprunner_service" "example" {
  service_name = "example"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8000"
      }
      image_identifier      = "public.ecr.aws/aws-containers/hello-app-runner:latest"
      image_repository_type = "ECR_PUBLIC"
    }
    # authentication_configuration {
    #   access_role_arn = aws_iam_role.role.arn
    # }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "example-apprunner-service"
  }
}

# resource "aws_iam_role" "role" {
#   name = "test-role"
#   assume_role_policy = jsonencode(
#   {
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",

#         Effect = "Allow",
#         Sid = "",
#         Principal = {
#           Service = [
#             "build.apprunner.amazonaws.com",
#             "tasks.apprunner.amazonaws.com"
#           ]
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "test-attach" {
#    role       = aws_iam_role.role.name
#    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
#  }