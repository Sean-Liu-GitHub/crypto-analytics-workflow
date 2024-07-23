locals {
  data_lake_bucket = "coins_data_lake"
  all_project_services = concat(var.gcp_service_list, [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "compute.googleapis.com"
  ])
}

variable "project_id" {
  description = "project id"
  default = "crypto-analytics-gcp"
  type = string
}

variable "region" {
  description = "Regional location of GCP resources. Choose based on your location: https://cloud.google.com/about/locations"
  default = "asia-east1"
  type = string
}

variable "gcp_storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default = "STANDARD"
}

variable "staging_dataset_name" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "stg_coins_dataset"
}

variable "production_dataset_name" {
  description = "BigQuery Dataset that transformed data (from DBT) will be written to"
  type = string
  default = "prod_coins_dataset"
} 

variable "zone" {
  description = "Region for VM"
  type = string
  default = "asia-east1-a"
}

variable "gce_ssh_user" {
  default = "seanl"
}

variable "ssh_pub_key_file" {
  description = "Path to the generated SSH public key on your local machine"
  default = "C:/Users/seanl/.ssh/gpc.pub"
}

variable "ssh_priv_key_file" {
  description = "Path to the generated SSH private key on your local machine"
  default = "C:/Users/seanl/.ssh/gpc"
}

variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default     = ["storage.googleapis.com",]
}