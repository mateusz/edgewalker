build: build-check build-do

build-check:
	@echo -n "This will install some system wide resources such as Glue kernels and AWS CDK. Are you sure to proceed? [y/N] " && read ans && [ $${ans:-N} = y ]

build-do:
	install-glue-kernels
	npm install -g aws-cdk

clean-notebooks:
	jupyter nbconvert --clear-output --inplace notebooks/*.ipynb

.PHONY: build build-check build-do clean-notebooks
