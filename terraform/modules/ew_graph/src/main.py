import sys

from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext

args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "vertex_file",
        "neptune_endpoint",
    ],
)

# If we use python shell jobs:
# Use awswrangler.s3.read_csv to read the source file args['vertex_file'] in chunks into pandas df
# Filter stuff out
# Reformat for Gremlin
# https://docs.aws.amazon.com/neptune/latest/userguide/bulk-load-tutorial-format-gremlin.html
# Use awswrangler.neptune.bulk_load to load to Neptune
# https://github.com/awslabs/amazon-neptune-tools/tree/master/neptune-python-utils#using-neptune-python-utils-with-aws-glue

# Spark job:

spark_context = SparkContext.getOrCreate()
glue_context = GlueContext(spark_context)
session = glue_context.spark_session

df = GlueContext.create_sample_dynamic_frame_from_options(
    connection_type="s3",
    connection_options={
        "compressionType": "gzip",
        "paths": args["vertex_file"],
        "isFailFast": True,
    },
    format="grokLog",
    format_options={"logFormat": "%{INT:id},%{DATA:rev_domain},%{INT:num_hosts}"},
    num=10,
)

print(df)
