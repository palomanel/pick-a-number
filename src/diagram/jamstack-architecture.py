# Requirements
# - graphviz installed on the system for rendering the diagram
# - diagrams library installed in the Python environment (pip install diagrams)
from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.aws.network import CloudFront
from diagrams.aws.storage import S3
from diagrams.aws.network import APIGateway
from diagrams.aws.compute import Lambda
from diagrams.aws.database import Dynamodb
from diagrams.aws.management import CloudwatchLogs
from diagrams.aws.devtools import XRay

graph_attr = {
    "layout": "dot",
    "compound": "true",
    "pad": "0.5",
}

with Diagram(
    "pick-a-number\nSample JAMstack architecture",
    filename="jamstack-architecture",
    show=False,
    graph_attr=graph_attr,
):
    user = User("User")

    with Cluster("AWS Cloud", graph_attr={"pad": "2"}):

        with Cluster("Frontend Layer"):
            cloudfront = CloudFront("CloudFront\nDistribution")
            s3 = S3("Static Website\nS3 Bucket")

        with Cluster("API Layer"):
            api_gateway = APIGateway("API Gateway")
            submit_number_lambda = Lambda("SubmitNumber\nLambda function")
            stats_lambda = Lambda("Stats\nLambda function")

        with Cluster("Data Layer"):
            dynamodb = Dynamodb("DynamoDB\nTable")

        with Cluster("Management\nLayer"):
            logs = S3("Logs\nS3 Bucket")
            cloudwatch = CloudwatchLogs("CloudWatch\nLogs")
            xray = XRay("X-Ray\nTracing")

    user >> cloudfront
    cloudfront >> Edge(label="/", minlen="2") >> s3
    cloudfront >> Edge(label="/api", minlen="2") >> api_gateway
    (
        api_gateway
        >> Edge(label="/api/submit-number", minlen="2")
        >> submit_number_lambda
        >> Edge(minlen="2")
        >> dynamodb
    )
    (
        api_gateway
        >> Edge(label="/api/stats", minlen="2")
        >> stats_lambda
        >> Edge(minlen="2")
        >> dynamodb
    )

    cloudfront >> Edge(style="dashed") >> logs
    s3 >> Edge(style="dashed") >> logs
    api_gateway >> Edge(style="dashed") >> cloudwatch
    submit_number_lambda >> Edge(style="dashed") >> cloudwatch
    stats_lambda >> Edge(style="dashed") >> cloudwatch
    api_gateway >> Edge(style="dashed") >> xray
    submit_number_lambda >> Edge(style="dashed") >> xray
    stats_lambda >> Edge(style="dashed") >> xray
