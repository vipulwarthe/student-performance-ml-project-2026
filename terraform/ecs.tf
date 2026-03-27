resource "aws_ecs_cluster" "cluster" {
  name = "student-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "student-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name  = "student-app"
      image = var.image_uri

      portMappings = [
        {
          containerPort = 5000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "student-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "student-app"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.listener]
}