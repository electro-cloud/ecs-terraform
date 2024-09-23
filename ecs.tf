#Create ecs cluster and tasks

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}


resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "1024"
  cpu                      = "512"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "ephermeral-storage"
          containerPath = "/var/log/nginx"  # Nginx logs stored here
        }
      ]
    },
    {
      #Container to sync logs with s3
      name      = "log-uploader"
      image     = "amazon/aws-cli"  # AWS CLI image
      cpu       = 128
      memory    = 256
      essential = false
      entryPoint = ["/bin/sh", "-c"]
      command = [
        "while true; do aws s3 sync /var/log/nginx s3://${aws_s3_bucket.nginx_logs_bucket.bucket}/nginx-logs/ --region us-east-1; sleep 60; done"
      ]
      mountPoints = [
        {
          sourceVolume  = "ephermeral-storage"
          containerPath = "/var/log/nginx"  
          
        }
      ]
    }
  ])
  ephemeral_storage {
    size_in_gib = 25
  }
  volume  {
      name = "ephermeral-storage"
      
      } 
      
    
}


