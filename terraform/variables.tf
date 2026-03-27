variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "student-app"
}

variable "image_uri" {
  description = "Docker image URI"
  type        = string
}