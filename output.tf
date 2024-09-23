output "load_balancer_dns" {
  value = aws_lb.ecs_lb.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "vpc_name" {
  value = aws_vpc.ecs_vpc.id
}

output "s3_bucket_name" {
     value = aws_s3_bucket.nginx_logs_bucket.bucket
}

output "aws_ecs_task_definition" {
    value = aws_ecs_task_definition.nginx_task.arn
}