import json
import boto3
import uuid
import os
import logging
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def handler(event, context):
    try:
        # Log the incoming event for debugging
        logger.info(f"Received event: {json.dumps(event)}")

        # Get payload from event
        payload = json.loads(event["body"])
        logger.info(f"Parsed body: {payload}")

        # Convert floats to Decimals for DynamoDB compatibility
        # Also handle the case where location might be None
        # TODO: Add more fields if necessary
        location = (
            {
                "latitude": Decimal(repr(payload["location"]["latitude"])),
                "longitude": Decimal(repr(payload["location"]["longitude"])),
            }
            if payload["location"] is not None
            else {
                "latitude": None,
                "longitude": None,
            }
        )

        item_id = str(uuid.uuid4())

        table.put_item(
            Item={
                "id": item_id,
                "number": payload["number"],
                "timestamp": payload["timestamp"],
                "location": location,
            }
        )

        logger.info(f"Successfully stored item {item_id} in DynamoDB")

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({"id": item_id, "status": "success"}),
        }
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {str(e)}, event body: {event.get('body')}")
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({"error": f"Invalid JSON: {str(e)}"}),
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
