import os
import sys

# Set environment variables BEFORE any imports
os.environ["TABLE_NAME"] = "test-table"
os.environ["AWS_XRAY_SDK_ENABLED"] = "false"
os.environ["AWS_DEFAULT_REGION"] = "us-east-1"

import pytest
from moto import mock_aws
import boto3

# Start mock BEFORE importing handlers
_mock = mock_aws()
_mock.start()

# Now safe to import handlers
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../src/backend"))


@pytest.fixture(scope="session")
def dynamodb_table():
    dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
    table = dynamodb.create_table(
        TableName="test-table",
        KeySchema=[
            {"AttributeName": "event_date", "KeyType": "HASH"},
            {"AttributeName": "event_datetime", "KeyType": "RANGE"},
        ],
        AttributeDefinitions=[
            {"AttributeName": "event_date", "AttributeType": "S"},
            {"AttributeName": "event_datetime", "AttributeType": "S"},
        ],
        BillingMode="PAY_PER_REQUEST",
    )
    return table


@pytest.fixture(autouse=True)
def clear_table(dynamodb_table):
    yield
    scan = dynamodb_table.scan()
    with dynamodb_table.batch_writer() as batch:
        for item in scan.get("Items", []):
            batch.delete_item(
                Key={
                    "event_date": item["event_date"],
                    "event_datetime": item["event_datetime"],
                }
            )


def pytest_sessionfinish(session, exitstatus):
    _mock.stop()
