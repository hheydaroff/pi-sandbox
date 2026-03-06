FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies + Playwright browser deps
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    docker.io \
    ca-certificates \
    gnupg \
    jq \
    # Playwright browser dependencies (for headless Chromium)
    libglib2.0-0 \
    libnspr4 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libcairo2 \
    libpango-1.0-0 \
    libasound2 \
    # Virtual display for headed browser mode
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user with docker group access
RUN useradd -m -s /bin/bash developer && \
    usermod -aG docker developer

# Add ralph.sh autonomous loop script
COPY ralph.sh /usr/local/bin/ralph.sh
RUN chmod +x /usr/local/bin/ralph.sh

# Set up working directory
USER developer
WORKDIR /workspace

# pi installed via postCreateCommand (always gets latest)
