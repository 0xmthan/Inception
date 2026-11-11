NAME := inception
COMPOSE	 := docker compose -f srcs/docker-compose.yml

# secrets creates .env, everything else needs it
ifneq ($(MAKECMDGOALS),secrets)
include srcs/.env
endif

all: up

build: dirs secrets
	$(COMPOSE) build

up: dirs secrets
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

secrets:
	@[ -f srcs/.env ] || { cp srcs/.env.example srcs/.env && echo "created srcs/.env, check its paths"; }
	@mkdir -p secrets
	@for f in db_password db_root_password ftp_password; do \
		[ -s secrets/$$f.txt ] || { openssl rand -hex 16 > secrets/$$f.txt && echo "created secrets/$$f.txt"; }; \
	done
	@[ -s secrets/credentials.txt ] || { \
		printf 'WP_ADMIN_PASSWORD=%s\nWP_USER_PASSWORD=%s\n' $$(openssl rand -hex 16) $$(openssl rand -hex 16) \
			> secrets/credentials.txt && echo "created secrets/credentials.txt"; }
	@chmod 600 secrets/*.txt

host:
	grep -q "$(DOMAIN_NAME)" /etc/hosts \
		|| echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts

clean:
	$(COMPOSE) down -v --remove-orphans

fclean: clean
	$(COMPOSE) down --rmi all --remove-orphans 2>/dev/null || true
	sudo rm -rf $(WP_DATA_PATH) $(DB_DATA_PATH)

prune: fclean
	docker system prune -af --volumes

# must stay at the end
srcs/.env:
	@cp srcs/.env.example srcs/.env
	@echo "created srcs/.env from .env.example, check its values"

.PHONY: all build up down stop start restart re logs ps status dirs secrets clean fclean prune host