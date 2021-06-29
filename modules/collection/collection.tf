resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "shooting_insights"
  protocol_type = "HTTP"
  route_key     = "POST /si/submit"
  target        = aws_lambda_function.lambda.arn

  depends_on = [
    aws_lambda_function.lambda
  ]
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                    = aws_apigatewayv2_api.api_gateway.id
  integration_type          = "AWS_PROXY"
  description               = "Integrate api gateway with lambda function"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.lambda.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"

  depends_on = [
    aws_lambda_function.lambda
  ]
}

resource "aws_lambda_permission" "api-gw" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.arn
    principal     = "apigateway.amazonaws.com"

    source_arn = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*/*"
}

resource "aws_iam_role" "lambda_role" {
  name = "collection_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${aws_lambda_function.lambda.function_name}_policy"
  description = "iam policy for ${aws_lambda_function.lambda.function_name}"
  policy =  <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "ses:SendEmail",
              "ses:SendRawEmail",
              "lambda:InvokeFunction"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject"
          ],
          "Resource": [
              "${var.data_bucket_arn}"
          ]
      }
  ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda" {
  filename         = "./modules/collection/collection_payload.zip"
  function_name    = "collection"
  role             = aws_iam_role.lambda_role.arn
  handler          = "collection.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("./modules/collection/collection_payload.zip")
}

data "archive_file" "lambda" {
  type = "zip"
  source_file = "./modules/collection/collection.py"
  output_path = "./modules/collection/collection_payload.zip"
}

output "output_arn" {
  value = aws_lambda_function.lambda.arn
}

output "output_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}
