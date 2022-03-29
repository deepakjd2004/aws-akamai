/*provider "akamai" {
 edgerc = "~/.edgerc"
 config_section = var.section
}
*/
//data source to define the location of the JSON template files and provide information about any user-defined variables included within the templates.
data "akamai_property_rules_template" "rules" {
  template_file = abspath("${path.module}/property-snippets/main.json")
  variables {
    name =  "cpcode_value"
    value = replace(akamai_cp_code.cp_code.id,"cpc_","")
    type = "number"
}
variables {
    name = "origin_value"
    value = var.originValue
    type = "string"
}
}

// Create and manage cp_code
resource "akamai_cp_code" "cp_code" {
 product_id  = var.productId
 contract_id = data.akamai_contract.contract.id
 group_id = data.akamai_group.group.id
 name = "${var.akamaiPrefix}-cp"
}

// Create and manage Edge Hostname

resource "akamai_edge_hostname" "edge_hostname" {
 product_id  = var.productId
 contract_id = data.akamai_contract.contract.id
 group_id = data.akamai_group.group.id
 ip_behavior = "IPV4"
 edge_hostname = "${var.akamaiPrefix}.edgesuite.net"
}

// Create and manage Akamai Property
resource "akamai_property" "property" {
    name        = "${var.akamaiPrefix}-pm"
    product_id  = var.productId
    contract_id = data.akamai_contract.contract.id
    group_id    = data.akamai_group.group.id
    hostnames {
      cname_from = "www.${var.akamaiPrefix}"
      cname_to = "${var.akamaiPrefix}.edgesuite.net"
      cert_provisioning_type = "CPS_MANAGED"
    }
    hostnames {
      cname_from = "${var.akamaiPrefix}.edgesuite-staging.net"
      cname_to = "${var.akamaiPrefix}.edgesuite.net"
      cert_provisioning_type = "CPS_MANAGED"
    }
    hostnames {
      cname_from = "www.renderfaster.xyz"
      cname_to = "${var.akamaiPrefix}.edgesuite.net"
      cert_provisioning_type = "CPS_MANAGED"
    }
    rule_format = var.ruleFormat
    rules       = data.akamai_property_rules_template.rules.json
    depends_on = [
        akamai_edge_hostname.edge_hostname
    ]
}

// Activate the property in Staging
resource "akamai_property_activation" "activate_staging" {
     property_id = akamai_property.property.id
     contact  = var.email
     version  = akamai_property.property.latest_version
     network  = "STAGING"
     note = var.activationNote
     depends_on = [
        aws_instance.web
     ]
}

// Activate the property in Production
/*
resource "akamai_property_activation" "activate_prod" {
     property_id = akamai_property.property.id
     contact  = [var.email]
     version  = akamai_property.property.latest_version
     network  = "PRODUCTION"
     note = var.activation_note
     depends_on = [
        akamai_property_activation.activate_staging
     ]
//     count = local.prod_activation_count
}


// Create CPS Enrollement for DV Certificate
resource "akamai_cps_dv_enrollment" "www-cert" {
  contract_id = data.akamai_contract.contract.id
  acknowledge_pre_verification_warnings = true
  common_name = "renderfaster.xyz"
  sans = ["www.renderfaster.xyz"]
  secure_network = "standard-tls"
  sni_only = true
  admin_contact {
    address_line_one = "Level 7/76 Berry St"
    address_line_two = "North Sydney"
    city = "Sydney"
    country_code = "AU"
    email = "deepakjd2004@gmail.com"
    first_name = "Deepak"
    last_name = "Jha"
    organization = "Akamai Technologies"
    phone = "9008 9600"
    postal_code = "2000"
    region = "AU"
    title = ""
}
tech_contact {
  first_name = "Deepak"
  last_name = "Jha"
  phone = "9008 9600"
  email = "djha@akamai.com"
  address_line_one = "150 Broadway"
  city = "Cambridge"
  country_code = "US"
  organization = "Akamai Technologies"
  postal_code = "02142"
  region = "Massachusetts"
  title = ""
}
certificate_chain_type = "default"
csr {
  country_code = "US"
  city = "San Francisco"
  organization = "Akamai Technologies"
  organizational_unit = "Advanced Solutions"
  state = "CA"
}
enable_multi_stacked_certificates = false
network_configuration {
  disallowed_tls_versions = ["TLSv1", "TLSv1_1"]
  clone_dns_names = true
  geography = "core"
  ocsp_stapling = "on"
  preferred_ciphers = "ak-akamai-2018q3"
  must_have_ciphers = "ak-akamai-2018q3"
  quic_enabled = false
}
signature_algorithm = "SHA-256"
organization {
  name = "Akamai Technologies"
  phone = "4156709507"
  address_line_one = "799 Market St"
  address_line_two = "Suite 600"
  city = "San Francisco"
  country_code = "US"
  postal_code = "94103"
  region = "CA"
}
}
*/
