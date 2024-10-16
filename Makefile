build:
	pip install --ignore-requires-python awsglue-local==1.0.2
	install-glue-kernels

clean-notebooks:
	jupyter nbconvert --clear-output --inplace notebooks/*.ipynb

.PHONY: build clean-notebooks
