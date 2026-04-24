.PHONY: local local-down test lint-python lint-go scan-images tf-init tf-plan tf-apply tf-destroy fmt validate

local:
	docker compose up --build

local-down:
	docker compose down -v

test:
	pip install -r app/requirements.txt pytest && pytest app/tests/ -v

lint-python:
	pip install bandit pip-audit
	bandit -r app/src/ -ll -ii
	pip-audit -r app/requirements.txt

lint-go:
	go install golang.org/x/vuln/cmd/govulncheck@latest
	cd services/worker && govulncheck ./...
	cd services/dashboard && govulncheck ./...

scan-images:
	trivy image --severity CRITICAL,HIGH url-demo-project/api:latest
	trivy image --severity CRITICAL,HIGH url-demo-project/worker:latest
	trivy image --severity CRITICAL,HIGH url-demo-project/dashboard:latest

tf-init:
	cd terraform && terraform init

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply

tf-destroy:
	cd terraform && terraform destroy

fmt:
	cd terraform && terraform fmt -recursive

validate:
	cd terraform && terraform validate
