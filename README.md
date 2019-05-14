# sovrin-validator-firewall-aws
Terraform to setup and provosion security group for Sovrin validator nodes in AWS

# How to use

1. Setup aws access key on your machine to make sure Terraform can make changes in your AWS (see https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

2. On your Sovrin validator machine, get list of current validators as JSON
```
current_validators --writeJson | node_address_list --outFormat json
```

3. Take this JSON and use it as value for key `validators` in `validators.json` file in this repo. Outbound will be only allowed addresses and their ports contained here.

4. In `validators.json`, set `allow_inbound_port` to reflect which port is your node listening on for Node2Node communication. Inbound from other validators will be allowed on this port.

5. Let's generate Terraform file from python script. Run `pip install -r requirements.txt` to install dependencies (Jinja2). (You might want to use `mkvirtualenv`).

6. If everything was set up properly, file `main.tf` should be generated in root file. Should looks somewhat like this:
```
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


  ingress {
    from_port   = 9701
    to_port     = 9701
    protocol    = "TCP"
    cidr_blocks = ["5.6.7.8/32"]
    description = "narnia"
  }

  egress {
    from_port   = 9701
    to_port     = 9701
    protocol    = "TCP"
    cidr_blocks = ["5.6.7.8/32"]
    description = "narnia"
  }

  ingress {
    from_port   = 9701
    to_port     = 9701
    protocol    = "TCP"
    cidr_blocks = ["1.2.3.4/32"]
    description = "mordor"
  }

  egress {
    from_port   = 9702
    to_port     = 9702
    protocol    = "TCP"
    cidr_blocks = ["1.2.3.4/32"]
    description = "mordor"
  }

}
```

7. Create file `terraform.tfvars` with following content:
```
region="eu-west-1"
vpc_id="vpc-abcd123"
```
whereas you need to set up the values accordingly to your AWS.

8. Now let's create the security group in AWS. Run `terraform init` and then `terraform apply`. You should now be able to find new security group `sovrin_validator_node2node_whitelist` in your AWS console.

9. If you want to modify this security group, modify `validator.json`, generate Terraform file `main.tf` and reapply terraform.

# To consider  
For sake of safety, you might consider always creating new security group to review in AWS and manually reassign on your AWS Sovrin node, rather than modifying security group of your Sovrin validator on the fly. 

To create new security group, you can simply delete terraform resource state
```
rm terraform.tfstate
```


