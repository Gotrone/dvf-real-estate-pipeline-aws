output "lake_bucket" {
  value = aws_s3_bucket.lake.bucket
}

output "glue_database" {
  value = aws_glue_catalog_database.dvf.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.dvf.name
}
