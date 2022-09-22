DOCKER ?= $(shell command -v docker 2> /dev/null)
JEKYLL_VERSION := 3.8.5
SERVE_PORT := 4000
LIVERELOAD_PORT := 35729
TIMEZONE := Asia/Tokyo
BASE_DIR := $$PWD

DOCKER_RUN := @$(DOCKER) run -it --rm -e TZ=$(TIMEZONE)
DOCKER_OPTS_VOLUMES := -v $(BASE_DIR)/docs:/srv/jekyll -v $(BASE_DIR)/.bundle:/usr/local/bundle
DOCKER_OPTS_PORTS := -p $(SERVE_PORT):$(SERVE_PORT) -p $(LIVERELOAD_PORT):$(LIVERELOAD_PORT)
DOCKER_IMAGE := jekyll/jekyll:$(JEKYLL_VERSION)

.DEFAULT_GOAL = help

.PHONY: bash
bash: ## open interactive shell (bash)
	$(DOCKER_RUN) \
		$(DOCKER_OPTS_VOLUMES) \
		$(DOCKER_IMAGE) \
		bash

.PHONY: build
build: dep ## jekyll build
	$(DOCKER_RUN)
		$(DOCKER_OPTS_VOLUMES) \
		-e JEKYLL_ENV=production \
		$(DOCKER_IMAGE) \
		bundle exec jekyll build

.PHONY: owner
owner: ## change docs directory ownership
	$(DOCKER_RUN) \
		$(DOCKER_OPTS_VOLUMES) \
		$(DOCKER_IMAGE) \
		chown -R jekyll:jekyll .

.PHONY: serve
serve: dep ## jekyll serve
	$(DOCKER_RUN) \
		$(DOCKER_OPTS_VOLUMES) \
		$(DOCKER_OPTS_PORTS) \
		$(DOCKER_IMAGE) \
		bundle exec jekyll serve \
			--host 0.0.0.0 \
			--port $(SERVE_PORT)
			--trace \
			--draft \
			--livereload \
			--livereload-port $(LIVERELOAD_PORT) \
			--config _config.dev.yml

.PHONY: dep
dep: ## install dependencies
	$(DOCKER_RUN) \
		$(DOCKER_OPTS_VOLUMES) \
		$(DOCKER_IMAGE) \
		bundle install

.PHONY: update
update: ## update dependencies
	$(DOCKER_RUN) \
		$(DOCKER_OPTS_VOLUMES) \
		$(DOCKER_IMAGE) \
		bundle update

.PHONY: help
help:
	@grep -E '^[A-Za-z_-]*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf  "\033[36m%-10s\033[0m %s\n", $$1, $$2}'