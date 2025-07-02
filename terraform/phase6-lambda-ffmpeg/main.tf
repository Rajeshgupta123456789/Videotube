
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "video_transcoder" {
  filename         = "function.zip"
  function_name    = "videoTranscoder"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 120
  memory_size      = 512

  environment {
    variables = {
      OUTPUT_PREFIX = "transcoded/"
    }
  }

  source_code_hash = filebase64sha256("function.zip")
}
