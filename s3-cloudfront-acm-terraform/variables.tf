variable "ssl_certificate_arn" {
    default = "s"
    #${{ secrets.MSB-SSL-CERT-ARN }}
}

variable "invalidate_cloud_front_on_s3_update" {
  default     = true
  description = "Setup lambda to invalidate CDN on S3 updates"
}