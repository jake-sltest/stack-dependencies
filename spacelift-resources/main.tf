#Create the necessary stacks

resource "spacelift_stack" "vpc-stack" {
  administrative               = false
  space_id                     = "root"
  branch                       = "main"
  description                  = "This stack creates a VPC"
  labels                       = ["sd-demo"]
  name                         = "01-vpc-stack"
  project_root                 = "/infrastructure/vpc"
  repository                   = "stack-dependencies"
  enable_local_preview         = true
  terraform_smart_sanitization = false
  autodeploy                   = true
}

resource "spacelift_stack" "ec2-stack" {
  administrative               = false
  space_id                     = "root"
  branch                       = "main"
  description                  = "This stack creates an ec2 instanc"
  labels                       = ["sd-demo", "ansible"]
  name                         = "02-ec2-stack"
  project_root                 = "/infrastructure/instances"
  repository                   = "stack-dependencies"
  enable_local_preview         = true
  terraform_smart_sanitization = true
  autodeploy                   = true
}

resource "spacelift_stack" "ansible-stack" {
    ansible {
        playbook = "playbook.yml"
    }
  administrative               = false
  space_id                     = "root"
  branch                       = "main"
  description                  = "This stack configures the deployed ec2 using ansible"
  labels                       = ["sd-demo", "ansible"]
  name                         = "03-ansible-stack"
  project_root                 = "/ansible"
  repository                   = "stack-dependencies"
  enable_local_preview         = true
  terraform_smart_sanitization = true
  autodeploy                   = true
  before_init = [
    "chmod 600 /mnt/workspace/id_rsa",
    "echo $host > /mnt/workspace/inventory.ini"
  ] 
}


#Create the Stack Dependencys and their respecitive Stack Dependency Rerferences (outputs)

resource "spacelift_stack_dependency" "ec2-depends-on-vpc" {
  stack_id            = spacelift_stack.ec2-stack.id
  depends_on_stack_id = spacelift_stack.vpc-stack.id
}

resource "spacelift_stack_dependency_reference" "ec2-vpc-output" {
  stack_dependency_id = spacelift_stack_dependency.ec2-depends-on-vpc.id
  output_name         = "subnetId"
  input_name          = "TF_VAR_path_subnetId"
}

resource "spacelift_stack_dependency" "ansible-depends-on-ec2" {
  stack_id            = spacelift_stack.ansible-stack.id
  depends_on_stack_id = spacelift_stack.ec2-stack.id
}

resource "spacelift_stack_dependency_reference" "ansible-ec2-output" {
  stack_dependency_id = spacelift_stack_dependency.ansible-depends-on-ec2.id
  output_name         = "aws_instance_ip"
  input_name          = "host"
}

# #Create ansible context

resource "spacelift_context" "ansible-context" {
  description = "Context for Terraform-Ansible workflow"
  name        = "Ansible context"
  space_id    = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  labels      = ["autoattach:ansible"]
}

resource "spacelift_environment_variable" "ansible_remote_user" {
  context_id = spacelift_context.ansible-context.id
  name = "ANSIBLE_REMOTE_USER"
  value = "ec2-user" 
  write_only = false
}

resource "spacelift_environment_variable" "ansible_inventory" {
  context_id = spacelift_context.ansible-context.id
  name = "ANSIBLE_INVENTORY"
  value = "/mnt/workspace/inventory.ini" 
  write_only = false
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "spacelift_mounted_file" "private_key" {
  context_id    = spacelift_context.ansible-context.id
  relative_path = "id_rsa"
  content       = base64encode(nonsensitive(tls_private_key.rsa.private_key_pem))
  write_only    = true
}

resource "aws_key_pair" "ansible-key" {
  key_name   = "tf-ansible-workflow-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "spacelift_mounted_file" "public_key" {
  context_id    = spacelift_context.ansible-context.id
  relative_path = "id_rsa.pub"
  content       = base64encode(aws_key_pair.ansible-key.public_key)
  write_only    = true
}


resource "spacelift_environment_variable" "ansible_private_key_file" {
  context_id = spacelift_context.ansible-context.id
  name       = "ANSIBLE_PRIVATE_KEY_FILE"
  value      = "/mnt/workspace/id_rsa"
  write_only = false
}