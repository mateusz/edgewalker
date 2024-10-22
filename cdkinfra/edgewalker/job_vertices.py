import aws_cdk.aws_ec2 as ec2
import aws_cdk.aws_glue_alpha as glue
import aws_cdk.aws_iam as iam
import aws_cdk.aws_logs as logs
import aws_cdk.aws_s3 as s3
from aws_cdk import CfnOutput, RemovalPolicy
from constructs import Construct

from .neptune import Neptune
from .networking import Networking


class JobVertices(Construct):
    def __init__(
        self,
        networking: Networking,
        work_bucket: s3.Bucket,
        neptune: Neptune,
        scope: Construct,
        construct_id: str,
        **kwargs,
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        lg = logs.LogGroup(
            self, f"{construct_id}-job_vertices", removal_policy=RemovalPolicy.DESTROY
        )

        role = iam.Role(
            self,
            "GlueRole",
            assumed_by=iam.ServicePrincipal("glue.amazonaws.com"),
        )

        role.add_to_policy(
            iam.PolicyStatement(
                actions=["s3:List*", "s3:Get*"],
                resources=["arn:aws:s3:::commoncrawl", "arn:aws:s3:::commoncrawl/*"],
            )
        )
        role.add_to_policy(
            iam.PolicyStatement(
                actions=["s3:List*", "s3:Get*"],
                resources=["arn:aws:s3:::commoncrawl", "arn:aws:s3:::commoncrawl/*"],
            )
        )
        role.add_to_policy(
            iam.PolicyStatement(
                actions=[
                    "glue:GetConnection",
                ],
                resources=[
                    f"arn:aws:glue:{scope.region}:{scope.account}:catalog",
                    networking.glue_conn.connection_arn,
                ],
            )
        )
        role.add_to_policy(
            iam.PolicyStatement(
                actions=[
                    "ec2:DescribeSubnets",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeVpcEndpoints",
                    "ec2:DescribeRouteTables",
                    "ec2:CreateNetworkInterface",
                    "ec2:AttachNetworkInterface",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DeleteNetworkInterface",
                    "ec2:CreateTags",
                ],
                resources=["*"],
            )
        )

        lg.grant_write(role)
        work_bucket.grant_read_write(role)
        neptune.cluster.grant_connect(role)

        CfnOutput(self, "RoleOutput", value=role.role_arn)
        CfnOutput(self, "LogOutput", value=lg.log_group_name)
