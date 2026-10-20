NAME := inception
COMPOSE	 := docker compose -f srcs/docker-compose.yml

include srcs/.env

all: up

build: dirs
	$(COMPOSE) build

up: dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart:
	$(COMPOSE) restart

re: down up

logs:
	$(COMPOSE) logs -f

ps status:
	$(COMPOSE) ps
	docker volume ls
	docker network ls

dirs:
	mkdir -p $(WP_DATA_PATH) $(DB_DATA_PATH)

host:
	grep -q "$(DOMAIN_NAME)" /etc/hosts \
		|| echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts

clean:
	$(COMPOSE) down -v --remove-orphans

fclean: clean
	$(COMPOSE) down --rmi local --remove-orphans 2>/dev/null || true
	sudo rm -rf $(WP_DATA_PATH) $(DB_DATA_PATH)

prune: fclean
	docker system prune -af --volumes

# must stay at the end
srcs/.env:
	@echo "srcs/.env not found, \"cp srcs/.env.example srcs/.env\" and fill it in"
	@exit 1

.PHONY: all build up down stop start restart re logs ps status dirs clean fclean prune host