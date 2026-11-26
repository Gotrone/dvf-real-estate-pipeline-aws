# Terraform

Defines the lake bucket, Glue database, an Athena workgroup with a per-query scan cap, and a
monthly budget alert. It has been applied by hand in `eu-north-1`. CI only runs
`terraform fmt` and `terraform validate` (no credentials needed).

Deployment is a manual, deliberate step:

```bash
cd terraform
terraform init
terraform plan -var alert_email=you@example.com -out=dvf.tfplan   # add -var region=... if needed
terraform apply dvf.tfplan                                        # only after reading the plan
```

State is local and ignored by Git. Keep it: it is required to change or destroy the
resources. Plan files contain the variable values, so do not commit them.
