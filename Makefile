.PHONY: setup download-models build up down run shell logs clean help

# Default settings
MODEL_DIR := ~/ai-models/stable-diffusion/zero123plus
MODEL_VERSION := zero123plus-v1.2

# Setup directories and symlinks
setup:
	@mkdir -p input output
	@if [ ! -L models ] && [ ! -d models ]; then \
		ln -s $(MODEL_DIR) models; \
		echo "Created symlink: models -> $(MODEL_DIR)"; \
	else \
		echo "models directory already exists"; \
	fi

# Download model from HuggingFace
download-models:
	@mkdir -p $(MODEL_DIR)
	@if [ ! -d "$(MODEL_DIR)/$(MODEL_VERSION)" ]; then \
		echo "Downloading $(MODEL_VERSION) from HuggingFace..."; \
		cd $(MODEL_DIR) && \
		git lfs install && \
		git clone https://huggingface.co/sudo-ai/$(MODEL_VERSION); \
	else \
		echo "Model already exists at $(MODEL_DIR)/$(MODEL_VERSION)"; \
	fi

# Docker operations
build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

# Run inference (usage: make run INPUT=input/image.png)
INPUT ?= input/sample.png
run:
	docker compose run --rm -v $(PWD)/scripts:/app/scripts:ro zero123plus \
		python /app/scripts/infer.py --input /app/$(INPUT)

# Open shell in container
shell:
	docker compose exec zero123plus bash

# Show logs
logs:
	docker compose logs -f

# Clean output directory
clean:
	@rm -f output/*.png
	@echo "Output directory cleaned"

# Help
help:
	@echo "sd-zero123plus-docker"
	@echo ""
	@echo "Setup:"
	@echo "  make setup              - Create directories and symlinks"
	@echo "  make download-models    - Download model from HuggingFace"
	@echo "  make build              - Build Docker image"
	@echo ""
	@echo "Run:"
	@echo "  make up                 - Start container (background)"
	@echo "  make run INPUT=path     - Run inference (e.g., make run INPUT=input/image.png)"
	@echo "  make down               - Stop container"
	@echo ""
	@echo "Utilities:"
	@echo "  make shell              - Open shell in container"
	@echo "  make logs               - Show container logs"
	@echo "  make clean              - Clean output directory"
