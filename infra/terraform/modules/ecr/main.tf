resource "aws_ecr_repository" "this" {
    for_each = toset(var.repository_names)

    name = each.value
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }

    force_delete = var.force_delete

    tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
    for_each = aws_ecr_repository.this
    repository = each.value.name
    policy = jsonencode({
        rules = [
            {
                rulePriority = 1
                description = "Keep only last 3 images"
                selection = {
                    tagStatus = "any"
                    countType = "imageCountMoreThan"
                    countNumber = 3
                }
                action = {
                    type = "expire"
                }
            }
        ]
    })
}