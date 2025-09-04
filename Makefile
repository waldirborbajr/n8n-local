# Default goal
.DEFAULT_GOAL := help

# Define variables
COMPOSE := docker compose
COMPOSE_FILE := docker-compose.yaml
PROJECT_NAME := $(shell basename $(CURDIR))
SERVICE ?=

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

# Check for Docker and Docker Compose
.PHONY: check
check: ## Check if Docker and Docker Compose are installed
	@echo "${BLUE}Checking dependencies...${NC}"
	@command -v docker >/dev/null 2>&1 || { echo "${RED}Docker is not installed${NC}"; exit 1; }
	@command -v $(COMPOSE) >/dev/null 2>&1 || { echo "${RED}Docker Compose is not installed${NC}"; exit 1; }
	@echo "${GREEN}Dependencies check passed!${NC}"

.PHONY: help
help: check ## Show this help message
	@echo "${BLUE}Available targets for $(PROJECT_NAME):${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-20s${NC} %s\n", $$1, $$2}'

.PHONY: up
up: check ## Start services in detached mode
	@echo "${BLUE}Starting services for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) up -d --remove-orphans || { echo "${RED}Failed to start services${NC}"; exit 1; }
	@echo "${GREEN}Services started successfully!${NC}"

.PHONY: restart
restart: check ## Restart all services
	@echo "${BLUE}Restarting services for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) restart || { echo "${RED}Failed to restart services${NC}"; exit 1; }
	@echo "${GREEN}Services restarted successfully!${NC}"

.PHONY: logs
logs: check ## Show logs for a specific service (e.g., make logs SERVICE=n8n) or all services
	@echo "${BLUE}Displaying logs for $(if $(SERVICE),$(SERVICE),all services) in $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) logs -f $(SERVICE) || { echo "${RED}Failed to display logs${NC}"; exit 1; }

.PHONY: shell
shell: check ## Open a shell in a specific service (e.g., make shell SERVICE=n8n)
	@if [ -z "$(SERVICE)" ]; then \
		echo "${RED}Error: SERVICE variable is required (e.g., make shell SERVICE=n8n)${NC}"; \
		exit 1; \
	fi
	@echo "${BLUE}Opening shell in $(SERVICE) for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) exec $(SERVICE) /bin/sh || { echo "${RED}Failed to open shell${NC}"; exit 1; }

.PHONY: down
down: check ## Stop and remove services, containers, and networks
	@echo "${BLUE}Stopping and removing services for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) down || { echo "${RED}Failed to stop services${NC}"; exit 1; }
	@echo "${GREEN}Services, containers, and networks stopped and removed!${NC}"

.PHONY: stop
stop: check ## Stop services without removing containers
	@echo "${BLUE}Stopping services for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) stop || { echo "${RED}Failed to stop services${NC}"; exit 1; }
	@echo "${GREEN}Services stopped!${NC}"

.PHONY: remove
remove: check ## Remove stopped containers for this project
	@echo "${BLUE}Removing stopped containers for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) rm -f || { echo "${RED}Failed to remove containers${NC}"; exit 1; }
	@echo "${GREEN}Stopped containers removed!${NC}"

.PHONY: clean
clean: down ## Perform a full cleanup (services, containers, networks, project-specific images, and volumes)
	@echo "${RED}WARNING: This will remove all project-specific images and volumes for $(PROJECT_NAME)!${NC}"
	@echo "${BLUE}Volumes to be removed: n8n_storage, postgres_storage, pgvector_storage, evolution_storage, waha_sessions_storage, waha_media_storage, waha_files_storage, waha_logs_storage, tailscale_config_storage, tailscale_data_storage, redis_data_storage${NC}"
	@echo "${BLUE}Press Ctrl+C to cancel or wait 5 seconds to continue...${NC}"
	@sleep 5
	@$(COMPOSE) -f $(COMPOSE_FILE) down --rmi local --volumes || { echo "${RED}Failed to clean up${NC}"; exit 1; }
	@echo "${GREEN}Full cleanup completed!${NC}"

.PHONY: status
status: check ## Show status of containers
	@echo "${BLUE}Checking container status for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) ps || { echo "${RED}Failed to display status${NC}"; exit 1; }
	@echo "${GREEN}Container status displayed!${NC}"

.PHONY: build
build: check ## Build or rebuild services
	@echo "${BLUE}Building services for $(PROJECT_NAME)...${NC}"
	@$(COMPOSE) -f $(COMPOSE_FILE) build || { echo "${RED}Failed to build services${NC}"; exit 1; }
	@echo "${GREEN}Services built successfully!${NC}"

.PHONY: update
update: build up ## Update and restart services
	@echo "${GREEN}Services updated successfully!${NC}"

.PHONY: prune
prune: check ## Prune unused Docker images and volumes system-wide (use with caution)
	@echo "${RED}WARNING: This will remove all unused images and volumes system-wide, not just for $(PROJECT_NAME)!${NC}"
	@echo "${BLUE}Press Ctrl+C to cancel or wait 5 seconds to continue...${NC}"
	@sleep 5
	@docker image prune -a || { echo "${RED}Failed to prune images${NC}"; exit 1; }
	@docker volume prune || { echo "${RED}Failed to prune volumes${NC}"; exit 1; }
	@echo "${GREEN}System-wide prune completed!${NC}"
