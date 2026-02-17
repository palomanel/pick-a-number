import json
import boto3
import uuid
import os
import logging
import datetime
from datetime import date, datetime, timezone, time
from decimal import Decimal
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

patch_all()

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
        event_datetime = datetime.strptime(
            event["requestContext"]["requestTime"], "%d/%b/%Y:%H:%M:%S %z"
        )
        event_date = event_datetime.date().isoformat()
        logger.info(f"Parsed body: {json.dumps(payload)}")

        # Convert floats to Decimals for DynamoDB compatibility
        # Also handle the case where location might be None
        # TODO: Add more fields if necessary
        location = (
            {
                "latitude": Decimal(repr(payload["location"]["latitude"])),
                "longitude": Decimal(repr(payload["location"]["longitude"])),
            }
            if payload["location"] is not None
            else None
        )

        table.put_item(
            Item={
                "event_date": event_date,
                "event_datetime": event_datetime.isoformat(),
                "number": payload["number"],
                "client_timestamp": payload["timestamp"],
                "location": location,
            }
        )

        logger.info(
            f"Successfully stored item in DynamoDB, PK: {event_date} SK: {event_datetime.isoformat()}"
        )

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"event_date": event_date, "status": "success"}),
        }
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {str(e)}, event body: {event.get('body')}")
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": f"Invalid JSON: {str(e)}"}),
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)}),
        }
