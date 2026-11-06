provider "aws" {
  region = "ap-southeast-2"
}

data "aws_instance" "existing" {
  instance_id = "i-0df03ae8e32351f29"
}

output "instance_details" {
  value = {
    id     = data.aws_instance.existing.id
    type   = data.aws_instance.existing.instance_type
    state  = data.aws_instance.existing.instance_state
  }
}
