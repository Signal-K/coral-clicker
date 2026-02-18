FROM python:3.12-slim

WORKDIR /workspace

CMD ["sh", "-c", "pip install --no-cache-dir -r tools/sprites/requirements.txt && python tools/sprites/generate_sprites.py --out-dir tools/sprites/out"]
