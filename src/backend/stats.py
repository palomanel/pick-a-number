import json
import boto3
import os
import logging
from boto3.dynamodb.conditions import Key
from datetime import datetime, timedelta
from collections import Counter
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

patch_all()

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def handler(event, context):
    try:
        logger.info(f"Received event: {json.dumps(event)}")

        # Get our date range
        from_date = datetime.fromisoformat(
            event["queryStringParameters"]["from"]
        ).date()
        to_date = datetime.fromisoformat(event["queryStringParameters"]["to"]).date()
        logger.info(f"Querying for submissions between {from_date} and {to_date}")

        # DynamoDB is partitioned by event_date, so we need to query for each date in the range and aggregate results
        query = lambda the_date: table.query(
            KeyConditionExpression=Key("event_date").eq(the_date.isoformat())
        ).get("Items", [])
        numbers = [
            int(item["number"])
            for x in range((to_date - from_date).days + 1)
            for item in query(from_date + timedelta(days=x))
        ]
        logger.info(f"Found {len(numbers)} submissions in the given date range")

        # Count number occurrences and get the most common number
        number_counts = Counter(numbers)
        most_common = number_counts.most_common(1)

        logger.info(f"Most common number in the given date range: {most_common})")

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(
                {
                    "from": from_date.isoformat(),
                    "to": to_date.isoformat(),
                    "most_selected_number": most_common[0][0] if most_common else None,
                    "count": most_common[0][1] if most_common else 0,
                    "total_submissions": len(numbers),
                }
            ),
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)}),
        }
