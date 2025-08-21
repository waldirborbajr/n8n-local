# Default goal
.DEFAULT_GOAL := help

# Define variables
COMPOSE := docker compose
CONTAINER := evolution
VOLUME := n8n-local_evolution_storage

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help
help: ## Show this help message
	@echo "${BLUE}Available targets:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-15s${NC} %s\n", $$1, $$2}'

.PHONY: update
update: stop dang up ## Update and restart services
	@echo "${GREEN}Services updated successfully!${NC}"

.PHONY: up
up: ## Start services in detached mode
	@echo "${BLUE}Starting services...${NC}"
	@$(COMPOSE) up -d --remove-orphans
	@echo "${GREEN}Services started successfully!${NC}"

.PHONY: restart
restart: ## Restart all services
	@echo "${BLUE}Restarting services...${NC}"
	@$(COMPOSE) restart
	@echo "${GREEN}Services restarted successfully!${NC}"

.PHONY: log
log: ## Show logs for the evolution container
	@echo "${BLUE}Displaying logs for ${CONTAINER}...${NC}"
	@docker logs -f ${CONTAINER}

.PHONY: down
down: ## Stop and remove all services
	@echo "${BLUE}Stopping and removing services...${NC}"
	@$(COMPOSE) down
	@echo "${GREEN}Services stopped and removed!${NC}"

.PHONY: stop
stop: ## Stop all services and remove containers
	@echo "${BLUE}Stopping services...${NC}"
	@$(COMPOSE) stop
	@echo "${BLUE}Removing containers...${NC}"
	@$(COMPOSE) rm -f
	@echo "${GREEN}Services stopped and containers removed!${NC}"

.PHONY: dang
dang: ## Remove dangling images and volumes
	@echo "${BLUE}Cleaning up dangling images and volumes...${NC}"
	@if [ -n "$$(docker images -qf dangling=true)" ]; then \
		docker rmi $$(docker images -qf dangling=true); \
		echo "${GREEN}Dangling images removed!${NC}"; \
	else \
		echo "${GREEN}No dangling images found!${NC}"; \
	fi
	@if [ -n "$$(docker volume ls -qf dangling=true)" ]; then \
		docker volume rm $$(docker volume ls -qf dangling=true); \
		echo "${GREEN}Dangling volumes removed!${NC}"; \
	else \
		echo "${GREEN}No dangling volumes found!${NC}"; \
	fi

.PHONY: remove
remove: ## Remove all containers
	@echo "${BLUE}Removing all containers...${NC}"
	@if [ -n "$$(docker ps -a -q)" ]; then \
		docker rm $$(docker ps -a -q) -f; \
		echo "${GREEN}All containers removed!${NC}"; \
	else \
		echo "${GREEN}No containers to remove!${NC}"; \
	fi

.PHONY: volume
volume: ## Remove specific volume
	@echo "${BLUE}Removing volume ${VOLUME}...${NC}"
	@if [ -n "$$(docker volume ls -q -f name=${VOLUME})" ]; then \
		docker volume rm ${VOLUME}; \
		echo "${GREEN}Volume ${VOLUME} removed!${NC}"; \
	else \
		echo "${GREEN}Volume ${VOLUME} not found!${NC}"; \
	fi

.PHONY: clean
clean: down remove volume ## Perform a full cleanup (down, remove containers, remove volume)
	@echo "${GREEN}Full cleanup completed!${NC}"

.PHONY: status
status: ## Show status of containers
	@echo "${BLUE}Checking container status...${NC}"
	@docker ps -a
	@echo "${GREEN}Container status displayed!${NC}"

.PHONY: build
build: ## Build or rebuild services
	@echo "${BLUE}Building services...${NC}"
	@$(COMPOSE) build
	@echo "${GREEN}Services built successfully!${NC}"
