# aws-akamai
 This repo is provisioned to store terraform examples to build a website on AWS + using Akamai as CDN and Security platform



 Some pre-requisite, this post assume that you have fair bit of understanding working with terraform, akamai api's, akamai ecosystem, aws ecosystem and aws cli. Below are the important for getting started with 
 Akamai API - https://developer.akamai.com/getting-started/edgegrid
 AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html
 About Terraform - https://www.terraform.io/
 Terraform - Akamai provider https://registry.terraform.io/providers/akamai/akamai/latest/docs
 Terraform - AWS provider https://registry.terraform.io/providers/hashicorp/aws/latest

 This repo helps with

 *Section 1 - Set up AWS API/CLI*
 Check the detailed blog
 https://medium.com/p/e2ce226231ed/ 

 *Section 2 - Setup Akamai API*
 Follow the easy steps mentioned in link below to create your api client on akamai and store .edgerc file . Make sure that you give permission to your api client to manage
 a) Akamai Edge DNS
 b) Akamai PAPI (Property Manager API)
 c) Akamai Application Security Configuration

 *Section 3 - Setup Terraform*
 Install Terraform 
 Install Terraform | Terraform - HashiCorp Learn
 To use Terraform you will need to install it. HashiCorp distributes Terraform as a binary package.

 *Section 4 -Structure your terraform files*
 Four types of file that we are going to use within terraform ecosystem:-
 Resource specific *.tf file - provision/manage resources
 variables.tf - Variables declaration file
 terraform.tfvars - values of variables 
 Output.tf - returning details about the managed resources
 *Section 5 - Start writing terraform code*

 *Section 6 - Other terraform files*

 *Section 7 -Start Provisioning*

 *Section 8 - Test your website.*
https://techdocs.akamai.com/api-acceleration/docs/test-stage
