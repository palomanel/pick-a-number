import json
import pytest
from stats import handler


@pytest.fixture
def seed_data(dynamodb_table):
    dynamodb_table.put_item(
        Item={
            "event_date": "2026-02-20",
            "event_datetime": "2026-02-20T10:00:00+00:00",
            "number": 7,
            "client_timestamp": "2026-02-20T10:00:00.000Z",
            "location": None,
        }
    )
    dynamodb_table.put_item(
        Item={
            "event_date": "2026-02-20",
            "event_datetime": "2026-02-20T11:00:00+00:00",
            "number": 7,
            "client_timestamp": "2026-02-20T11:00:00.000Z",
            "location": None,
        }
    )
    dynamodb_table.put_item(
        Item={
            "event_date": "2026-02-21",
            "event_datetime": "2026-02-21T10:00:00+00:00",
            "number": 3,
            "client_timestamp": "2026-02-21T10:00:00.000Z",
            "location": None,
        }
    )


def test_stats_success(dynamodb_table, seed_data):
    event = {"queryStringParameters": {"from": "2026-02-20", "to": "2026-02-21"}}

    response = handler(event, None)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["most_selected_number"] == 7
    assert body["count"] == 2
    assert body["total_submissions"] == 3


def test_stats_empty_range(dynamodb_table):
    event = {"queryStringParameters": {"from": "2026-02-25", "to": "2026-02-26"}}

    response = handler(event, None)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["most_selected_number"] is None
    assert body["count"] == 0
    assert body["total_submissions"] == 0


def test_stats_single_day(dynamodb_table, seed_data):
    event = {"queryStringParameters": {"from": "2026-02-21", "to": "2026-02-21"}}

    response = handler(event, None)

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["most_selected_number"] == 3
    assert body["count"] == 1
    assert body["total_submissions"] == 1
