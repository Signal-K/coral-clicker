SHELL := /bin/bash

.PHONY: help up up-desktop down restart ps logs bootstrap template web bridge native electron sprites supabase-schema

help:
	@echo "Targets:"
	@echo "  make bootstrap      - Generate runtime config and install host deps"
	@echo "  make up             - Start supabase (if needed) + docker stack"
	@echo "  make up-desktop     - Start stack + electron profile"
	@echo "  make down           - Stop docker stack; stop supabase only if managed here"
	@echo "  make logs           - Follow compose logs"
	@echo "  make ps             - List compose services"
	@echo "  make web            - Start only web service"
	@echo "  make bridge         - Start only bridge service"
	@echo "  make native         - Start only native metro service"
	@echo "  make electron       - Start electron (desktop profile)"
	@echo "  make sprites        - Run sprite generator in docker (tools profile)"
	@echo "  make supabase-schema- Apply local supabase schema"

bootstrap:
	npm run knowns:bootstrap

template:
	npm run template:generate

up:
	./scripts/dev-up.sh

up-desktop:
	./scripts/supabase-ensure-running.sh
	docker compose --profile desktop up -d

down:
	./scripts/dev-down.sh

restart: down up

ps:
	docker compose ps

logs:
	docker compose logs -f --tail=200

web:
	./scripts/supabase-ensure-running.sh
	docker compose up -d web

bridge:
	./scripts/supabase-ensure-running.sh
	docker compose up -d bridge

native:
	./scripts/supabase-ensure-running.sh
	docker compose up -d native-metro

electron:
	./scripts/supabase-ensure-running.sh
	docker compose --profile desktop up -d electron web

sprites:
	docker compose --profile tools run --rm sprites

supabase-schema:
	./scripts/apply-supabase-schema.sh
