import boto3
import sys
import os
import time
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
    client = boto3.client('sagemaker', region_name=region)
    while (True):
        response = client.describe_endpoint(
            EndpointName=endpoint_name,
        )
        status = response["EndpointStatus"]
        logger.info(f"status: {status}")

        if (status == "InService"):
            break
        elif (status == "Creating"):
            time.sleep(5)
            continue
        else:
            raise Exception(f"endpoint={endpoint_name}, status={status}")


if __name__ == "__main__":
    endpoint_name = sys.argv[1]
    event = {
        "EndpointName": endpoint_name
    }
    context = {}
    handler(event, context)