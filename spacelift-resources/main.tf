resource "spacelift_stack" "vpc-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack creates a VPC"
  name                         = "vpc-stack"
  project_root                 = "/infrastructure/terraform/vpc"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = true
  autodeploy        = true
}

resource "spacelift_stack" "ec2-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack creates an ec2 instanc"
  name                         = "ec2-stack"
  project_root                 = "/infrastructure/terraform/instances"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = true
  autodeploy        = true
}

resource "spacelift_stack" "ansible-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack configures the deployed ec2 using ansible"
  name                         = "ansible-stack"
  project_root                 = "/ansible"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = true
  autodeploy        = true
}