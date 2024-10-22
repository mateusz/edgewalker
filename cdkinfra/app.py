#!/usr/bin/env python3
import hashlib

import aws_cdk as cdk

from edgewalker.ewstack import Ewstack

app = cdk.App()

stack = app.node.try_get_context("stack")
if not stack:
    raise Exception("Pass stack name as context (-c stack=xxx)")
environment = app.node.try_get_context("environment")
if not environment:
    raise Exception("Pass environment name as context (-c environment=xxx)")

cdk.Tags.of(app).add("ss:stack", stack)
cdk.Tags.of(app).add("ss:environment", environment)
stack = Ewstack(app, f"ew-{stack}-{environment}")

app.synth()
