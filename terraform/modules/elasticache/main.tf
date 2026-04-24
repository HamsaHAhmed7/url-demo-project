resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project}-redis-subnet-group"
  subnet_ids = var.subnet_ids
  tags = { Name = "${var.project}-redis-subnet-group" }
}

resource "aws_security_group" "redis" {
  name   = "${var.project}-redis-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ecs_security_group]
  }
  tags = { Name = "${var.project}-redis-sg" }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project}-redis"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]
  tags = { Name = "${var.project}-redis" }
}
