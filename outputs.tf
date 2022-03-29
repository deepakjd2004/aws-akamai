output "public_ip" {
          value = aws_instance.web.public_ip
      }

output "private_ip" {
        value       = aws_instance.web.private_ip
        description = "The private IP address of the main server instance."
      }

 output "SSH_Connection" {
     value      = format("ssh connection to instance  ${var.prefix}-vm ==> sudo ssh -i ~/.ssh/ec2_id_ed25519 ec2-user@%s",aws_instance.web.public_ip)
}
/*
output "dns_challenges" {
  value = akamai_cps_dv_enrollment.www-cert.dns_challenges
}

output "http_challenges" {
  value = akamai_cps_dv_enrollment.www-cert.http_challenges
}

output "enrollment_id" {
  value = akamai_cps_dv_enrollment.www-cert.id
}
*/
