FROM debian:bookworm-slim

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
    xvfb \
    libasound2 \
    libxkbcommon0 \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Detect architecture and download correct Godot
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      export ARCH="arm64"; \
    else \
      export ARCH="x86_64"; \
    fi && \
    wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.${ARCH}.zip \
    && unzip Godot_v4.3-stable_linux.${ARCH}.zip \
    && mv Godot_v4.3-stable_linux.${ARCH} /usr/local/bin/godot \
    && rm Godot_v4.3-stable_linux.${ARCH}.zip

WORKDIR /workspace

COPY . .

ENV GODOT_USER_DIR=/tmp/godot
RUN mkdir -p /tmp/godot

ENV PROJECT_PATH=/workspace/project
ENV SCREENSHOT_DIR=/workspace/artifacts/tour
ENV REPORT_PATH=/workspace/artifacts/tour_report.json

RUN chmod +x scripts/run-tour.sh
ENTRYPOINT ["scripts/run-tour.sh"]
