provider "akamai" {
 edgerc = "~/.edgerc"
 config_section = var.section
}

// define data source to query group details where resources are to be managed
data "akamai_contract" "contract" {
 group_name = var.groupName
}

// define data element to query contract details where resources are to be managed
data "akamai_group" "group" {
    contract_id = data.akamai_contract.contract.id
    group_name = var.groupName
}

/*
# Create DNS zone
resource "akamai_dns_zone" "tlz" {
#    contract = "C-1ED34DY" # has to hardcode becuase it did not pick up contract id from data.akamai_contract.contract.id
    contract = data.akamai_contract.contract.id
    group = data.akamai_group.group.id
    zone = "renderfaster_test.xyz"
    type =  "PRIMARY"
    comment =  "Zone Onboarding"
    sign_and_serve = false
}

resource "akamai_dns_record" "soa" {
    zone = "renderfaster.xyz"
    name = "renderfaster.xyz"
    recordtype =  "SOA"
    active = true
    ttl =  86400
    target = ["a1-43.akam.net. renderfaster.xyz. 2021052933 3600 600 604800 300"]
}
*/
resource "akamai_dns_record" "origin" {
    zone = "renderfaster.xyz"
    name = var.originValue
    recordtype =  "A"
    active = true
    ttl =  30
    target = [aws_instance.web.public_ip]
    depends_on = [
       aws_instance.web
    ]
}

resource "akamai_dns_record" "www" {
    zone = "renderfaster.xyz"
    name = "www.renderfaster.xyz"
    recordtype =  "CNAME"
    active = true
    ttl =  30
    target = ["${var.akamaiPrefix}.edgesuite.net"]
    depends_on = [
       aws_instance.web
    ]
}
