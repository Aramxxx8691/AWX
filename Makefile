RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

# Service Names
GRAFANA=grafana
PORTAINER=portainer
POSTGRES=postgres
LOKI=loki

# Image Names
GRAFANA_IMAGE=grafana/grafana:latest
PORTAINER_IMAGE=portainer/portainer-ce:latest
POSTGRES_IMAGE=postgres:latest
LOKI_IMAGE=grafana/loki:2.8.2

# Volumes
PORTAINER_VOLUME=portainer_data
LOKI_VOLUME=loki_data

all: up

build:
	@echo "$(YELLOW)🛠️  Building Docker images...$(NC)"
	@docker-compose build || echo "$(RED)❌ Error: Failed to build images.$(NC)"

up:
	@echo "$(GREEN)🚀  Starting containers...$(NC)"
	@docker-compose up -d || echo "$(RED)❌ Error: Failed to start containers.$(NC)"
	@docker-compose logs -f || echo "$(RED)❌ Error: Failed to fetch logs.$(NC)"

down:
	@echo "$(YELLOW)⏹️  Stopping containers...$(NC)"
	@docker-compose down || echo "$(RED)❌ Error: Failed to stop containers.$(NC)"

start:
	@echo "$(GREEN)🚀  Starting containers...$(NC)"
	@docker-compose start || echo "$(RED)❌ Error: Failed to start containers.$(NC)"

stop:
	@echo "$(YELLOW)⏹️  Stopping containers...$(NC)"
	@docker-compose stop || echo "$(RED)❌ Error: Failed to stop containers.$(NC)"

shell-grafana:
	@echo "$(GREEN)🔧 Accessing Grafana container shell...$(NC)"
	@docker exec -it $(GRAFANA) /bin/bash || echo "$(RED)❌ Error: Failed to access Grafana shell.$(NC)"

shell-portainer:
	@echo "$(GREEN)🔧 Accessing Portainer container shell...$(NC)"
	@docker exec -it $(PORTAINER) /bin/bash || echo "$(RED)❌ Error: Failed to access Portainer shell.$(NC)"

shell-postgres:
	@echo "$(GREEN)🔧 Accessing PostgreSQL container shell...$(NC)"
	@docker exec -it $(POSTGRES) /bin/bash || echo "$(RED)❌ Error: Failed to access PostgreSQL shell.$(NC)"

shell-loki:
	@echo "$(GREEN)🔧 Accessing Loki container shell...$(NC)"
	@docker exec -it $(LOKI) /bin/bash || echo "$(RED)❌ Error: Failed to access Loki shell.$(NC)"

rm-grafana:
	@echo "$(RED)🗑️  Removing Grafana container...$(NC)"
	@if docker ps -a | grep -q "$(GRAFANA)"; then \
		docker rm -f $(GRAFANA) || echo "$(RED)❌ Error: Failed to remove Grafana container.$(NC)"; \
	else \
		echo "$(YELLOW)No Grafana container found.$(NC)"; \
	fi

rm-portainer:
	@echo "$(RED)🗑️  Removing Portainer container...$(NC)"
	@if docker ps -a | grep -q "$(PORTAINER)"; then \
		docker rm -f $(PORTAINER) || echo "$(RED)❌ Error: Failed to remove Portainer container.$(NC)"; \
	else \
		echo "$(YELLOW)No Portainer container found.$(NC)"; \
	fi

rm-postgres:
	@echo "$(RED)🗑️  Removing PostgreSQL container...$(NC)"
	@if docker ps -a | grep -q "$(POSTGRES)"; then \
		docker rm -f $(POSTGRES) || echo "$(RED)❌ Error: Failed to remove PostgreSQL container.$(NC)"; \
	else \
		echo "$(YELLOW)No PostgreSQL container found.$(NC)"; \
	fi

rm-loki:
	@echo "$(RED)🗑️  Removing Loki container...$(NC)"
	@if docker ps -a | grep -q "$(LOKI)"; then \
		docker rm -f $(LOKI) || echo "$(RED)❌ Error: Failed to remove Loki container.$(NC)"; \
	else \
		echo "$(YELLOW)No Loki container found.$(NC)"; \
	fi

rm-containers:
	@echo "$(RED)🗑️  Removing all containers...$(NC)"
	@docker rm -f $(GRAFANA) $(PORTAINER) $(POSTGRES) $(LOKI) || echo "$(RED)❌ Error: Failed to remove containers.$(NC)"

rm-image-grafana:
	@echo "$(RED)🗑️  Removing Grafana image...$(NC)"
	@IMAGES=$$(docker images -q $(GRAFANA_IMAGE)); \
	if [ -n "$$IMAGES" ]; then \
		docker rmi -f $$IMAGES || echo "$(RED)❌ Error: Failed to remove Grafana image.$(NC)"; \
	else \
		echo "$(YELLOW)No Grafana image found.$(NC)"; \
	fi

rm-image-portainer:
	@echo "$(RED)🗑️  Removing Portainer image...$(NC)"
	@IMAGES=$$(docker images -q $(PORTAINER_IMAGE)); \
	if [ -n "$$IMAGES" ]; then \
		docker rmi -f $$IMAGES || echo "$(RED)❌ Error: Failed to remove Portainer image.$(NC)"; \
	else \
		echo "$(YELLOW)No Portainer image found.$(NC)"; \
	fi

rm-image-postgres:
	@echo "$(RED)🗑️  Removing PostgreSQL image...$(NC)"
	@IMAGES=$$(docker images -q $(POSTGRES_IMAGE)); \
	if [ -n "$$IMAGES" ]; then \
		docker rmi -f $$IMAGES || echo "$(RED)❌ Error: Failed to remove PostgreSQL image.$(NC)"; \
	else \
		echo "$(YELLOW)No PostgreSQL image found.$(NC)"; \
	fi

rm-image-loki:
	@echo "$(RED)🗑️  Removing Loki image...$(NC)"
	@IMAGES=$$(docker images -q $(LOKI_IMAGE)); \
	if [ -n "$$IMAGES" ]; then \
		docker rmi -f $$IMAGES || echo "$(RED)❌ Error: Failed to remove Loki image.$(NC)"; \
	else \
		echo "$(YELLOW)No Loki image found.$(NC)"; \
	fi

rm-images:
	@echo "$(RED)🗑️  Removing all project images...$(NC)"
	@$(MAKE) rm-image-grafana rm-image-portainer rm-image-postgres rm-image-loki

rm-portainer-volume:
	@echo "$(RED)🗑️  Removing Portainer volume...$(NC)"
	@if docker volume ls | grep -q "$(PORTAINER_VOLUME)"; then \
		docker volume rm $(PORTAINER_VOLUME) || echo "$(RED)❌ Error: Failed to remove volume.$(NC)"; \
	else \
		echo "$(YELLOW)No Portainer volume found.$(NC)"; \
	fi

rm-loki-volume:
	@echo "$(RED)🗑️  Removing Loki volume...$(NC)"
	@if docker volume ls | grep -q "$(LOKI_VOLUME)"; then \
		docker volume rm $(LOKI_VOLUME) || echo "$(RED)❌ Error: Failed to remove Loki volume.$(NC)"; \
	else \
		echo "$(YELLOW)No Loki volume found.$(NC)"; \
	fi

clean: down rm-containers rm-images

fclean: clean rm-portainer-volume rm-loki-volume

re: clean all

.PHONY: all build up down start stop \
        rm-grafana rm-portainer rm-postgres rm-loki rm-containers \
        rm-image-grafana rm-image-portainer rm-image-postgres rm-image-loki rm-images \
        rm-portainer-volume rm-loki-volume clean fclean re
