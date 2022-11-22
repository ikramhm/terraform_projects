import boto3
import time
import os

IGNORE_PREFIX = "tag/"
WILDCARD_TRIGGER = "tag/book-notes/index.html"
WILDCARD_VAL = "/tag/*"

def handle_s3_change(event, context):
    ignore_prefix = ""
    paths = []
    for items in event["Records"]:
        key = items["s3"]["object"]["key"]
        print("Key: " + key)
        if key == WILDCARD_TRIGGER:
            paths.append(WILDCARD_VAL)
        elif key.startswith(IGNORE_PREFIX):
            continue
        elif key.endswith("index.html"):
            paths.append("/" + key[:-10])
            paths.append("/" + key)
        else:
            paths.append("/" + key)
    if paths:
        print("Invalidating " + str(paths))
        client = boto3.client('cloudfront')
        batch = {
            'Paths': {
                'Quantity': len(paths),
                'Items': paths
            },
            'CallerReference': str(time.time())
        }
        invalidation = client.create_invalidation(
            DistributionId=os.environ['CLOUDFRONT_DISTRIBUTION_ID'],
            InvalidationBatch=batch,
        )
        return batch
    else:
        print("Nothing to invalidate")
        return {}