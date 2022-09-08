import boto3
import sys
import os
import json
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):

    logger.info("### ### ### ### event ### ### ### ###")
    logger.info(event)
    logger.info("### ### ### ### context ### ### ### ###")
    logger.info(context)

    endpoint_name = event["EndpointName"]
    region = os.getenv("AWS_REGION", "ap-northeast-1")
    logger.info(f"EndpointName: {endpoint_name}")

    client = boto3.client('sagemaker-runtime', region_name=region)
    test_data = [
        "ドラゴンボール",
        "トヨタ",
        "Windows",
    ]
    for keyword in test_data:
        response = client.invoke_endpoint(
            EndpointName=endpoint_name,
            ContentType='application/json',
            Accept='application/json',
            Body=json.dumps({"keyword": keyword})
        )
        body = json.load(response['Body'])
        text = json.dumps(body, indent=2, ensure_ascii=False)

        print(text)
        logger.info(text)


if __name__ == "__main__":
    endpoint_name = sys.argv[1]
    event = {
        "EndpointName": endpoint_name
    }
    context = {}
    handler(event, context)