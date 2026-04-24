resource "aws_ecr_repository" "repos" {
  for_each             = toset(["api", "worker", "dashboard"])
  name                 = "${var.project}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "${var.project}-${each.key}" }
}
