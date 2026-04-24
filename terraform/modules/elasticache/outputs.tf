output "redis_url" {
  value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379"
}

output "cluster_id" {
  value = aws_elasticache_cluster.redis.id
}
