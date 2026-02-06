import boto3
from boto3.dynamodb.conditions import Key
from datetime import datetime, timedelta

# Initialize DynamoDB resource
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("your-stack-name-data")


def query_by_date(date_str):
    """Query all records for a specific date"""
    response = table.query(KeyConditionExpression=Key("event_date").eq(date_str))
    return response["Items"]


def query_date_range_same_day(date_str, start_time, end_time):
    """Query records within time range on same date"""
    start_datetime = f"{date_str}T{start_time}"
    end_datetime = f"{date_str}T{end_time}"

    response = table.query(
        KeyConditionExpression=Key("event_date").eq(date_str)
        & Key("event_datetime").between(start_datetime, end_datetime)
    )
    return response["Items"]


def query_multiple_dates(start_date, end_date):
    """Query across multiple dates (requires multiple queries)"""
    current_date = datetime.strptime(start_date, "%Y-%m-%d")
    end_date_obj = datetime.strptime(end_date, "%Y-%m-%d")

    all_items = []
    while current_date <= end_date_obj:
        date_str = current_date.strftime("%Y-%m-%d")
        items = query_by_date(date_str)
        all_items.extend(items)
        current_date += timedelta(days=1)

    return all_items


# Example usage
if __name__ == "__main__":
    # Query all records for 2024-01-15
    items = query_by_date("2024-01-15")

    # Query records between 10:00 and 15:00 on 2024-01-15
    items = query_date_range_same_day("2024-01-15", "10:00:00Z", "15:00:00Z")

    # Query records from 2024-01-15 to 2024-01-17
    items = query_multiple_dates("2024-01-15", "2024-01-17")
