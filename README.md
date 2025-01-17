# Edgewalker

Common crawl exploration.

## Rough overview

The goal is to load the website graph information for querying, and also once websites of interest have been identified, to be able to deeply analyse their content in bulk.

![Overview](diagram.png)

## Basic setup

Install aws-vault and micromamba, then:

```
micromamba create -n edgewalker -f environment.yml
micromamba activate edgewalker
poetry install
make build
```

Provision your access via aws-vault to the target account, then create infrastructure by:

```bash
cd cdkinfra
aws-vault exec gradient-dev --region us-east-1 -- cdk bootstrap -c stack=edgewalker -c environment=dev
aws-vault exec gradient-dev --region us-east-1 -- cdk deploy -c stack=edgewalker -c environment=dev
```

## Interactive sessions

Assuming you already have aws-vault set up, and profiles to match, add a profile for accessing Glue kernel by editing your `~/.aws/config` as follows.

```
[profile glue]
region=us-east-1
glue_iam_role=arn:aws:iam::400678530796:role/glue-etl-dev
credential_process="/path/to/edgewalker/aws-credentials-process.sh" <existing-profile>
```

Note the profile specified for the credentials process has to have an appropriate iam:PassRole permission to be able to start the Glue session.

You should now be able to run the [01_try_glue_interactive_sessions.ipynb](notebooks/01_try_glue_interactive_sessions.ipynb) to check your connectivity. Follow instructions in [https://docs.aws.amazon.com/glue/latest/dg/interactive-sessions-vscode.html](https://docs.aws.amazon.com/glue/latest/dg/interactive-sessions-vscode.html).

If you are not seeing the PySpark kernel, there is some troubleshooting steps in the doc, but for mac if you don't want to start jupyter every time you can do the following:

* `cp -fr ~/Library/Jupyter/kernels/glue_pyspark ~/Library/Jupyter/kernels/glue_pyspark_edgewalker`
* `which python`
* Copy the interpreter path
* `vim ~/Library/Jupyter/kernels/glue_pyspark_edgewalker/kernel.json`
* Replace the "python" interpreter path as is visible with the path found in the previous steps.

Glue PySpark should appear in the options now.
