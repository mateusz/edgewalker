variable "account" {
  type        = string
  description = "Account alias for resource naming purposes"
}

variable "stack" {
  type        = string
  description = "Unique identifier for this stack"
}

variable "environment" {
  type        = string
  description = "Functional identifier of this stack"
}

variable "s3_edges" {
  type        = string
  description = "S3 path to edge file"
  default     = "s3://commoncrawl/projects/hyperlinkgraph/cc-main-2024-jun-jul-aug/domain/cc-main-2024-jun-jul-aug-domain-edges.txt.gz"
}

variable "s3_vertices" {
  type        = string
  description = "S3 path to vertex file"
  default     = "s3://commoncrawl/projects/hyperlinkgraph/cc-main-2024-jun-jul-aug/domain/cc-main-2024-jun-jul-aug-domain-vertices.txt.gz"
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to resources"
  default     = {}
}
