FROM --platform=linux/amd64 debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    libfontconfig1 \
    libdbus-1-3 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libvulkan1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Godot 4.3
RUN wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip \
    && unzip Godot_v4.3-stable_linux.x86_64.zip \
    && mv Godot_v4.3-stable_linux.x86_64 /usr/local/bin/godot \
    && rm Godot_v4.3-stable_linux.x86_64.zip

# Set Godot environment
ENV GODOT_EDITOR="/usr/local/bin/godot"
ENV GODOT_USER_DIR=/tmp/godot

WORKDIR /workspace

# Copy package files for better caching
COPY package.json yarn.lock* borndotcom-react-native-godot-v1.0.1.tgz ./

# Enable corepack for Yarn 4
RUN corepack enable && corepack prepare yarn@4.9.3 --activate

RUN yarn install

# Copy everything else
COPY . .

CMD ["./scripts/test-all.sh"]
