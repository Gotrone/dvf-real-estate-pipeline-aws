variable "region" {
  description = "AWS region (eu-west-3 = Paris)."
  type        = string
  default     = "eu-west-3"
}

variable "project" {
  description = "Prefix used for resource names."
  type        = string
  default     = "dvf-pipeline"
}

variable "athena_scan_limit_bytes" {
  description = "Hard cap on bytes scanned per Athena query (cost guard)."
  type        = number
  default     = 1073741824 # 1 GiB
}

variable "monthly_budget_usd" {
  description = "Monthly cost budget; an e-mail alert is sent at 80% of it."
  type        = number
  default     = 5
}

variable "alert_email" {
  description = "E-mail receiving budget alerts."
  type        = string
}
