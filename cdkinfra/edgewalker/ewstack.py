import aws_cdk.aws_s3 as s3
from aws_cdk import CfnOutput, RemovalPolicy, Stack
from constructs import Construct

from .job_vertices import JobVertices
from .neptune import Neptune
from .networking import Networking


class Ewstack(Stack):
    job_vertices: JobVertices

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        net = Networking(self, "Ewstack")
        work_bucket = s3.Bucket(
            self, "WorkBucket", removal_policy=RemovalPolicy.DESTROY
        )
        neptune = Neptune(net, work_bucket, self, "CommonCrawl")

        self.job_vertices = JobVertices(net, work_bucket, neptune, self, "JobVertices")

        CfnOutput(self, "WorkBucketOutput", value=work_bucket.bucket_name)
