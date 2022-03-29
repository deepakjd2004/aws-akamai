variable "prefix" {
  description = "The prefix used for all resources in this example"
  default = "TerraformDemo4Akamai"
}
variable "aws_region" {
    default = "us-east-1"
}

variable "vpc_cidr" {
    default = "192.168.0.0/16"
    }

variable "public_subnet_cidr"{
    default = "192.168.10.0/24"
    }

variable "sg_name" {
    default = "sg-akamai"
    }

variable "ami_id"{
        default = "ami-0c02fb55956c7d316"
        }

variable "instance_type"{
                default = "t2.micro"
                }

variable "instance_key"{
                default = "/Users/djha/.ssh/ec2_id_rsa.pub"
                }


##### Akamai Related Variables ####

variable "env" {
  type = string
  description = "a variable to hold akamai network name"
  default = "staging"
}

variable "akamaiPrefix" {
  type = string
  description = "a variable to hold prefix to interpolate other values"
}

variable "section" {
  type = string
  description = "a variable to hold edgerc section name"
}

variable "email" {
  type = list
  default = ["djha@akamai.com"]
}

variable "groupName" {
  type = string
  description = "a variable to hold group name"
}

variable "productId" {
  type = string
  description = "a variable to hold product ID"
}

variable "originValue" {
  type = string
  description = "a variable to hold product ID"
}

variable "ruleFormat" {
  type = string
  description = "a variable to hold product ID"
  default = "latest"
}

variable "activationNote" {
  type = string
  description = "a variable to hold Activation Note"
}

variable "policy_name" {
  type = string
  description = "a variable to hold security policy name"
}

variable "ipblock_list" {
  type = list
  description = "a variable to hold Ip Block List"
}

variable "ipblock_list_exceptions" {
  type = list
  description = "a variable to hold Ip Block List exceptions"
}

variable "geoblock_list" {
  type = list
  description = "a variable to hold GEO Block List"
}

variable "securitybypass_list" {
  type = list
  description = "a variable to hold securitybypass_list"
}

variable "securityPolicyPrefix" {
  type = string
  description = "a 4 alphaNumeric prefix"
}
