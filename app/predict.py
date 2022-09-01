import boto3
import json
import sys
import os


if __name__ == "__main__":
    endpoint_name = sys.argv[1]
    keyword = sys.argv[2]
    region = os.getenv("AWS_REGION")

    request = { 'keyword': keyword }
    client = boto3.client(
        'sagemaker-runtime',
        region_name=region,
    )
    response = client.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType='application/json',
        Accept='application/json',
        Body=json.dumps(request)
    )
    body = json.load(response['Body'])
    print(json.dumps(body, indent=2, ensure_ascii=False))