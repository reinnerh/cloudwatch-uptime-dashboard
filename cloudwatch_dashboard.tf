resource "aws_cloudwatch_dashboard" "infra_dashboard" {
  dashboard_name = "infra-monitor-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          title = "Uptime - ALB Healthy Hosts",
          metrics = [
            [ "AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", "app/NAME-LB8A1-XXXXXXX/XXXXXXX", { "stat": "Minimum" } ]
          ],
          period = 300,
          stat = "Minimum",
          region = "sa-east-1",
          view = "timeSeries",
          stacked = false,
          yAxis = {
            left = {
              min = 0
            }
          },
          legend = {
            position = "bottom"
          },
          timezone = "UTC",
          liveData = false,
          start = "-P3M",  # Last 3 months
          end = "P0D"      # Until now
        }
      },
      {
        type = "metric",
        x    = 12,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          title = "Auto Scaling Group Utilization (%) - ASG-NAME",
          metrics = [
            [ { "expression": "(m1/m2)*100", "label": "Usage %", "id": "e1", "region": "sa-east-1" } ],
            [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "ASG-NAME", { "id": "m1", "visible": false } ],
            [ "AWS/AutoScaling", "GroupMaxSize", "AutoScalingGroupName", "ASG-NAME", { "id": "m2", "visible": false } ]
          ],
          region = "sa-east-1",
          view = "timeSeries",
          period = 300,
          stacked = false,
          yAxis = {
            left = {
              min = 0,
              max = 100
            }
          },
          legend = {
            position = "bottom"
          },
          timezone = "UTC",
          liveData = false,
          start = "-P3M",  # Last 3 months
          end = "P0D"      # Until now
        }
      },
      {
        type = "metric",
        x    = 0,
        y    = 6,
        width = 24,
        height = 6,
        properties = {
          title = "Platform Availability (%) - Last 3 Months",
          metrics = [
            [ { "expression": "100 * (m1 / PERIOD(m1))", "label": "Availability %", "id": "e1", "region": "sa-east-1" } ],
            [ "AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", "app/Ibacbr-LB8A1-eBf9GTCPKjBq/b04a514f4135b681", { "id": "m1", "stat": "SampleCount", "visible": false } ]
          ],
          region = "sa-east-1",
          view = "timeSeries",
          period = 86400,  # Daily aggregation
          stacked = false,
          yAxis = {
            left = {
              min = 90,
              max = 100
            }
          },
          annotations = {
            horizontal: [
              {
                color: "#ff0000",
                label: "SLA Threshold (99.9%)",
                value: 99.9
              }
            ]
          },
          legend = {
            position = "bottom"
          },
          timezone = "UTC",
          liveData = false,
          start = "-P3M",  # Last 3 months
          end = "P0D"      # Until now
        }
      },
      {
        type = "text",
        x    = 0,
        y    = 12,
        width = 24,
        height = 3,
        properties = {
          markdown = "# Platform Uptime Dashboard\nThis dashboard shows the platform uptime metrics for the last 3 months. The availability percentage is calculated based on ALB healthy host metrics.\n\n**Last Updated:** ${timestamp()}"
        }
      }
    ]
  })
}
