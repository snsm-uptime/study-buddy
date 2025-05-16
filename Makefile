APP_CONTAINER = study-buddy-backend-dev
DOCKER_COMPOSE ?= docker-compose -f docker-compose.dev.yml

# --- 🔧 Setup & Lint ---
check: lint test ## Run linters and tests

eval:
	docker exec -w /app $(APP_CONTAINER) poetry run mypy app

lint: ## Run all linters
	cd ./backend && poetry run black .
	cd ./backend && poetry run isort .
	docker exec -w /app $(APP_CONTAINER) poetry run mypy app

pre-commit-install: ## Install Git hooks in container
	cd ./backend poetry run pre-commit install

# --- 🧪 Testing ---
test: clean-pycache
	docker exec -it $(APP_CONTAINER) poetry run pytest

# --- 🧬 DB / Alembic ---
migrate: ## Run Alembic upgrade
	docker exec -it $(APP_CONTAINER) poetry run alembic upgrade head

revision: ## Create new Alembic revision: make revision m="message"
ifndef m
	$(error You must provide a message: make revision m="your message")
endif
	docker exec -it $(APP_CONTAINER) poetry run alembic revision --autogenerate -m "$(m)"

# --- 🐳 Docker ---
base-build: ## Build base image
	docker build -f backend/Dockerfile.base -t study-buddy-base .

clean-build: ## Rebuild container without cache
	$(DOCKER_COMPOSE) build --no-cache backend

rebuild-dev: base-build ## Rebuild backend using latest base
	$(DOCKER_COMPOSE) build backend

restart: down up ## Restart containers

shell: ## Open shell in backend container
	docker exec -it $(APP_CONTAINER) /bin/sh

status: ## Show running containers
	$(DOCKER_COMPOSE) ps

logs: ## Tail logs
	$(DOCKER_COMPOSE) logs -f --tail=100

up: ## Start containers
	$(DOCKER_COMPOSE) up -d backend postgres ollama

down: ## Stop containers
	$(DOCKER_COMPOSE) down

# --- 🧹 Utilities ---
clean-pycache: ## Remove __pycache__ and .pyc files
	find . -name "__pycache__" -type d -exec rm -r {} + || true
	find . -name "*.pyc" -type f -delete || true

clean-db-volume: ## CAREFUL! Removes only DB volume
	docker volume rm study-buddy_postgres-data

# --- 🚀 Misc ---
version: ## Show test/pytest version
	docker exec $(APP_CONTAINER) poetry run python -m pytest --version

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "- %-20s %s\n", $$1, $$2}'