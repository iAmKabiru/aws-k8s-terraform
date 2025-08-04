variable "cluster_name" {
  description = "EKS cluster name prefix"
  type        = string
  default     = "my-eks-cluster"
}

variable "tags" {
  description = "Tags for IAM roles"
  type        = map(string)
  default     = {}
}
