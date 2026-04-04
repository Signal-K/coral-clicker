# Makefile for Coral Clicker

.PHONY: help up down restart ps logs shell-web shell-godot test test-godot test-tour godot-export-web nextjs-test clean prune up-desktop sprites supabase-schema

help:
	@echo "Available commands:"
	@echo "  up                 - Start all services in docker"
	@echo "  down               - Stop all services"
	@echo "  restart            - Restart all services"
	@echo "  ps                 - Show running services"
	@echo "  logs               - Show logs from all services"
	@echo "  up-desktop         - Start web, bridge and electron (desktop profile)"
	@echo "  sprites            - Generate species sprites using the sprites tool"
	@echo "  supabase-schema    - Apply supabase/schema.sql to local Supabase"
	@echo "  test               - Run all tests in docker (test-suite + tour)"
	@echo "  test-tour          - Run Godot tour test pass in docker"
	@echo "  test-godot         - Run Godot E2E tests in docker"
	@echo "  godot-export-web   - Export Godot project to Web (web/public/godot)"
	@echo "  nextjs-test        - Export Godot to Web and run tests in Next.js container"
	@echo "  clean              - Delete all local build artifacts (.venv, coverage, node_modules)"
	@echo "  prune              - Delete dangling docker images and build cache"

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

ps:
	docker compose ps

logs:
	docker compose logs -f

up-desktop:
	docker compose --profile desktop up -d

sprites:
	docker compose --profile tools run --rm sprites

supabase-schema:
	./scripts/apply-supabase-schema.sh

test:
	docker compose --profile test run --rm test-suite && \
	docker compose --profile test run --rm tour; \
	status=$$?; \
	$(MAKE) clean; \
	exit $$status

test-tour:
	docker compose --profile test run --rm tour; \
	status=$$?; \
	$(MAKE) clean; \
	exit $$status

test-godot:
	docker compose --profile test run --rm godot-test; \
	status=$$?; \
	$(MAKE) clean; \
	exit $$status

godot-export-web:
	@mkdir -p web/public/godot
	docker compose --profile test run --rm godot-test --export-release "Web" ../web/public/godot/index.html

nextjs-test: godot-export-web
	docker compose run --rm web yarn test; \
	status=$$?; \
	$(MAKE) clean; \
	exit $$status

clean: clean-build-artifacts prune
	docker compose --profile test --profile desktop --profile tools down -v --rmi local --remove-orphans

clean-build-artifacts:
	rm -rf .venv coverage web/.next web/out electron/node_modules web/node_modules node_modules /tmp/coral-compose-config.txt generated-config/*.json
	rm -rf ios/build android/app/build android/.gradle ios/Pods ios/Podfile.lock
	rm -f ios/GodotTest.pck ios/Pengu.zip
	rm -rf project/.godot .godot
	rm -f web/.env.local electron/.env
	rm -rf tools/sprites/out
	rm -rf web/public/godot
	rm -rf generated-config

prune:
	docker system prune -f --volumes
	docker image prune -a -f --filter "until=24h"
	docker builder prune -f
	@echo "Docker storage reclaimed. Current usage:"
	docker system df
