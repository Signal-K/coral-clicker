FROM node:20-bullseye

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  libgtk-3-0 \
  libnotify4 \
  libnss3 \
  libxss1 \
  libxtst6 \
  xdg-utils \
  libatspi2.0-0 \
  libdrm2 \
  libgbm1 \
  libasound2 \
  xvfb \
  && rm -rf /var/lib/apt/lists/*

CMD ["sh", "-c", "npm --prefix electron install && npm --prefix electron run dev"]
