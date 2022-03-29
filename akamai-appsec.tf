/*
locals {
  csv_data = file("output_for_terraform.txt")
  country_code = csvdecode(local.csv_data)
}
*/
resource "null_resource" "network_list_extraction_script" {
 provisioner "local-exec" {
#   command = "chmod +x extract_country_code.txt"
   command = "/bin/bash ${path.module}/extract_country_code_new.txt >> ${path.module}/output_for_terraform_new.txt"
  }
}

data "local_file" "output_for_terraform" {
    filename = "${path.module}/output_for_terraform_new.txt"
  depends_on = ["null_resource.network_list_extraction_script"]
}

resource "akamai_appsec_configuration" "akamai_appsec" {
  contract_id = replace(data.akamai_contract.contract.id, "ctr_", "")
  group_id  = replace(data.akamai_group.group.id, "grp_", "")
  name = "${var.akamaiPrefix}-SecurityConfig"
  description = "Security Configuration for ${var.akamaiPrefix}-pm"
  host_names = [ "www.${var.akamaiPrefix}" ]

  depends_on = [ akamai_property_activation.activate_staging ]
}

resource "akamai_appsec_security_policy" "security_policy" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  default_settings       = true
  security_policy_name = var.policy_name
  security_policy_prefix = "${var.securityPolicyPrefix}"
}


resource "akamai_appsec_advanced_settings_pragma_header" "pragma_header" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  pragma_header = file("${path.module}/appsec-snippets/pragma_header.json")
}


/*
resource "akamai_appsec_waf_mode" "waf_mode" {
 config_id          = akamai_appsec_configuration.akamai_appsec.config_id
 security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
 mode = "KRS"
}
*/

resource "akamai_networklist_network_list" "IPBLOCKLIST" {
  #for_each = { for country in local.country_code : country.CountryName => country }
  #count = length(local.country_code)
  name = "IPBLOCKLIST"
  type = "IP"
  description = "IPBLOCKLIST"
  list = var.ipblock_list
  mode = "REPLACE"
  depends_on = [
    null_resource.network_list_extraction_script
  ]
}

resource "akamai_networklist_network_list" "IPBLOCKLISTEXCEPTIONS" {
  name = "IPBLOCKLISTEXCEPTIONS"
  type = "IP"
  description = "IPBLOCKLISTEXCEPTIONS"
  list = var.ipblock_list_exceptions
  mode = "REPLACE"
}

resource "akamai_networklist_network_list" "GEOBLOCKLIST" {
  name = "GEOBLOCKLIST"
  type = "GEO"
  description = "GEOBLOCKLIST"
  #list = ["data.local_file.output_for_terraform.content"]
  list = var.geoblock_list
  mode = "REPLACE"
  #depends_on = [
  #  null_resource.network_list_extraction_script
  #]
}

/*
resource "akamai_networklist_network_list" "GEOBLOCKLIST" {
  name = "GEOBLOCKLIST"
  type = "GEO"
  description = "GEOBLOCKLIST"
  list = [upper(data.local_file.output_for_terraform.content)]
  mode = "REPLACE"
  depends_on = [
    null_resource.network_list_extraction_script
  ]
}
*/



resource "akamai_networklist_network_list" "SECURITYBYPASSLIST" {
  name = "SECURITYBYPASSLIST-DJ"
  type = "IP"
  description = "SECURITYBYPASSLIST"
  list = var.securitybypass_list
  mode = "REPLACE"
}

resource "akamai_appsec_match_target" "match_target" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  match_target = templatefile("${path.module}/appsec-snippets/match_targets.json", {
      config_id = akamai_appsec_configuration.akamai_appsec.config_id,
      hostname = "www.${var.akamaiPrefix}",
      policy_id = akamai_appsec_security_policy.security_policy.security_policy_id,
      securitybypass_list = akamai_networklist_network_list.SECURITYBYPASSLIST.id
      }
    )
}

