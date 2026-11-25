# Terraform (not applied yet)

Defines the lake bucket, Glue database, an Athena workgroup with a per-query scan cap, and a
monthly budget alert. **Nothing has been deployed.** CI only runs `terraform fmt` and
`terraform validate` (no credentials needed).

Deployment is a manual, deliberate step:

```bash
cd terraform
terraform init
terraform plan -var alert_email=you@example.com
terraform apply -var alert_email=you@example.com   # only after reading the plan
```
