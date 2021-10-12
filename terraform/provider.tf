provider "aws" {
    region = var.provider_region
}

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}


# Configure the Datadog provider
provider "datadog" {
  api_key = var.dd_api_key
  app_key = var.dd_app_key
  api_url = var.api_url
}