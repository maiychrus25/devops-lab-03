.PHONY: build test lint

build:
	terraform -chdir=terraform-aws-lab init -input=false -no-color
	terraform -chdir=terraform-aws-lab validate -no-color
	@echo "Build succeeded"

test:
	python3 -m unittest discover -s scripts -p 'test_*.py'
	terraform -chdir=terraform-aws-lab test -no-color

lint:
	terraform -chdir=terraform-aws-lab fmt -check -recursive
	node scripts/check-docs.js
