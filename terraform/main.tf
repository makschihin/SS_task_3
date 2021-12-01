locals {
  #mysql_url  = "jdbc:mysql://${aws_db_instance.default.endpoint}/${var.rds_db_name}?allowPublicKeyRetrieval=true&useSSL=false"
  mysql_user = var.rds_user
  mysql_pass = var.rds_user_password
  image_path = var.image_path
  apikey     = var.dd_api_key
}

####
#Availability zones
####
data "aws_availability_zones" "available_zones" {
  state = "available"
}

####
#Load balancer
####
#Defines the load balancer itself and attaches it to 
#the public subnet in each availability zone with the
#load balancer security group.
resource "aws_lb" "pet-lb" {
  name               = "${var.name}-lb"
  internal           = false
  subnets            = [aws_subnet.public_sub_1.id, aws_subnet.public_sub_2.id]
  #subnets            = aws_subnet.public.*.id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_task_task.id]
}

resource "aws_lb_target_group" "ecs_task" {
  name        = "${var.name}-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.new_vpc.id
  target_type = "ip"
  health_check {
    enabled  = true
    interval = 30
    path     = "/"
    port     = 8080
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_listener" "ecs_task" {
  load_balancer_arn = aws_lb.pet-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs_task.arn
    type             = "forward"
  }
}

####
#IAM role
####
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ECSTaskExecutionRolePolicy-Demo"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

####
#ECS
####
resource "aws_ecs_task_definition" "ecs_task" {
  family = "service"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu       = 512
  memory    = 1024
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = jsonencode([
    {
      name      = "ecs-task-container"
      image     = "${local.image_path}:latest"
      /*dockerLabels = {
            "com.datadoghq.ad.instances": "[{\"host\": \"%%host%%\", \"port\": 8080}]",
            "com.datadoghq.ad.check_names": "[\"ecs-task-container\"]",
            "com.datadoghq.ad.init_configs": "[{}]"
        }*/
      essential = true
      environment = [
        {
            name = "MYSQL_USER"
            value = local.mysql_user
        },
        {
            name = "MYSQL_PASS"
            value = local.mysql_pass
        },
        {
            name = "MYSQL_URL"
            value = local.mysql_url
        },
        {
            name = "spring_profiles_active"
            value = "mysql"
        }
      ]
      portMappings = [
        {
          containerPort = 8080
          # hostPort      = 8080
        }
      ],
     firelensConfiguration = null
     logConfiguration = {
       logDriver = "awsfirelens"
       options = {
        dd_message_key = "log"
        apikey = local.apikey
        provider = "ecs"
        dd_service = "ecs-task"
        dd_source = "httpd"
        Host = "http-intake.logs.datadoghq.eu"
        TLS = "on"
        dd_tags = "project:fluent-bit"
        Name = "datadog"
        }
      }
    },
    {
      name = "log_router"
      image = "amazon/aws-for-fluent-bit"
      logConfiguration = null
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
        }
      }
    },
    {
      name = "datadog-agent"
      image = "datadog/agent:latest"
      environment = [
        {
          name = "DD_API_KEY"
          value = local.apikey
        },
        { 
          name = "DD_SITE"
          value = "datadoghq.eu"
        },
        {
          name = "ECS_FARGATE"
          value = "true"
        }
        ]
    }
  ])
}

#ECS cluster security group
resource "aws_security_group" "ecs_task_task" {
  name        = "${var.name}-task-security-group"
  vpc_id      = aws_vpc.new_vpc.id

  dynamic "ingress" {
    for_each = ["22", "80", "8080", "8125", "8126"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

resource "aws_ecs_service" "ecs_task" {
  name            = "ecs-task-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_task_task.id]
    subnets          = [aws_subnet.public_sub_1.id, aws_subnet.public_sub_2.id] 
    #subnets          = aws_subnet.public.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_task.arn
    container_name   = "ecs-task-container"
    container_port   = 8080
  }

  #depends_on = [aws_lb_listener.ecs_task]
}

#############################################################################
# RDS
#############################################################################
# DB subnet group
resource "aws_db_subnet_group" "testRDS" {
  name = "testrds"
  subnet_ids = [aws_subnet.private_sub_1.id, aws_subnet.private_sub_2.id]
}

resource "aws_security_group" "rds-sg" {
  name        = "rds-security-group"
  description = "allow inbound access to the database"
  vpc_id      = aws_vpc.new_vpc.id

  ingress {
    // protocol    = "tcp"
    // from_port   = 0
    // to_port     = 3306
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS instance
resource "aws_db_instance" "default" {
allocated_storage    = 10
#availability_zone    = data.aws_availability_zones.available_zones.id
identifier           = "sampleinstance"
storage_type         = "gp2"
engine               = var.rds_engine
engine_version       = var.rds_engine_version
instance_class       = var.rds_type
name                 = var.rds_db_name
username             = var.rds_user
password             = var.rds_user_password
port                 = var.db_port
parameter_group_name = "default.mysql5.7"
db_subnet_group_name = aws_db_subnet_group.testRDS.name
vpc_security_group_ids = [ aws_security_group.rds-sg.id ]
publicly_accessible  = false
skip_final_snapshot  = true
multi_az             = false
}

# Create a new Datadog monitor
resource "datadog_monitor" "loadbalacer_anomalous" {
  name    = "Anomalous response LB"
  type    = "query alert"
  message = "Something "
  query   = "avg(last_10m):avg:aws.applicationelb.target_response_time.maximum{region:us-east-2} by {loadbalancer} > 3"
  monitor_thresholds {
    critical          = 3.0
    critical_recovery = 2.5
		warning           = 2.0
		warning_recovery  = 1.5
  }
}