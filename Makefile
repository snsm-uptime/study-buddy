APP_CONTAINER=study-buddy-backend-dev

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "🎯 %-20s %s\n", $$1, $$2}'

# -------------------
# General Commands
# -------------------

up: ## Start dev stack
	docker-compose -f docker-compose.dev.yml up --build

stop: ## Stop all containers
	docker-compose -f docker-compose.dev.yml down

shell: ## Enter backend container
	docker exec -it $(APP_CONTAINER) /bin/sh

test: ## Run tests inside backend container
	docker exec -it $(APP_CONTAINER) poetry run pytest

migrate: ## Apply latest Alembic migrations
	docker exec -it $(APP_CONTAINER) poetry run alembic upgrade head

makemigration: ## Generate Alembic revision
	docker exec -it $(APP_CONTAINER) poetry run alembic revision --autogenerate -m

lint: ## Run black, isort and mypy
	docker exec -it $(APP_CONTAINER) poetry run pre-commit run --all-files

base-build: ## Build the base image (used in dev/prod)
	docker build -f backend/Dockerfile.base -t study-buddy-base .

rebuild-dev: base-build ## Rebuild base + dev image
	docker-compose -f docker-compose.dev.yml build backend
