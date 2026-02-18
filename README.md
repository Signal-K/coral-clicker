# Coral: Godot + React Native + Next.js + Electron

This repo now includes:
- A Godot level system (10 levels, completion rewards, level selector, progression state)
- Cross-runtime hosts:
  - React Native + Expo + `@borndotcom/react-native-godot`
  - Next.js browser host (`web/`)
  - Electron desktop host (`electron/`)
- Local Supabase roundtrip for game progress (frontend -> Godot -> Supabase and Supabase -> Godot)
- Dockerized dev stack for web/native bridge
- Python sprite template engine for transparent, fixed-size deep-sea sprite sheets

## Quick start

1. Generate runtime configs:
   - `npm run template:generate`
2. Install web + electron packages:
   - `npm run knowns:bootstrap`
3. Start local Supabase + docker services:
   - `make up`
4. Apply DB schema:
   - `make supabase-schema`

Supabase behavior:
- `make up` starts Supabase only when it is not already running.
- `make down` stops Supabase only if it was started by this repo.

## Docker + Make

- Main stack: `docker-compose.yml`
- Docker build files: `docker/*.Dockerfile`
- Ignore rules: `.dockerignore`
- Entry points: `Makefile`

Common commands:
- `make up` (web + bridge + native metro)
- `make up-desktop` (adds electron profile)
- `make down`
- `make logs`
- `make sprites` (runs sprite generator in Docker)

## Run each host

- React Native Metro: `npm run start` (or `make native` in docker)
- iOS: `npm run ios`
- Android: `npm run android`
- Web (Next.js): `npm run web:dev`
- Desktop (Next.js + Electron): `npm run desktop:dev`
- Bridge API only: `npm run bridge:dev`

## Sprite engine

- Install Python deps in a venv and generate sprites:
  - `python3 -m venv .venv && source .venv/bin/activate`
  - `pip install -r tools/sprites/requirements.txt`
  - `npm run sprites:gen`

## Supabase endpoints

- API: `http://127.0.0.1:54321`
- REST: `http://127.0.0.1:54321/rest/v1`
- Studio: `http://127.0.0.1:54323`
- DB: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
