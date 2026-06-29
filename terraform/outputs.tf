output "data_b2_account_info" {
  value = {
    s3_api_url = data.b2_account_info.my_account_info.s3_api_url
  }
}

output "b2_key_id" {
  value = b2_application_key.dr_key.application_key_id
}

output "b2_key_secret" {
  value = b2_application_key.dr_key.application_key
  sensitive = true
}
