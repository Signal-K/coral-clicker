FROM --platform=linux/amd64 debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libfontconfig1 \
    libdbus-1-3 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libvulkan1 \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip \
    && unzip Godot_v4.3-stable_linux.x86_64.zip \
    && mv Godot_v4.3-stable_linux.x86_64 /usr/local/bin/godot \
    && rm Godot_v4.3-stable_linux.x86_64.zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENV GODOT_USER_DIR=/tmp/godot

ENTRYPOINT ["godot", "--headless", "--path", "project"]
