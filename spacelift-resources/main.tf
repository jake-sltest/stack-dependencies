#Create the necessary stacks

resource "spacelift_stack" "vpc-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack creates a VPC"
  labels                       = ["sd-demo"]
  name                         = "vpc-stack"
  project_root                 = "/infrastructure/terraform/vpc"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = false
  autodeploy        = true
}

resource "spacelift_stack" "ec2-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack creates an ec2 instanc"
  labels                       = ["sd-demo"]
  name                         = "ec2-stack"
  project_root                 = "/infrastructure/terraform/instances"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = true
  autodeploy        = true
}

resource "spacelift_stack" "ansible-stack" {
    ansible {
        playbook = "playbook.yml"
    }
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack configures the deployed ec2 using ansible"
  labels                       = ["sd-demo"]
  name                         = "ansible-stack"
  project_root                 = "/ansible"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = true
  autodeploy        = true
}

#Create the Stack Dependencys and their respecitive Stack Dependency Rerferences (outputs)

resource "spacelift_stack_dependency" "ec2-depends-on-vpc" {
  stack_id            = spacelift_stack.ec2-stack.id
  depends_on_stack_id = spacelift_stack.vpc-stack.id
}

resource "spacelift_stack_dependency_reference" "ec2-vpc-output" {
  stack_dependency_id = spacelift_stack_dependency.ec2-depends-on-vpc.id
  output_name         = "subnetId"
  input_name          = "TF_VAR_subnetId"
}

resource "spacelift_stack_dependency" "ansible-depends-on-ec2" {
  stack_id            = spacelift_stack.ansible-stack.id
  depends_on_stack_id = spacelift_stack.ec2-stack.id
}

resource "spacelift_stack_dependency_reference" "ansible-ec2-output" {
  stack_dependency_id = spacelift_stack_dependency.ansible-depends-on-ec2.id
  output_name         = "ec2Id"
  input_name          = "TF_VAR_ec2Id"
}

resource "spacelift_context" "ansible-context" {
  description = "Context for Terraform-Ansible workflow demo"
  name        = "Ansible context - ${spacelift_stack.ec2-stack.id}"
}


resource "spacelift_environment_variable" "ansible_confg_var" {
  context_id = spacelift_context.ansible-context.id
  name       = "ANSIBLE_INVENTORY"
  value      = "/mnt/workspace/aws_ec2.yml"
  write_only = false
}

data "template_file" "aws_dynamic_inventory" {
  template = "${file("${path.module}/templates/aws_ec2.tpl")}"
  vars = {
    aws_region = "us-east-1"
    spacelift_stack_id = spacelift_stack.ec2-stack.id
  }
}

resource "spacelift_mounted_file" "aws_inventory" {
  context_id    = spacelift_context.ansible-context.id
  relative_path = "aws_ec2.yml"
  content       = base64encode(data.template_file.aws_dynamic_inventory.rendered)
  write_only    = false
}

resource "spacelift_context_attachment" "attachment" {
  context_id = spacelift_context.ansible-context.id
  stack_id   = spacelift_stack.ansible-stack.id
  priority   = 0
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-ansible" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible-key" {
  key_name   = "tf-ansible-workflow-key-${spacelift_stack.ec2-stack.id}"
  public_key = tls_private_key.rsa-ansible.public_key_openssh
}

resource "spacelift_mounted_file" "ansible-key" {
  context_id    = spacelift_context.ansible-context.id
  relative_path = "tf-ansible-key.pem"
  content       = base64encode(nonsensitive(tls_private_key.rsa-ansible.private_key_pem))
  write_only    = true
}

resource "spacelift_environment_variable" "ansible_private_key_file" {
  context_id = spacelift_context.ansible-context.id
  name       = "ANSIBLE_PRIVATE_KEY_FILE"
  value      = "/mnt/workspace/tf-ansible-key.pem"
  write_only = false
}