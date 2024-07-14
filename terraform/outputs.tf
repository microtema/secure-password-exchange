# Output value definitions

output "base_url" {
  description = "Base URL for API Gateway."
  value       = aws_api_gateway_deployment.this.invoke_url
}

output "cognito_user_pool_id" {
  value = tolist(data.aws_cognito_user_pools.this.ids)[0]
}

output "cognito_user_pool_arn" {
  value = tolist(data.aws_cognito_user_pools.this.arns)[0]
}

output "product_table_arn" {
  value = aws_dynamodb_table.this.arn
}