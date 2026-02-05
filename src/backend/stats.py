import json
import boto3
import os
import logging
from datetime import datetime, time, timedelta, timezone
from collections import Counter
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def handler(event, context):
    try:
        logger.info(f"Received event: {json.dumps(event)}")

        # Get our date range
        from_time = datetime.fromisoformat(event["queryStringParameters"]["from"])
        to_time = datetime.fromisoformat(event["queryStringParameters"]["to"])
        logger.info(f"Querying for submissions between {from_time} and {to_time}")

        # Query DynamoDB for all entries from yesterday using scan with filter
        # Using scan since we don't have a GSI on timestamp
        response = table.scan(
            FilterExpression="#ts BETWEEN :start AND :end",
            ExpressionAttributeNames={
                "#ts": "timestamp",
            },
            ExpressionAttributeValues={
                ":start": from_time.isoformat(),
                ":end": to_time.isoformat(),
            },
        )

        items = response.get("Items", [])
        logger.info(f"Found {len(items)} submissions in the given date range")

        if not items:
            return {
                "statusCode": 200,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
                "body": json.dumps(
                    {
                        "from": from_time.isoformat(),
                        "to": to_time.isoformat(),
                        "most_selected_number": None,
                        "count": 0,
                        "total_submissions": 0,
                    }
                ),
            }

        # Extract numbers and find the most common one
        numbers = [int(item["number"]) for item in items]
        number_counts = Counter(numbers)
        most_common_number, count = number_counts.most_common(1)[0]

        logger.info(
            f"Most selected number yesterday: {most_common_number} (selected {count} times)"
        )

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps(
                {
                    "from": from_time.isoformat(),
                    "to": to_time.isoformat(),
                    "most_selected_number": most_common_number,
                    "count": int(count),
                    "total_submissions": len(items),
                }
            ),
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({"error": str(e)}),
        }