resource  "akamai_appsec_ip_geo" "ip_geo_block" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  mode = "block"
  ip_network_lists = [ akamai_networklist_network_list.IPBLOCKLIST.id ]
  geo_network_lists = [ akamai_networklist_network_list.GEOBLOCKLIST.id ]
  exception_ip_network_lists = [ akamai_networklist_network_list.IPBLOCKLISTEXCEPTIONS.id ]
}
/*
resource "akamai_appsec_rate_policy" "rate_policy_page_view_requests" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  rate_policy =  file("${path.module}/appsec-snippets/rate-policies/rate_policy_page_view_requests.json")
}

resource  "akamai_appsec_rate_policy_action" "appsec_rate_policy_page_view_requests_action" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  rate_policy_id = akamai_appsec_rate_policy.rate_policy_page_view_requests.rate_policy_id
  ipv4_action = var.ratepolicy_page_view_requests_action
  ipv6_action = var.ratepolicy_page_view_requests_action
}

resource "akamai_appsec_rate_policy" "rate_policy_origin_error" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  rate_policy =  file("${path.module}/appsec-snippets/rate-policies/rate_policy_origin_error.json")
}

resource  "akamai_appsec_rate_policy_action" "appsec_rate_policy_origin_error_action" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  rate_policy_id = akamai_appsec_rate_policy.rate_policy_origin_error.rate_policy_id
  ipv4_action = var.ratepolicy_origin_error_action
  ipv6_action = var.ratepolicy_origin_error_action
}

resource "akamai_appsec_rate_policy" "rate_policy_post_requests" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  rate_policy =  file("${path.module}/appsec-snippets/rate-policies/rate_policy_post_requests.json")
}

resource  "akamai_appsec_rate_policy_action" "appsec_rate_policy_post_requests_action" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  rate_policy_id = akamai_appsec_rate_policy.rate_policy_post_requests.rate_policy_id
  ipv4_action = var.ratepolicy_post_requests_action
  ipv6_action = var.ratepolicy_post_requests_action
}

resource "akamai_appsec_slow_post" "slow_post" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  slow_rate_action = var.slow_post_protection_action
  slow_rate_threshold_rate = 10
  slow_rate_threshold_period = 60
}

resource "akamai_appsec_attack_group" "attack_group_web_attack_tool" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "TOOL"
  attack_group_action = var.attack_group_web_attack_tool_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_web_attack_tool_exception.json")
}

resource "akamai_appsec_attack_group" "attack_group_web_protocol_attack" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "PROTOCOL"
  attack_group_action = var.attack_group_web_protocol_attack_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_web_protocol_attack_exception.json")
}

resource "akamai_appsec_attack_group" "attack_group_sql_injection" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "SQL"
  attack_group_action = var.attack_group_sql_injection_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_sql_injection_exception.json")
}

resource "akamai_appsec_attack_group" "attack_group_cross_site_scripting" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "XSS"
  attack_group_action = var.attack_group_cross_site_scripting_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_cross_site_scripting_exception.json")
}

resource "akamai_appsec_attack_group" "attack_group_local_file_inclusion" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "LFI"
  attack_group_action = var.attack_group_local_file_inclusion_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_local_file_inclusion_exception.json")
}

resource "akamai_appsec_attack_group" "attack_group_remote_file_inclusion" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "RFI"
  attack_group_action = var.attack_group_remote_file_inclusion_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_remote_file_inclusion_exception.json")
}

resource "akamai_appsec_attack_group" "attack_group_command_injection" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "CMDI"
  attack_group_action = var.attack_group_command_injection_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_command_injection_exception.json")
}

resource "akamai_appsec_attack_group" "attack_group_web_platform_attack" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group = "PLATFORM"
  attack_group_action = var.attack_group_web_platform_attack_action
  condition_exception = file("${path.module}/appsec-snippets/attack-groups/attack_group_web_platform_attack_exception.json")
}
*/


resource "akamai_appsec_activations" "activation" {
  config_id = akamai_appsec_configuration.akamai_appsec.config_id
  network = var.env
  notes  = var.activationNote
  notification_emails = var.email
  depends_on = [
    akamai_appsec_configuration.akamai_appsec,
    akamai_appsec_security_policy.security_policy,
    akamai_appsec_advanced_settings_pragma_header.pragma_header,
    akamai_appsec_match_target.match_target,
    akamai_appsec_ip_geo.ip_geo_block
    ]
}
