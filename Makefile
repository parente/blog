.PHONY: build clean env help release server

GIT_VERSION := $(shell git describe --abbrev=4 --dirty --always --tags)

export SITE_DOMAIN:=blog.parente.dev

help:
# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo Note: Changes to master trigger travis pushes to gh-pages


clean: ## Make a clean workspace
	@rm -rf _output
	@git clean -f .

check: ## Make a ruff check of code lint
	@ruff check generate.py

env: ## Make the current python environment install all prereqs
	@pip install -r requirements.txt -r requirements-dev.txt

build: ## Make a local copy of the blog
	python generate.py

server: ## Make a local web server point to the latest local build
	@open http://localhost:8000/_output && python -m http.server