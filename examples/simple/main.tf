module "ecs_task_scheduled_execution" {
  source                               = "../.."
  name                                 = var.name
  cluster_name                         = aws_ecs_cluster.this.name
  ecs_task_definition_family           = aws_ecs_task_definition.this.family
  security_groups                      = [aws_security_group.this.id]
  subnets                              = module.vpc.private_subnets
  assign_public_ip                     = false
  enabled                              = true
  cloudwatch_event_schedule_expression = "rate(2 minutes)"

  cloudwatch_event_input_transformer = [{
    input_paths    = { "time" = "$.time", "region" = "$.region" }
    input_template = <<EOF
{
    "commands":["echo", <time>],
    "region":<region>
}
EOF
  }]

  // need examples/deps apply
  cloudwatch_event_role_name = "StartExecutionStepFunctionCloudWatchEvent"
  sfn_iam_role_name          = "EcsTaskScheduledExecutionStepFunction"

  sfn_ecs_container_override = <<JSON
{
  "ContainerOverrides": [
    {
      "Name": "${aws_ecs_task_definition.this.family}",
      "Command.$": "$.commands",
      "Environment": [
        {
          "Name": "REGION",
          "Value.$": "$.region"
        }
      ]
    }
  ]
}
JSON
}
