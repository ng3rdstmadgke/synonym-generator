import boto3
import json
import sys
import os


if __name__ == "__main__":
    endpoint_name = sys.argv[1]
    region = os.getenv("AWS_REGION")

    client = boto3.client(
        'sagemaker',
        region_name=region,
    )
    response = client.describe_endpoint(
        EndpointName=endpoint_name,
    )
    print(response["EndpointStatus"])
