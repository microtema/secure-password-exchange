provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      doc-ms-name = var.service_name
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${ var.domain_name }LambdaRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid : ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "template_file" "lambda_policy" {
  template = "${file("${path.module}/policy.json")}"

  vars = {
    table_name = upper(var.domain_name)
  }
}

resource "aws_iam_policy" "this" {
  name        = "${var.project_name}-${var.service_name}-${var.stage_name}-${var.aws_region}LambdaPolicy"
  path        = "/"
  description = "IAM policy for ${ var.service_name } lambda functions"
  policy      = data.template_file.lambda_policy.rendered
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# create aws s3 bucket
resource "aws_s3_bucket" "lib" {
  bucket =  "${var.project_name}-${var.service_name}-${var.stage_name}-${var.aws_region}"
  tags   = {
    Name        = "${ var.service_name } API CRUD operations"
    Environment = var.stage_name
  }
}

resource "aws_s3_bucket_versioning" "lib" {
  bucket = aws_s3_bucket.lib.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.lib.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

## create Bucket ACL with private ACL
resource "aws_s3_bucket_acl" "lib" {
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.lib.id
  acl        = "private"
}

data "archive_file" "lib" {
  type        = "zip"
  source_dir  = "${path.module}/../api"
  output_path = "${path.module}/../lib/${var.service_name}.zip"
}

resource "aws_s3_object" "lib" {

  bucket     = aws_s3_bucket.lib.id

  key    = "${var.service_name}.zip"
  source = data.archive_file.lib.output_path

  etag = filemd5(data.archive_file.lib.output_path)
}

# Create Password
resource "aws_lambda_function" "create_password" {
  function_name = "${lower(var.domain_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}-Create${ var.domain_name }"
  description   = "Create a ${ var.domain_name }"

  s3_bucket = aws_s3_bucket.lib.id
  s3_key    = aws_s3_object.lib.key

  runtime = var.node_runtime
  handler = "src/createPassword.handler"

  environment {
    variables = {
      TABLE_NAME = upper(var.domain_name)
      REGION = lower(var.aws_region)
    }
  }

  source_code_hash = data.archive_file.lib.output_base64sha256

  role = aws_iam_role.this.arn
}

resource "aws_cloudwatch_log_group" "create_password" {
  name = "/aws/lambda/${aws_lambda_function.create_password.function_name}"

  retention_in_days = 7
}

# Password Created
resource "aws_lambda_function" "password_changed" {
  function_name = "${lower(var.domain_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}-Change${var.domain_name}"
  description   = "${ var.domain_name } Changed"

  s3_bucket = aws_s3_bucket.lib.id
  s3_key    = aws_s3_object.lib.key

  runtime = var.node_runtime
  handler = "src/passwordChanged.handler"

  environment {
    variables = {
      TABLE_NAME = upper(var.domain_name)
      REGION = lower(var.aws_region)
    }
  }

  source_code_hash = data.archive_file.lib.output_base64sha256

  role = aws_iam_role.this.arn
}

resource "aws_cloudwatch_log_group" "password_changed" {
  name = "/aws/lambda/${aws_lambda_function.password_changed.function_name}"

  retention_in_days = 7
}

# Get Password
resource "aws_lambda_function" "get_password" {
  function_name = "${lower(var.domain_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}-Get${ var.domain_name }"
  description   = "Get a ${ var.domain_name } by Key"

  s3_bucket = aws_s3_bucket.lib.id
  s3_key    = aws_s3_object.lib.key

  runtime = var.node_runtime
  handler = "src/getPassword.handler"
  environment {
    variables = {
      TABLE_NAME = upper(var.domain_name)
      REGION = lower(var.aws_region)
    }
  }

  source_code_hash = data.archive_file.lib.output_base64sha256

  role = aws_iam_role.this.arn
}

resource "aws_cloudwatch_log_group" "get_password" {
  name = "/aws/lambda/${aws_lambda_function.get_password.function_name}"

  retention_in_days = 7
}

# Delete Password
resource "aws_lambda_function" "delete_password" {
  function_name = "${lower(var.domain_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}-Delete${ var.domain_name }"
  description   = "Delete a ${ var.domain_name } by given Key"

  s3_bucket = aws_s3_bucket.lib.id
  s3_key    = aws_s3_object.lib.key

  runtime = var.node_runtime
  handler = "src/deletePassword.handler"
  environment {
    variables = {
      TABLE_NAME = "${upper(var.domain_name)}-${upper(var.stage_name)}-${upper(var.aws_region)}"
      REGION = upper(var.aws_region)
    }
  }

  source_code_hash = data.archive_file.lib.output_base64sha256

  role = aws_iam_role.this.arn
}

resource "aws_cloudwatch_log_group" "delete_password" {
  name = "/aws/lambda/${aws_lambda_function.delete_password.function_name}"

  retention_in_days = 7
}

data "template_file" "openapi" {

  template = file("${path.module}/openapi.yaml")

  vars = {
    context_path = "${lower(var.domain_name)}s"

    create_password_lambda_arn = aws_lambda_function.create_password.arn
    get_password_lambda_arn    = aws_lambda_function.get_password.arn

    cognito_user_pool_arn     = tolist(data.aws_cognito_user_pools.this.arns)[0]

    aws_region              = var.aws_region
    lambda_identity_timeout = var.lambda_identity_timeout
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name           = "${lower(var.project_name)}-${lower(var.service_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}"
  description    = "${ var.domain_name } OPEN API Gateway"
  api_key_source = "HEADER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = data.template_file.openapi.rendered
}

resource "aws_dynamodb_table" "this" {
  name             = upper(var.domain_name)
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "message"
    type = "S"
  }

  attribute {
    name = "expired"
    type = "N"
  }

  attribute {
    name = "once"
    type = "B"
  }

  global_secondary_index {
    name            = "PasswordMessageExpiredIndex"
    hash_key        = "message"
    range_key       = "expired"
    projection_type = "ALL"
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_trigger" {
  event_source_arn  = aws_dynamodb_table.this.stream_arn
  function_name     = aws_lambda_function.password_changed.arn
  starting_position = "LATEST"
}

# Create Password permission
resource "aws_lambda_permission" "create_password" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_password.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/${lower(var.domain_name)}s"
}

# Get Password permission
resource "aws_lambda_permission" "get_password" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_password.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/GET/${lower(var.domain_name)}s/*"
}

## API KEY
resource "aws_api_gateway_api_key" "this" {
  name = "${lower(var.service_name)}-${lower(var.domain_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}"
}

resource "aws_api_gateway_usage_plan_key" "this" {
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
}

# Usage Plan
resource "aws_api_gateway_usage_plan" "this" {
  name         = "${lower(var.service_name)}-${lower(var.domain_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}"
  description  = "Usage plan for ${lower(var.domain_name)} API"
  product_code = lower(var.domain_name)

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  quota_settings {
    limit  = 1000
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 20
    rate_limit  = 100
  }
}

# Deploy REST API
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}

data "aws_cognito_user_pools" "this" {
  name = "${lower(var.project_name)}-${lower(var.stage_name)}-${lower(var.aws_region)}"
}