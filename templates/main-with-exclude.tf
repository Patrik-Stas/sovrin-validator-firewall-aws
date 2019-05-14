terraform {
  required_version = "~> 0.11.8"
}

variable "region" {}
variable "vpc_id" {}

provider "aws" {
  version = "~> 1.40.0"
  region     = "${var.region}"
}

resource "aws_security_group" "sovrin_validator_node2node_whitelist" {

  name        = "sovrin_validator_node2node_whitelist"
  description = "Allow only traffic among Sovrin Node2Node addresses"
  vpc_id      = "${var.vpc_id}"

{% for key, value  in validators.items() %}
{% if value.address in excluded_ips %}
###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
###### Skipping node: "{{key}}"
###### Because it's address {{value.address}} was found in exclusion list
###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
{% else %}
  ingress {
    from_port   = {{allow_inbound_port}}
    to_port     = {{allow_inbound_port}}
    protocol    = "TCP"
    cidr_blocks = ["{{value.address}}/32"]
    description = "{{key}}"
  }

  egress {
    from_port   = {{value.port}}
    to_port     = {{value.port}}
    protocol    = "TCP"
    cidr_blocks = ["{{value.address}}/32"]
    description = "{{key}}"
  }
{%- endif -%}
{% endfor %}
}

