##################
### Processing ###
##################

### Athena Results Bucket ###

module "athena_results_bucket" {
  source = "./modules/athena/results_bucket"
  athena_results_bucket = "shooting-insights-athena-results"
}

# Hello World Db

module "athena_db_hello_world" {
  source = "./modules/athena/database"
  athena_db_name = "hello_world"
  athena_bucket_name = module.athena_results_bucket.athena_results_bucket_name
  athena_workgroup_name = "hello_world"
}

# Hello World Table Query
module "athena_query_hello_world_create_table" {
  source = "./modules/athena/query"
  athena_query_name = "hello_world"
  athena_db_name = module.athena_db_hello_world.athena_db_name_output
  athena_workgroup_name = module.athena_db_hello_world.athena_workgroup_output
  athena_query = <<EOT
  CREATE EXTERNAL TABLE IF NOT EXISTS ${module.athena_db_hello_world.athena_db_name_output}.hello_world (
         `spot_1` int,
         `spot_2` int,
         `spot_3` int,
         `spot_4` int,
         `spot_5` int,
         `spot_6` int,
         `spot_7` int,
         `spot_8` int,
         `spot_9` int,
         `spot_10` int,
         `spot_11` int,
         `temp` int,
         `date` date,
         `time` string 
) 
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
         'serialization.format' = '1' ) LOCATION 's3://shooting-insights-data/test/' TBLPROPERTIES ('has_encrypted_data'='false');

  EOT
}

module "processing_lambda" {
  source              = "./modules/lambda"
  role                = "processing_lambda_role"
  filename            = module.processing_lambda.output_path
  function_name       = "processing"
  handler             = "processing.lambda_handler"
  runtime             = "python3.8"
  source_code_hash    = filebase64sha256(module.processing_lambda.output_path)

  lambda_policy_json  = <<EOT
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
              "ses:SendRawEmail"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:GetObject"
          ],
          "Resource": [
              "${module.bootstrap.data_bucket_arn}",
              "${module.athena_results_bucket.athena_results_bucket_arn}"
          ]
      }
  ]
}
EOT
}
