import aws_cdk.aws_ec2 as ec2
import aws_cdk.aws_iam as iam
import aws_cdk.aws_neptune_alpha as neptune
import aws_cdk.aws_s3 as s3
from aws_cdk import CfnOutput, RemovalPolicy
from constructs import Construct

from .networking import Networking


class Neptune(Construct):
    cluster: neptune.DatabaseCluster

    def __init__(
        self,
        networking: Networking,
        work_bucket: s3.Bucket,
        scope: Construct,
        construct_id: str,
        **kwargs,
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        role = iam.Role(
            self,
            "NeptuneRole",
            assumed_by=iam.ServicePrincipal("rds.amazonaws.com"),
        )
        work_bucket.grant_read_write(role)

        self.cluster = neptune.DatabaseCluster(
            self,
            "CommonCrawl",
            vpc=networking.vpc,
            instance_type=neptune.InstanceType.T3_MEDIUM,
            iam_authentication=True,
            instances=1,
            security_groups=[networking.neptune_sg],
            subnet_group=neptune.SubnetGroup(
                self,
                "CommonCrawlSubnets",
                vpc=networking.vpc,
                vpc_subnets=ec2.SubnetSelection(
                    subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS,
                ),
            ),
            associated_roles=[role],
            removal_policy=RemovalPolicy.DESTROY,
        )

        CfnOutput(
            self,
            "NeptuneHostnameOutput",
            value=self.cluster.cluster_endpoint.hostname,
        )
        CfnOutput(
            self,
            "NeptuneRoleOutput",
            value=role.role_arn,
        )
