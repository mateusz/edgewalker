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

df = glue_context.create_dynamic_frame_from_options(
    connection_type="s3",
    connection_options={
        "compressionType": "gzip",
        # "paths": ["s3://commoncrawl/projects/hyperlinkgraph/cc-main-2024-jun-jul-aug/host/vertices/part-00000-3095dbcf-098e-45c9-a3a7-70c1b93b80fa-c000.txt.gz"],
        "paths": [
            "s3://edgewalker-dev-ew-graph-ewtest-dev-working/job_vertices/original_dataset/vertices/part-00000-3095dbcf-098e-45c9-a3a7-70c1b93b80fa-c000.txt.gz"
        ],
        "isFailFast": True,
        # "groupFiles": "inPartition",
        # "groupSize": 1024*1024*100,
    },
    format="grokLog",
    format_options={"logFormat": "%{INT:id}\t%{GREEDYDATA:domain}"},
)
filtered_df = df.filter(f=lambda x: x["domain"].endswith(".nz"))
filtered_df.write(
    connection_type="s3",
    connection_options={
        "path": "s3://edgewalker-dev-ew-graph-ewtest-dev-working/job_vertices/all_vertices_from_job",
    },
    format="parquet",
)
