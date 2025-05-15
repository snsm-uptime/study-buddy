APP_CONTAINER = study-buddy-backend-dev
DOCKER_COMPOSE ?= docker-compose -f docker-compose.dev.yml

help:  ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "🎯 %-20s %s\n", $$1, $$2}'

up:
	$(DOCKER_COMPOSE) up -d backend postgres ollama

stop:
	$(DOCKER_COMPOSE) down

shell:
	docker exec -it $(APP_CONTAINER) /bin/sh

test:
	docker exec -it $(APP_CONTAINER) poetry run pytest

migrate:  ## ⬆️ Run Alembic migrations
	docker exec -it $(APP_CONTAINER) poetry run alembic upgrade head

makemigration:  ## ✏️ Generate new Alembic revision
	docker exec -it $(APP_CONTAINER) poetry run alembic revision --autogenerate -m

lint:
	cd ./backend && poetry run black .
	cd ./backend && poetry run isort ./backend
	docker exec -w /app $(APP_CONTAINER) poetry run mypy app

base-build: ## Build the base image (used in dev/prod)
	docker build -f backend/Dockerfile.base -t study-buddy-base .

rebuild-dev: base-build  ## 🔄 Rebuild backend using updated base
	$(DOCKER_COMPOSE) build backend

pre-commit-install:  ## 🔧 Install Git hooks
	docker exec -it $(APP_CONTAINER) poetry run pre-commit install

check: lint test
	
