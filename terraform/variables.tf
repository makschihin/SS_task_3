variable "provider_region" {
    description = "Provider region on aws"
    default     = "us-east-2"
}

variable "name" {
    description = "Name of resource"
    default     = "test"
}

variable "api_url" {
  description = "The API URL"
}

variable "dd_api_key" {
  description = "DD_API_KEY"
}

variable "dd_app_key" {
  description = "DD_APP_KEY"
}

variable "def_vpc" {
    description = "VPC cidr block"  
    default     = "10.32.0.0/16"
}

variable "image_path" {
    description = "Path to the image"
    default     = ""
}

variable "app_count" {
    description = "Count of app"
    type        = number
    default     = 2
}

variable "db_port" {
  description = "DB port"
  type        = number
  default     = 3306
}

variable "rds_type" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"  
}

variable "rds_engine" {
  description = "RDS engine"
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "RDS engine version"
  default     = "5.7"
}

variable "rds_user" {
  description = "RDS user name"
}

variable "rds_db_name" {
  description = "RDS DB name"
}

variable "rds_user_password" {
  description = "RDS user password"
}

variable "public_sub_1" {
  description = "Public subnet 1"
}

variable "public_sub_2" {
  description = "Public subnet 2"
}
variable "private_subnet_1" {
  description = "Private Subnets"
}

variable "private_subnet_2" {
  description = "Private Subnets"
}

variable "private1_az" {
  description = "availability_zone_1"
}

variable "private2_az" {
  description = "availability_zone_2"
}