# Ultimate Edition Dockerfile for OpenClaw Engine
FROM node:22-bookworm-slim

LABEL maintainer="MAGI <admin@magi.com>"

# Install system dependencies
# We maintain Apt lists only during the build to keep the image small
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    python3 \
    python3-pip \
    python3-dev \
    ffmpeg \
    build-essential \
    make \
    g++ \
    git \
    curl \
    wget \
    unzip \
    tar \
    procps \
    ripgrep \
    jq \
    dumb-init \
    fonts-liberation \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Essential Python Libraries for AI Agents
RUN pip3 install --no-cache-dir --break-system-packages \
    pandas \
    numpy \
    matplotlib \
    requests \
    beautifulsoup4 \
    youtube-transcript-api

ENV TZ=UTC

# Install OpenClaw globally with versioning and cache cleaning
ARG OPENCLAW_VERSION=latest
RUN npm install -g openclaw@${OPENCLAW_VERSION} \
    @openclaw/plugin-browser \
    @openclaw/plugin-code-interpreter \
    && npm cache clean --force

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Ensure node user exists and set up app directory
# The node image usually comes with a 'node' user, but we ensure permissions
USER node
WORKDIR /home/node/app

# Copy entrypoint script (assuming it's in the same directory as Dockerfile)
COPY --chown=node:node entrypoint.sh /home/node/app/entrypoint.sh

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

# Entrypoint setup
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/home/node/app/entrypoint.sh"]
