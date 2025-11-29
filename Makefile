COMPOSE_FILE = srcs/docker-compose.yml

.PHONY: all up build start down stop clean re ps logs buildup

all: up

up:
	docker-compose -f $(COMPOSE_FILE) up -d

buildup:
	docker-compose -f $(COMPOSE_FILE) up --build -d

build:
	docker-compose -f $(COMPOSE_FILE) build

start:
	docker-compose -f $(COMPOSE_FILE) start

stop:
	docker-compose -f $(COMPOSE_FILE) stop

down:
	docker-compose -f $(COMPOSE_FILE) down

clean:
	docker-compose -f $(COMPOSE_FILE) down --rmi all --remove-orphans
	docker builder prune --all -f

re: clean all

ps:
	docker-compose -f $(COMPOSE_FILE) ps -a

logs:
	docker-compose -f $(COMPOSE_FILE) logs