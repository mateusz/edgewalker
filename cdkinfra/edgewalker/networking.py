import aws_cdk.aws_ec2 as ec2
import aws_cdk.aws_glue_alpha as glue
from aws_cdk import CfnOutput
from constructs import Construct


class Networking(Construct):
    vpc: ec2.IVpc
    private_subnet_1: ec2.ISubnet
    private_subnet_2: ec2.ISubnet
    glue_sg: ec2.SecurityGroup
    neptune_sg: ec2.SecurityGroup
    glue_conn: glue.IConnection

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        self.vpc = ec2.Vpc(
            self,
            "MainVpc",
            ip_addresses=ec2.IpAddresses.cidr("10.0.0.0/16"),
            max_azs=2,
            nat_gateways=1,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    cidr_mask=24,
                    name="Public",
                    subnet_type=ec2.SubnetType.PUBLIC,
                ),
                ec2.SubnetConfiguration(
                    cidr_mask=24,
                    name="Private",
                    subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS,
                ),
            ],
            gateway_endpoints={
                "S3": ec2.GatewayVpcEndpointOptions(
                    service=ec2.GatewayVpcEndpointAwsService.S3
                )
            },
        )
        self.private_subnet_1 = self.vpc.private_subnets[0]
        self.private_subnet_2 = self.vpc.private_subnets[1]

        self.glue_sg = ec2.SecurityGroup(
            self,
            "GlueConnectionSg",
            vpc=self.vpc,
            allow_all_ipv6_outbound=True,
            allow_all_outbound=True,
        )
        self.glue_sg.add_ingress_rule(
            ec2.Peer.any_ipv4(), ec2.Port.all_traffic(), "Any ingress from Glue"
        )
        self.glue_sg.add_ingress_rule(
            ec2.Peer.any_ipv6(), ec2.Port.all_traffic(), "Any ingress from Glue"
        )

        self.neptune_sg = ec2.SecurityGroup(
            self,
            "NeptuneSg",
            vpc=self.vpc,
            allow_all_ipv6_outbound=True,
            allow_all_outbound=True,
        )
        self.neptune_sg.add_ingress_rule(self.glue_sg, ec2.Port.tcp(port=8182))

        self.glue_conn = glue.Connection(
            self,
            "GlueConnection",
            type=glue.ConnectionType.NETWORK,
            security_groups=[self.glue_sg],
            subnet=self.private_subnet_1,
        )

        CfnOutput(self, "GlueConnOutput", value=self.glue_conn.connection_name)
