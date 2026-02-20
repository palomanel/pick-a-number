import json
import pytest
from decimal import Decimal
from submit_number import handler


@pytest.fixture
def lambda_event():
    return {
        "body": json.dumps(
            {
                "number": 7,
                "timestamp": "2026-02-20T16:00:00.000Z",
                "location": {"latitude": 40.7128, "longitude": -74.0060},
            }
        ),
        "requestContext": {"requestTime": "20/Feb/2026:16:00:00 +0000"},
    }


def test_submit_number_success(dynamodb_table, lambda_event):
    response = handler(lambda_event, None)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["status"] == "success"
    assert body["event_date"] == "2026-02-20"


def test_submit_number_without_location(dynamodb_table, lambda_event):
    event = lambda_event.copy()
    body = json.loads(event["body"])
    body["location"] = None
    event["body"] = json.dumps(body)

    response = handler(event, None)

    assert response["statusCode"] == 200


def test_submit_number_invalid_json(dynamodb_table):
    event = {
        "body": "invalid json",
        "requestContext": {"requestTime": "20/Feb/2026:16:00:00 +0000"},
    }

    response = handler(event, None)

    assert response["statusCode"] == 400
    body = json.loads(response["body"])
    assert "error" in body
