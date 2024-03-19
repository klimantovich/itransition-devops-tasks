#-----------------------------------------------
# Install Cloudwatch Addon on EKS cluster
#-----------------------------------------------
resource "aws_eks_addon" "cloudwatch" {
  cluster_name = module.dev_eks.cluster_id
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [
    module.dev_eks,
    aws_iam_role_policy_attachment.CloudWatchAgentServerPolicy,
    aws_iam_role_policy_attachment.AWSXrayWriteOnlyAccess
  ]
}

#-----------------------------------------------
# Add necessary permissions for IAM role
#-----------------------------------------------
resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = module.dev_eks.nodegroup_role_name
}

resource "aws_iam_role_policy_attachment" "AWSXrayWriteOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = module.dev_eks.nodegroup_role_name
}

#-----------------------------------------------
# Create Cloudwatch dashboard
#-----------------------------------------------
resource "aws_cloudwatch_dashboard" "app_monitoring" {
  dashboard_name = "${var.project_application_name}-monitoring"

  dashboard_body = jsonencode({
    "widgets" = [
      {
        "height" : 4,
        "width" : 15,
        "y" : 7,
        "x" : 4,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["ContainerInsights", "replicas_desired", "PodName", "${var.project_application_name}-${var.project_namespace}", "ClusterName", "${local.cluster_name}", "Namespace", "${var.project_namespace}", { "region" : "${var.aws_region}" }],
            [".", "replicas_ready", ".", ".", ".", ".", ".", ".", { "region" : "${var.aws_region}" }],
            [".", "status_replicas_available", ".", ".", ".", ".", ".", "."],
            [".", "status_replicas_unavailable", ".", ".", ".", ".", ".", "."]
          ],
          "region" : "${var.aws_region}",
          "stacked" : true,
          "title" : "Application Pod Replicas Count",
          "view" : "singleValue",
          "period" : 300,
          "stat" : "Minimum"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 8,
        "height" : 7,
        "properties" : {
          "metrics" : [
            ["ContainerInsights", "pod_cpu_request", "PodName", "${var.project_application_name}-${var.project_namespace}", "ClusterName", "${local.cluster_name}", "Namespace", "${var.project_namespace}"],
            [".", "pod_cpu_limit", ".", ".", ".", ".", ".", "."],
            [".", "pod_cpu_utilization", ".", ".", ".", ".", ".", "."]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "${var.aws_region}",
          "stat" : "Minimum",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "min" : 0
            }
          },
          "title" : "Pod CPU Utilization"
        }
      },
      {
        "type" : "metric",
        "x" : 8,
        "y" : 0,
        "width" : 8,
        "height" : 7,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["ContainerInsights", "pod_memory_limit", "PodName", "${var.project_application_name}-${var.project_namespace}", "ClusterName", "${local.cluster_name}", "Namespace", "${var.project_namespace}"],
            [".", "pod_memory_request", ".", ".", ".", ".", ".", "."],
            [".", "pod_memory_utilization", ".", ".", ".", ".", ".", "."]
          ],
          "region" : "${var.aws_region}",
          "yAxis" : {
            "left" : {
              "min" : 0
            }
          },
          "title" : "Pod Memory Utilization"
        }
      },
      {
        "type" : "metric",
        "x" : 16,
        "y" : 0,
        "width" : 8,
        "height" : 7,
        "properties" : {
          "metrics" : [
            ["ContainerInsights", "pod_network_tx_bytes", "PodName", "${var.project_application_name}-${var.project_namespace}", "ClusterName", "${local.cluster_name}", "Namespace", "${var.project_namespace}"],
            [".", "pod_network_rx_bytes", ".", ".", ".", ".", ".", "."],
            [".", "pod_interface_network_tx_dropped", ".", ".", ".", ".", ".", "."],
            [".", "pod_interface_network_rx_dropped", ".", ".", ".", ".", ".", "."]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "${var.aws_region}",
          "title" : "Pod Network Stats"
        }
      }
    ]
  })
}

#-----------------------------------------------
# Create Cloudwatch alerts
#-----------------------------------------------
resource "aws_cloudwatch_metric_alarm" "replicas_is_ready" {
  alarm_name                = "app-is-ready-notification"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "ContainerInsights"
  metric_name               = "replicas_ready"
  period                    = 30
  statistic                 = "Minimum"
  threshold                 = 1
  alarm_description         = <<EOF
    ArgoCD URL: 
    https://${data.kubernetes_service.argocd_endpoint.status.0.load_balancer.0.ingress.0.hostname} 

    ArgoCD Password: 
    ${nonsensitive(random_password.argocd_password.result)}
    
    Application URL: 
    https://${module.dev_eks.ingress_endpoint}

    Application Nginx Password:
    ${nonsensitive(random_password.nginx_password.result)}
    EOF
  insufficient_data_actions = []

  dimensions = {
    ClusterName = "${local.cluster_name}",
    Namespace   = "${var.project_namespace}",
    PodName     = "${var.project_application_name}-${var.project_namespace}"
  }

  ok_actions = [aws_sns_topic.monitoring_notifications.arn]
}

#-----------------------------------------------
# Create SNS topic with telegram notifications
# (For cloudwatch notifications)
#-----------------------------------------------
resource "aws_sns_topic" "monitoring_notifications" {
  name       = "monitoring-notifications"
  fifo_topic = false
}

resource "aws_sns_topic_subscription" "telegram_lambda" {
  topic_arn = aws_sns_topic.monitoring_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.tg_notifier.arn
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda_tg_notifier"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_lambda_permission" "exec_from_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tg_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.monitoring_notifications.arn
}

resource "aws_lambda_function" "tg_notifier" {
  function_name = "cloudwatch_tg_notifier"
  role          = aws_iam_role.iam_for_lambda.arn

  description      = "Lambda function which receives events from CloudWatch -> SNS service, and POST it to telegram bot API"
  filename         = "${path.module}/${var.telegram_bot_app_file}"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/${var.telegram_bot_app_file}")
  handler          = "lambda_function.lambda_handler"

  environment {
    variables = {
      TOKEN   = nonsensitive(data.google_secret_manager_secret_version.bot_token.secret_data)
      USER_ID = var.telegram_bot_chat_id
    }
  }
}
