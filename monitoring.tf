resource "aws_sns_topic" "my_topic" {
  name = "MyTopic"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "CPUUtilizationHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Alert if CPU utilization is greater than 90% for 5 minutes"
  alarm_actions       = [aws_sns_topic.my_topic.arn]
  dimensions = {
    InstanceId = aws_instance.ubuntu[0].id  # Use the index for the first instance
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "MemoryUtilizationHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert if memory utilization is greater than 80% for 5 minutes"
  alarm_actions       = [aws_sns_topic.my_topic.arn]
  dimensions = {
    InstanceId = aws_instance.ubuntu[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  alarm_name          = "DiskUtilizationHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskSpaceUtilization"
  namespace           = "System/Linux"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Alert if disk utilization is greater than 90% for 5 minutes"
  alarm_actions       = [aws_sns_topic.my_topic.arn]
  dimensions = {
    InstanceId = aws_instance.ubuntu[0].id
  }
}
